class_name BancoRendimiento
extends Node
## Banco de rendimiento (M5-prep c) para comparar escritorio y navegador. En web se abre con `?banco` en la URL
## (PantallaInicio); en escritorio, corriendo esta escena. Mide:
## - PrevisionTurno (la operación más pesada: alcance por Zancadas y Golpes) en el peor caso sintético del
##   test de rendimiento (actor con Velocidad 30 en el centro del mapa B, rodeado) y en cada decisión de la
##   party en el combate de prueba (REPETICIONES veces cada una).
## - FPS en exploración y mientras se anima el combate.
## Muestra el resumen en pantalla, lo imprime y, en web, lo manda al servidor local (`/banco?...`), que lo
## deja en su registro. Solo depuración: no cambia nada del juego.

const ESCENA_MUNDO: String = "res://scenes/world/mundo.tscn"
const MAPA_B: String = "res://scenes/world/mapas/mapa_prueba_b.tscn"
const ENEMIGO: String = "res://data/criaturas/enemigo_prueba_cuerpo_a_cuerpo.tres"
const BUILDS: Array[String] = ["res://data/builds/guerrero.tres", "res://data/builds/picaro.tres",
	"res://data/builds/clerigo.tres", "res://data/builds/bruja.tres"]
const REPETICIONES: int = 5
const DECISIONES: int = 12
const FRAMES_MAXIMOS: int = 20000
const RUTA_GUARDADO: String = "user://partida_banco.json"

var _texto: Label
var _resultados: Dictionary = {}


func _ready() -> void:
	_texto = Label.new()
	_texto.position = Vector2(8, 8)
	var capa: CanvasLayer = CanvasLayer.new()
	capa.layer = 10
	capa.add_child(_texto)
	add_child(capa)
	_correr.call_deferred()


func _correr() -> void:
	SaveSystem.ruta = RUTA_GUARDADO  # no pisa la partida real
	_mostrar("Banco: peor caso sintético…")
	_resultados["plataforma"] = "web" if OS.has_feature("web") else OS.get_name()
	_resultados["sintetico"] = _estadistica(await _peor_caso())
	_mostrar("Banco: combate de prueba…")
	var medidas: Dictionary = await _combate_real()
	_resultados["combate"] = _estadistica(medidas.previsiones)
	_resultados["fps_combate"] = _estadistica(medidas.fps_combate)
	_resultados["fps_exploracion"] = _estadistica(medidas.fps_exploracion)
	var resumen: String = JSON.stringify(_resultados)
	print("BANCO ", resumen)
	_mostrar("BANCO\n" + resumen.replace(",\"", ",\n\""))
	_informar(resumen)


## Peor caso del test de rendimiento, en milisegundos por cálculo.
func _peor_caso() -> Array[float]:
	var mapa: Node = (load(MAPA_B) as PackedScene).instantiate()
	add_child(mapa)
	await get_tree().process_frame
	var grilla: GrillaMapa = mapa.construir_grilla()
	var libres: Array[Vector2i] = []
	var region: Rect2i = grilla.region()
	for x in range(region.position.x, region.end.x):
		for y in range(region.position.y, region.end.y):
			if grilla.es_transitable(Vector2i(x, y)):
				libres.append(Vector2i(x, y))
	var centro: Vector2i = region.get_center()
	libres.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return Medicion.pies_entre(a, centro) < Medicion.pies_entre(b, centro))
	var rapido: DefinicionCriatura = (load(ENEMIGO) as DefinicionCriatura).duplicate()
	rapido.velocidad_pies = 30
	var participantes: Array[Combatiente] = [Combatiente.desde_criatura(&"actor", rapido, libres[0])]
	for i in 3:
		participantes.append(Combatiente.desde_criatura(StringName("aliado%d" % i), load(ENEMIGO), libres[1 + i]))
	for i in BUILDS.size():
		participantes.append(Combatiente.desde_personaje(StringName("pj%d" % i), ArmadorPersonaje.armar(load(BUILDS[i])), libres[8 + i * 6]))
	var combate: Combate = Combate.new(participantes, grilla, Dados.new(1))
	combate.iniciar()
	while combate.turno_actual().id != &"actor":
		combate.terminar_turno()
	var tiempos: Array[float] = []
	for i in REPETICIONES * 4:
		tiempos.append(_medir_prevision(combate))
		await get_tree().process_frame
	mapa.queue_free()
	return tiempos


## Combate de prueba del mapa B: la party pasa sus turnos; en cada decisión se mide la previsión.
func _combate_real() -> Dictionary:
	GameState.nueva_partida()
	GameState.reiniciar_dados(7)
	var mundo: Node = (load(ESCENA_MUNDO) as PackedScene).instantiate()
	add_child(mundo)
	var party: ControlParty = mundo.get_node("Party")
	var control: ControladorCombate = mundo.get_node("ControladorCombate")
	var medidas: Dictionary = {"previsiones": [] as Array[float], "fps_combate": [] as Array[float], "fps_exploracion": [] as Array[float]}
	await _esperar(func() -> bool: return not party.bloqueado)
	party.ir_a_celda(Vector2i(19, 5))
	await _esperar(func() -> bool:
		medidas.fps_exploracion.append(Engine.get_frames_per_second())
		return GameState.id_mapa_actual == &"mapa_prueba_b" and not party.bloqueado)
	party.ir_a_celda(Vector2i(13, 10))
	await _esperar(func() -> bool: return control.en_curso())
	var decisiones: Array[int] = [0]  # las lambdas capturan por valor: el contador va en un Array
	await _esperar(func() -> bool:
		if not control.en_curso() or decisiones[0] >= DECISIONES:
			return true
		if control.animando():
			medidas.fps_combate.append(Engine.get_frames_per_second())
		elif control.esperando_decision():
			for i in REPETICIONES:
				medidas.previsiones.append(_medir_prevision(control.combate()))
			decisiones[0] += 1
			_mostrar("Banco: decisión %d/%d" % [decisiones[0], DECISIONES])
			control.terminar_turno_jugador()
		return false)
	return medidas


func _medir_prevision(combate: Combate) -> float:
	var inicio: int = Time.get_ticks_usec()
	PrevisionTurno.new(combate)
	return (Time.get_ticks_usec() - inicio) / 1000.0


func _esperar(condicion: Callable) -> void:
	for i in FRAMES_MAXIMOS:
		if condicion.call():
			return
		await get_tree().process_frame


static func _estadistica(valores: Array) -> Dictionary:
	if valores.is_empty():
		return {"n": 0}
	var ordenados: Array = valores.duplicate()
	ordenados.sort()
	var suma: float = 0.0
	for v: float in ordenados:
		suma += v
	return {"n": ordenados.size(), "media": snappedf(suma / ordenados.size(), 0.01), "mediana": snappedf(ordenados[ordenados.size() / 2], 0.01),
		"min": snappedf(ordenados[0], 0.01), "max": snappedf(ordenados[-1], 0.01)}


func _mostrar(texto: String) -> void:
	print("banco: ", texto.get_slice("\n", 0))
	_texto.text = texto


## En web, deja el resumen en el registro del servidor local (una petición GET; la respuesta no importa).
func _informar(resumen: String) -> void:
	if not OS.has_feature("web"):
		return
	var pedido: HTTPRequest = HTTPRequest.new()
	add_child(pedido)
	var origen: String = str(JavaScriptBridge.eval("window.location.origin"))
	pedido.request("%s/banco?%s" % [origen, resumen.uri_encode()])

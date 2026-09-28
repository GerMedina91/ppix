class_name BancoRendimiento
extends Node
## Banco de rendimiento (M5-prep c) para comparar escritorio y navegador. En web se abre con `?banco` en la URL
## (PantallaInicio); en escritorio, corriendo esta escena. Mide:
## - PrevisionTurno (la operación más pesada: alcance por Zancadas y Golpes) en el peor caso sintético (actor
##   con Velocidad 30 rodeado, en el centro del mapa B y en el claro del corazón del Monte) y en cada decisión de
##   la party en los tres combates del slice (M5; REPETICIONES veces cada una).
## - FPS en exploración y mientras se anima el combate.
## Muestra el resumen en pantalla, lo imprime y, en web, lo manda al servidor local (`/banco?...`), que lo
## deja en su registro. Solo depuración: no cambia nada del juego.

const ESCENA_MUNDO: String = "res://scenes/world/mundo.tscn"
const MAPA_B: String = "res://scenes/world/mapas/mapa_prueba_b.tscn"
const MAPA_CORAZON: String = "res://scenes/world/mapas/corazon_del_monte.tscn"
## Los combates del slice: mapa, casilla donde arranca la party (partida cargada), casilla de la zona del
## encuentro y enemigos que ya no están (para llegar al combate final).
const COMBATES: Array[Dictionary] = [
	{"clave": "combate_1", "mapa": &"linde_del_monte", "desde": Vector2i(8, 7), "zona": Vector2i(12, 7), "retirados": []},
	{"clave": "combate_2", "mapa": &"corazon_del_monte", "desde": Vector2i(2, 4), "zona": Vector2i(5, 4), "retirados": []},
	{"clave": "combate_3", "mapa": &"corazon_del_monte", "desde": Vector2i(15, 11), "zona": Vector2i(15, 13),
		"retirados": [&"Zombi1", &"Zombi2", &"Esqueleto", &"EsqueletoArco"], "resuelto": &"encuentro_muertos"},
]
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
	_resultados["sintetico"] = _estadistica(await _peor_caso(MAPA_B))
	_resultados["sintetico_corazon"] = _estadistica(await _peor_caso(MAPA_CORAZON))
	var fps_combate: Array[float] = []
	var fps_exploracion: Array[float] = []
	for datos: Dictionary in COMBATES:
		_mostrar("Banco: %s…" % datos.clave)
		var medidas: Dictionary = await _combate_real(datos)
		_resultados[datos.clave] = _estadistica(medidas.previsiones)
		fps_combate.append_array(medidas.fps_combate)
		fps_exploracion.append_array(medidas.fps_exploracion)
	_resultados["fps_combate"] = _estadistica(fps_combate)
	_resultados["fps_exploracion"] = _estadistica(fps_exploracion)
	var resumen: String = JSON.stringify(_resultados)
	print("BANCO ", resumen)
	_mostrar("BANCO\n" + resumen.replace(",\"", ",\n\""))
	_informar(resumen)
	if OS.get_cmdline_user_args().has("salir"):  # escritorio, desde la línea de comandos: `-- salir`
		get_tree().quit()


## Peor caso del test de rendimiento en el centro de `ruta_mapa`, en milisegundos por cálculo.
func _peor_caso(ruta_mapa: String) -> Array[float]:
	var mapa: Node = (load(ruta_mapa) as PackedScene).instantiate()
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


## Un combate del slice: la party arranca cerca (como una partida cargada), camina a la zona y pasa sus turnos;
## en cada decisión se mide la previsión.
func _combate_real(datos: Dictionary) -> Dictionary:
	GameState.nueva_partida()
	GameState.reiniciar_dados(7)
	for nombre: StringName in datos.retirados:
		GameState.mundo.retirar_enemigo(datos.mapa, nombre)
	if datos.has("resuelto"):
		GameState.mundo.resolver_encuentro(datos.mapa, datos.resuelto)
	GameState.id_mapa_actual = datos.mapa
	GameState.ubicacion = {"celdas": {&"Miembro1": datos.desde}, "entrada": &""}
	GameState.recien_cargada = true
	var mundo: Node = (load(ESCENA_MUNDO) as PackedScene).instantiate()
	(mundo.get_node("PosicionamientoPrevio") as PosicionamientoPrevio).omitir = true
	add_child(mundo)
	var party: ControlParty = mundo.get_node("Party")
	var control: ControladorCombate = mundo.get_node("ControladorCombate")
	var medidas: Dictionary = {"previsiones": [] as Array[float], "fps_combate": [] as Array[float], "fps_exploracion": [] as Array[float]}
	# La partida cargada ubica a la party en diferido: se espera a que esté en su casilla.
	await _esperar(func() -> bool: return not party.bloqueado and party.lider().celda == datos.desde)
	party.ir_a_celda(datos.zona)
	await _esperar(func() -> bool:
		medidas.fps_exploracion.append(Engine.get_frames_per_second())
		return control.en_curso())
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
			_mostrar("Banco: %s, decisión %d/%d" % [datos.clave, decisiones[0], DECISIONES])
			control.terminar_turno_jugador()
		return false)
	mundo.queue_free()
	await get_tree().process_frame
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

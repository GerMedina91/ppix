extends GdUnitTestSuite
## Rendimiento de la previsión de turno en el mapa real (B): velocidad 30, 3 acciones y varios enemigos.
## El cálculo completo se hace una vez por decisión; el cursor solo consulta.

const DadosFijos: GDScript = preload("res://tests/utiles/dados_fijos.gd")
const ESCENA: String = "res://scenes/world/mapas/mapa_prueba_b.tscn"
const ENEMIGO: String = "res://data/criaturas/enemigo_prueba_cuerpo_a_cuerpo.tres"
const BUILDS: Array[String] = ["res://data/builds/guerrero.tres", "res://data/builds/picaro.tres",
	"res://data/builds/clerigo.tres", "res://data/builds/bruja.tres"]
## Límites holgados para no depender de la máquina; lo medido se imprime.
const MAXIMO_CALCULO_MS: float = 15.0
const MAXIMO_CONSULTA_MS: float = 0.05
const REPETICIONES: int = 5

var _combate: Combate


func before_test() -> void:
	var mapa: Mapa = auto_free(load(ESCENA).instantiate())
	add_child(mapa)
	var grilla: GrillaMapa = mapa.construir_grilla()
	var libres: Array[Vector2i] = _libres(grilla)
	var centro: Vector2i = grilla.region().get_center()
	libres.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return Medicion.pies_entre(a, centro) < Medicion.pies_entre(b, centro))
	# El actor (velocidad 30) en el centro; tres aliados cerca y cuatro enemigos alrededor.
	var rapido: DefinicionCriatura = (load(ENEMIGO) as DefinicionCriatura).duplicate()
	rapido.velocidad_pies = 30
	var participantes: Array[Combatiente] = [Combatiente.desde_criatura(&"actor", rapido, libres[0])]
	for i in 3:
		participantes.append(Combatiente.desde_criatura(StringName("aliado%d" % i), load(ENEMIGO), libres[1 + i]))
	for i in BUILDS.size():
		var personaje: DefinicionPersonaje = ArmadorPersonaje.armar(load(BUILDS[i]))
		participantes.append(Combatiente.desde_personaje(StringName("pj%d" % i), personaje, libres[8 + i * 6]))
	var dados: Array = [20]
	for i in participantes.size() - 1:
		dados.append(1)
	_combate = Combate.new(participantes, grilla, DadosFijos.new(dados))
	_combate.iniciar()


func _libres(grilla: GrillaMapa) -> Array[Vector2i]:
	var libres: Array[Vector2i] = []
	var region: Rect2i = grilla.region()
	for x in range(region.position.x, region.end.x):
		for y in range(region.position.y, region.end.y):
			if grilla.es_transitable(Vector2i(x, y)):
				libres.append(Vector2i(x, y))
	return libres


func test_el_calculo_completo_tarda_pocos_milisegundos() -> void:
	var actor: Combatiente = _combate.turno_actual()
	assert_str(actor.id).is_equal("actor")
	assert_int(actor.acciones_restantes).is_equal(3)
	var prevision: PrevisionTurno = PrevisionTurno.new(_combate)
	assert_bool(prevision.alcance.por_casilla.values().has(3)).override_failure_message("sin casillas a 3 Zancadas").is_true()
	var inicio: int = Time.get_ticks_usec()
	for i in REPETICIONES:
		prevision = PrevisionTurno.new(_combate)
	var ms: float = (Time.get_ticks_usec() - inicio) / 1000.0 / REPETICIONES
	prints("Previsión completa:", "%.2f ms" % ms, "(%d casillas)" % prevision.alcance.por_casilla.size())
	assert_float(ms).is_less(MAXIMO_CALCULO_MS)


func test_la_consulta_del_cursor_es_instantanea() -> void:
	var prevision: PrevisionTurno = PrevisionTurno.new(_combate)
	var celdas: Array[Vector2i] = _libres(_combate.grilla())
	var inicio: int = Time.get_ticks_usec()
	for celda: Vector2i in celdas:
		prevision.vigente(_combate)
		prevision.costo(celda)
		prevision.camino(celda)
	var ms: float = (Time.get_ticks_usec() - inicio) / 1000.0 / celdas.size()
	prints("Consulta del cursor:", "%.4f ms" % ms)
	assert_float(ms).is_less(MAXIMO_CONSULTA_MS)


func test_un_cambio_de_estado_invalida_la_prevision() -> void:
	var prevision: PrevisionTurno = PrevisionTurno.new(_combate)
	assert_bool(prevision.vigente(_combate)).is_true()
	var enemigo: Combatiente = _combate.combatiente(&"pj0")
	enemigo.celda += Vector2i(1, 0)
	assert_bool(prevision.vigente(_combate)).is_false()
	enemigo.celda -= Vector2i(1, 0)
	_combate.turno_actual().gastar_acciones(1)
	assert_bool(prevision.vigente(_combate)).is_false()


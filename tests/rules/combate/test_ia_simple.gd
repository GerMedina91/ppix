extends GdUnitTestSuite

const DadosFijos: GDScript = preload("res://tests/utiles/dados_fijos.gd")
const CAC: String = "res://data/personajes/party_prueba_cuerpo_a_cuerpo.tres"
const DIST: String = "res://data/personajes/party_prueba_distancia.tres"
const ENEMIGO_CAC: String = "res://data/criaturas/enemigo_prueba_cuerpo_a_cuerpo.tres"
const ENEMIGO_DIST: String = "res://data/criaturas/enemigo_prueba_distancia.tres"


func _grilla(ancho: int = 20, alto: int = 10, paredes: Array[Vector2i] = []) -> GrillaMapa:
	var grilla: GrillaMapa = GrillaMapa.new(Rect2i(0, 0, ancho, alto))
	for x in ancho:
		for y in alto:
			grilla.set_transitable(Vector2i(x, y), not paredes.has(Vector2i(x, y)))
	return grilla


## El enemigo siempre empieza (iniciativa 20 contra 1). Después, dados con semilla fija.
func _combate(participantes: Array[Combatiente], grilla: GrillaMapa = _grilla()) -> Combate:
	var iniciativa: Array = []
	for c: Combatiente in participantes:
		iniciativa.append(20 if c.bando == Combatiente.Bando.ENEMIGOS else 1)
	var combate: Combate = Combate.new(participantes, grilla, _DadosMixtos.new(iniciativa))
	combate.iniciar()
	return combate


func _cuenta(eventos: Array[EventoCombate], tipo: EventoCombate.Tipo) -> int:
	return eventos.filter(func(e: EventoCombate) -> bool: return e.tipo == tipo).size()


func test_cuerpo_a_cuerpo_pegado_golpea_tres_veces() -> void:
	var pj: Combatiente = Combatiente.desde_personaje(&"pj", load(CAC), Vector2i(5, 5))
	pj.pg = 999
	var e: Combatiente = Combatiente.desde_criatura(&"e", load(ENEMIGO_CAC), Vector2i(6, 5))
	var combate: Combate = _combate([pj, e])
	var eventos: Array[EventoCombate] = IASimple.jugar_turno(combate)
	assert_int(_cuenta(eventos, EventoCombate.Tipo.GOLPE)).is_equal(3)
	assert_str(combate.turno_actual().id).is_equal("pj")


func test_cuerpo_a_cuerpo_lejos_se_acerca_y_golpea() -> void:
	var pj: Combatiente = Combatiente.desde_personaje(&"pj", load(CAC), Vector2i(2, 5))
	pj.pg = 999
	var e: Combatiente = Combatiente.desde_criatura(&"e", load(ENEMIGO_CAC), Vector2i(8, 5))
	var combate: Combate = _combate([pj, e])
	var eventos: Array[EventoCombate] = IASimple.jugar_turno(combate)
	assert_int(_cuenta(eventos, EventoCombate.Tipo.MOVIMIENTO)).is_equal(1)
	assert_int(_cuenta(eventos, EventoCombate.Tipo.GOLPE)).is_equal(2)
	assert_bool(Medicion.en_alcance(e.celda, pj.celda, 5)).is_true()


func test_si_no_llega_se_acerca_con_todas_las_acciones() -> void:
	var pj: Combatiente = Combatiente.desde_personaje(&"pj", load(CAC), Vector2i(0, 0))
	var e: Combatiente = Combatiente.desde_criatura(&"e", load(ENEMIGO_CAC), Vector2i(19, 0))
	var combate: Combate = _combate([pj, e])
	var eventos: Array[EventoCombate] = IASimple.jugar_turno(combate)
	assert_int(_cuenta(eventos, EventoCombate.Tipo.MOVIMIENTO)).is_equal(3)
	assert_int(e.celda.x).is_equal(19 - 15)


func test_a_distancia_con_linea_de_vision_dispara_sin_moverse() -> void:
	var pj: Combatiente = Combatiente.desde_personaje(&"pj", load(CAC), Vector2i(2, 5))
	pj.pg = 999
	var e: Combatiente = Combatiente.desde_criatura(&"e", load(ENEMIGO_DIST), Vector2i(10, 5))
	var combate: Combate = _combate([pj, e])
	var eventos: Array[EventoCombate] = IASimple.jugar_turno(combate)
	assert_int(_cuenta(eventos, EventoCombate.Tipo.MOVIMIENTO)).is_equal(0)
	assert_int(_cuenta(eventos, EventoCombate.Tipo.GOLPE)).is_equal(3)


func test_a_distancia_pegado_se_aleja_con_un_paso() -> void:
	var pj: Combatiente = Combatiente.desde_personaje(&"pj", load(CAC), Vector2i(5, 5))
	pj.pg = 999
	var e: Combatiente = Combatiente.desde_criatura(&"e", load(ENEMIGO_DIST), Vector2i(6, 5))
	var combate: Combate = _combate([pj, e])
	var eventos: Array[EventoCombate] = IASimple.jugar_turno(combate)
	assert_str(eventos[0].datos.get("tipo", "")).is_equal("paso")
	assert_bool(Medicion.en_alcance(e.celda, pj.celda, 5)).is_false()
	assert_int(_cuenta(eventos, EventoCombate.Tipo.GOLPE)).is_equal(2)


func test_sin_camino_termina_el_turno_sin_colgarse() -> void:
	# Pared completa entre los dos.
	var paredes: Array[Vector2i] = []
	for y in 10:
		paredes.append(Vector2i(10, y))
	var pj: Combatiente = Combatiente.desde_personaje(&"pj", load(CAC), Vector2i(2, 5))
	var e: Combatiente = Combatiente.desde_criatura(&"e", load(ENEMIGO_CAC), Vector2i(15, 5))
	var combate: Combate = _combate([pj, e], _grilla(20, 10, paredes))
	var eventos: Array[EventoCombate] = IASimple.jugar_turno(combate)
	assert_int(_cuenta(eventos, EventoCombate.Tipo.GOLPE)).is_equal(0)
	assert_str(combate.turno_actual().id).is_equal("pj")


func test_no_ataca_a_personajes_caidos() -> void:
	var caido: Combatiente = Combatiente.desde_personaje(&"caido", load(CAC), Vector2i(6, 5))
	var lejos: Combatiente = Combatiente.desde_personaje(&"lejos", load(CAC), Vector2i(12, 5))
	lejos.pg = 999
	var e: Combatiente = Combatiente.desde_criatura(&"e", load(ENEMIGO_CAC), Vector2i(5, 5))
	var combate: Combate = _combate([caido, lejos, e])
	caido.recibir_danio(caido.pg, false)
	var eventos: Array[EventoCombate] = IASimple.jugar_turno(combate)
	for evento: EventoCombate in eventos:
		if evento.tipo == EventoCombate.Tipo.GOLPE:
			assert_str(evento.datos.objetivo).is_equal("lejos")


func test_combate_completo_entre_ias_termina() -> void:
	for semilla: int in [1, 2, 3, 4, 5]:
		var participantes: Array[Combatiente] = [
			Combatiente.desde_personaje(&"a", load(CAC), Vector2i(2, 3)),
			Combatiente.desde_personaje(&"b", load(CAC), Vector2i(2, 5)),
			Combatiente.desde_personaje(&"c", load(DIST), Vector2i(0, 3)),
			Combatiente.desde_personaje(&"d", load(DIST), Vector2i(0, 5)),
			Combatiente.desde_criatura(&"e1", load(ENEMIGO_CAC), Vector2i(14, 4)),
			Combatiente.desde_criatura(&"e2", load(ENEMIGO_DIST), Vector2i(17, 4)),
		]
		var combate: Combate = Combate.new(participantes, _grilla(), Dados.new(semilla))
		combate.iniciar()
		var turnos: int = 0
		while combate.estado == Combate.Estado.EN_CURSO and turnos < 200:
			IASimple.jugar_turno(combate)
			turnos += 1
		assert_bool(combate.estado == Combate.Estado.VICTORIA or combate.estado == Combate.Estado.DERROTA) \
			.override_failure_message("semilla %d: no terminó en %d turnos" % [semilla, turnos]).is_true()


## Dados: primero los valores fijos (iniciativa) y después una secuencia con semilla.
class _DadosMixtos extends Dados:
	var _fijos: Array = []

	func _init(fijos: Array) -> void:
		super(12345)
		_fijos = fijos.duplicate()

	func tirar(caras: int) -> int:
		if not _fijos.is_empty():
			return _fijos.pop_front()
		return super(caras)


func test_con_remata_caidos_ataca_al_caido_mas_cercano() -> void:
	var caido: Combatiente = Combatiente.desde_personaje(&"caido", load(CAC), Vector2i(6, 5))
	var lejos: Combatiente = Combatiente.desde_personaje(&"lejos", load(CAC), Vector2i(12, 5))
	var criatura: DefinicionCriatura = load(ENEMIGO_CAC).duplicate()
	criatura.remata_caidos = true
	var e: Combatiente = Combatiente.desde_criatura(&"e", criatura, Vector2i(5, 5))
	var combate: Combate = _combate([caido, lejos, e])
	caido.recibir_danio(caido.pg, false)
	var eventos: Array[EventoCombate] = IASimple.jugar_turno(combate)
	var objetivos: Array = eventos.filter(func(ev: EventoCombate) -> bool: return ev.tipo == EventoCombate.Tipo.GOLPE) \
		.map(func(ev: EventoCombate) -> String: return ev.datos.objetivo)
	assert_array(objetivos).is_not_empty()
	assert_str(objetivos[0]).is_equal("caido")


func test_los_enemigos_de_prueba_no_rematan_caidos() -> void:
	assert_bool((load(ENEMIGO_CAC) as DefinicionCriatura).remata_caidos).is_false()
	assert_bool((load(ENEMIGO_DIST) as DefinicionCriatura).remata_caidos).is_false()

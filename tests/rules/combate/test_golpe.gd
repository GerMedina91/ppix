extends GdUnitTestSuite

const DadosFijos: GDScript = preload("res://tests/utiles/dados_fijos.gd")
const CAC: String = "res://data/personajes/party_prueba_cuerpo_a_cuerpo.tres"
const DIST: String = "res://data/personajes/party_prueba_distancia.tres"
const ENEMIGO: String = "res://data/criaturas/enemigo_prueba_cuerpo_a_cuerpo.tres"
const O: Vector2i = Vector2i(10, 10)

var _vision: LineaVision


func before_test() -> void:
	var grilla: GrillaMapa = GrillaMapa.new(Rect2i(0, 0, 100, 30))
	for x in 100:
		for y in 30:
			grilla.set_transitable(Vector2i(x, y), true)
	grilla.set_transitable(Vector2i(10, 20), false)  # una pared para probar línea de visión
	_vision = LineaVision.new(grilla)


func _pj(celda: Vector2i, ruta: String = CAC, id: StringName = &"pj") -> Combatiente:
	return Combatiente.desde_personaje(id, load(ruta), celda)


func _enemigo(celda: Vector2i = O) -> Combatiente:
	return Combatiente.desde_criatura(&"enemigo", load(ENEMIGO), celda)


func _golpe(atacante: Combatiente, objetivo: Combatiente, valores: Array, participantes: Array[Combatiente] = []) -> ResultadoGolpe:
	if participantes.is_empty():
		participantes = [atacante, objetivo]
	return Golpe.resolver(atacante, objetivo, atacante.arma_principal(), DadosFijos.new(valores), participantes, _vision)


func test_impacto_hace_danio_con_fuerza() -> void:
	# +7 al ataque contra CA 16: 10 + 7 = 17, éxito. Daño d8 (5) + Fuerza 4 = 9.
	var objetivo: Combatiente = _enemigo()
	var resultado: ResultadoGolpe = _golpe(_pj(O + Vector2i(-1, 0)), objetivo, [10, 5])
	assert_int(resultado.prueba.grado).is_equal(GradoExito.Grado.EXITO)
	assert_int(resultado.danio).is_equal(9)
	assert_int(objetivo.pg).is_equal(20 - 9)


func test_critico_duplica_el_danio() -> void:
	var objetivo: Combatiente = _enemigo()
	var resultado: ResultadoGolpe = _golpe(_pj(O + Vector2i(-1, 0)), objetivo, [19, 5])  # 26 contra 16
	assert_bool(resultado.critico).is_true()
	assert_int(resultado.danio).is_equal(18)


func test_fallo_no_hace_danio_y_no_tira_danio() -> void:
	var objetivo: Combatiente = _enemigo()
	var dados: Variant = DadosFijos.new([8, 5])
	var atacante: Combatiente = _pj(O + Vector2i(-1, 0))
	var resultado: ResultadoGolpe = Golpe.resolver(atacante, objetivo, atacante.arma_principal(), dados, [atacante, objetivo], _vision)
	assert_int(resultado.danio).is_equal(0)
	assert_int(objetivo.pg).is_equal(20)
	assert_int(dados.restantes()).is_equal(1)


func test_penalizador_por_ataque_multiple() -> void:
	var normal: DefinicionArma = DefinicionArma.new()
	var agil: DefinicionArma = DefinicionArma.new()
	agil.agil = true
	assert_array([0, 1, 2, 3].map(func(n: int) -> int: return Golpe.penalizador_ataque_multiple(normal, n))).is_equal([0, -5, -10, -10])
	assert_array([0, 1, 2, 3].map(func(n: int) -> int: return Golpe.penalizador_ataque_multiple(agil, n))).is_equal([0, -4, -8, -8])


func test_el_segundo_golpe_lleva_menos_5() -> void:
	var atacante: Combatiente = _pj(O + Vector2i(-1, 0))
	var objetivo: Combatiente = _enemigo()
	_golpe(atacante, objetivo, [2])  # primer ataque (falla)
	var segundo: ResultadoGolpe = _golpe(atacante, objetivo, [10])
	assert_int(segundo.prueba.total).is_equal(10 + 7 - 5)


func test_penalizador_por_incremento_de_rango() -> void:
	var arma: DefinicionArma = load(DIST).armas[0]  # incremento de 60 pies
	assert_int(Golpe.incrementos_extra(arma, 60)).is_equal(0)
	assert_int(Golpe.incrementos_extra(arma, 65)).is_equal(1)
	assert_int(Golpe.incrementos_extra(arma, 125)).is_equal(2)
	var atacante: Combatiente = _pj(O + Vector2i(13, 0), DIST)  # 65 pies
	var resultado: ResultadoGolpe = _golpe(atacante, _enemigo(), [10])
	assert_int(resultado.prueba.total).is_equal(10 + 7 - 2)


func test_fuera_de_alcance_no_ataca() -> void:
	var lejos_cac: ResultadoGolpe = _golpe(_pj(O + Vector2i(-2, 0)), _enemigo(), [10])
	assert_int(lejos_cac.motivo).is_equal(Golpe.Motivo.FUERA_DE_ALCANCE)
	var lejos_dist: ResultadoGolpe = _golpe(_pj(O + Vector2i(73, 0), DIST), _enemigo(), [10])  # 365 pies > 360
	assert_int(lejos_dist.motivo).is_equal(Golpe.Motivo.FUERA_DE_ALCANCE)


func test_sin_linea_de_vision_no_ataca() -> void:
	# Pared en (10,20) entre (10,17) y (10,23).
	var resultado: ResultadoGolpe = _golpe(_pj(Vector2i(10, 17), DIST), _enemigo(Vector2i(10, 23)), [10])
	assert_int(resultado.motivo).is_equal(Golpe.Motivo.SIN_LINEA_DE_VISION)


func test_no_se_ataca_a_un_aliado_ni_a_un_muerto() -> void:
	assert_int(_golpe(_pj(O), _pj(O + Vector2i(1, 0), CAC, &"otro"), [10]).motivo).is_equal(Golpe.Motivo.OBJETIVO_ALIADO)
	var muerto: Combatiente = _enemigo()
	muerto.condiciones.muerto = true
	assert_int(_golpe(_pj(O + Vector2i(-1, 0)), muerto, [10]).motivo).is_equal(Golpe.Motivo.OBJETIVO_MUERTO)


func test_flanqueo_baja_la_ca_solo_frente_a_los_que_flanquean() -> void:
	var a: Combatiente = _pj(O + Vector2i(-1, 0), CAC, &"a")
	var b: Combatiente = _pj(O + Vector2i(1, 0), CAC, &"b")
	var c: Combatiente = _pj(O + Vector2i(0, -1), CAC, &"c")  # tercer atacante, no flanquea
	var objetivo: Combatiente = _enemigo()
	var todos: Array[Combatiente] = [a, b, c, objetivo]
	var de_a: ResultadoGolpe = _golpe(a, objetivo, [2], todos)
	var de_c: ResultadoGolpe = _golpe(c, objetivo, [2], todos)
	assert_bool(de_a.flanqueando).is_true()
	assert_int(de_a.prueba.cd).is_equal(16 - 2)
	assert_bool(de_c.flanqueando).is_false()
	assert_int(de_c.prueba.cd).is_equal(16)


func test_danio_minimo_1_al_impactar() -> void:
	var criatura: DefinicionCriatura = load(ENEMIGO).duplicate()
	criatura.bonificador_danio = -10
	var atacante: Combatiente = Combatiente.desde_criatura(&"debil", criatura, O + Vector2i(-1, 0))
	var objetivo: Combatiente = _pj(O)
	var resultado: ResultadoGolpe = Golpe.resolver(atacante, objetivo, atacante.arma_principal(), DadosFijos.new([15, 1]), [atacante, objetivo], _vision)
	assert_bool(resultado.prueba.grado >= GradoExito.Grado.EXITO).is_true()
	assert_int(resultado.danio).is_equal(1)


func test_golpe_critico_que_tumba_a_un_personaje_da_moribundo_2() -> void:
	var objetivo: Combatiente = _pj(O)
	objetivo.pg = 3
	var atacante: Combatiente = _enemigo(O + Vector2i(1, 0))
	# +9 contra CA 18: 20 natural, crítico.
	Golpe.resolver(atacante, objetivo, atacante.arma_principal(), DadosFijos.new([20, 4]), [atacante, objetivo], _vision)
	assert_int(objetivo.condiciones.moribundo).is_equal(2)

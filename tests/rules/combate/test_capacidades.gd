extends GdUnitTestSuite
## Ataque furtivo y Destreza al daño del Ladrón con el pícaro del slice (Player Core, verificado en AoN).

const DadosFijos: GDScript = preload("res://tests/utiles/dados_fijos.gd")
const ENEMIGO: String = "res://data/criaturas/enemigo_prueba_cuerpo_a_cuerpo.tres"
const O: Vector2i = Vector2i(5, 5)

var _vision: LineaVision


func before_test() -> void:
	var grilla: GrillaMapa = GrillaMapa.new(Rect2i(0, 0, 20, 20))
	for x in 20:
		for y in 20:
			grilla.set_transitable(Vector2i(x, y), true)
	_vision = LineaVision.new(grilla)


func _picaro(celda: Vector2i, armas: Array[DefinicionArma] = []) -> Combatiente:
	var personaje: DefinicionPersonaje = ArmadorPersonaje.armar(load("res://data/builds/picaro.tres"))
	if not armas.is_empty():
		personaje.armas = armas
	return Combatiente.desde_personaje(&"picaro", personaje, celda)


func _guerrero(celda: Vector2i) -> Combatiente:
	return Combatiente.desde_personaje(&"guerrero", ArmadorPersonaje.armar(load("res://data/builds/guerrero.tres")), celda)


func _enemigo() -> Combatiente:
	var e: Combatiente = Combatiente.desde_criatura(&"e", load(ENEMIGO), O)
	e.pg = 999
	return e


func _golpe(atacante: Combatiente, objetivo: Combatiente, valores: Array, todos: Array[Combatiente]) -> ResultadoGolpe:
	return Golpe.resolver(atacante, objetivo, atacante.arma_principal(), DadosFijos.new(valores), todos, _vision)


func test_ladron_suma_destreza_al_danio_con_arma_sutil() -> void:
	var p: DefinicionPersonaje = ArmadorPersonaje.armar(load("res://data/builds/picaro.tres"))
	assert_int(Estadisticas.bonificador_danio(p, load("res://data/armas/estoque.tres"))).is_equal(4)
	# Con un arma que no es sutil vuelve a la Fuerza (+0).
	assert_int(Estadisticas.bonificador_danio(p, load("res://data/armas/espadon.tres"))).is_equal(0)


func test_ataque_furtivo_contra_un_objetivo_flanqueado() -> void:
	var picaro: Combatiente = _picaro(O + Vector2i(-1, 0))
	var guerrero: Combatiente = _guerrero(O + Vector2i(1, 0))
	var objetivo: Combatiente = _enemigo()
	# 15 + 7 = 22 contra CA 16 - 2: éxito. Estoque d6 (3) + Des 4 + furtivo d6 (5) = 12.
	var resultado: ResultadoGolpe = _golpe(picaro, objetivo, [15, 3, 5], [picaro, guerrero, objetivo])
	assert_bool(resultado.flanqueando).is_true()
	assert_int(resultado.danio_adicional.size()).is_equal(1)
	assert_int(resultado.danio).is_equal(12)


func test_sin_desprevenido_no_hay_ataque_furtivo() -> void:
	var picaro: Combatiente = _picaro(O + Vector2i(-1, 0))
	var objetivo: Combatiente = _enemigo()
	var resultado: ResultadoGolpe = _golpe(picaro, objetivo, [15, 3], [picaro, objetivo])
	assert_int(resultado.danio_adicional.size()).is_equal(0)
	assert_int(resultado.danio).is_equal(3 + 4)


func test_con_objetivo_desprevenido_por_su_condicion() -> void:
	var picaro: Combatiente = _picaro(O + Vector2i(-1, 0))
	var objetivo: Combatiente = _enemigo()
	objetivo.condiciones.desprevenido = true
	var resultado: ResultadoGolpe = _golpe(picaro, objetivo, [15, 3, 5], [picaro, objetivo])
	assert_int(resultado.danio).is_equal(3 + 4 + 5)


func test_arma_cuerpo_a_cuerpo_sin_agil_ni_sutil_no_califica() -> void:
	var picaro: Combatiente = _picaro(O + Vector2i(-1, 0), [load("res://data/armas/espadon.tres")])
	var guerrero: Combatiente = _guerrero(O + Vector2i(1, 0))
	var objetivo: Combatiente = _enemigo()
	var resultado: ResultadoGolpe = _golpe(picaro, objetivo, [18, 6], [picaro, guerrero, objetivo])
	assert_bool(resultado.flanqueando).is_true()
	assert_int(resultado.danio_adicional.size()).is_equal(0)


func test_el_critico_duplica_el_furtivo_y_el_letal_se_suma_despues() -> void:
	var picaro: Combatiente = _picaro(O + Vector2i(-1, 0))
	var guerrero: Combatiente = _guerrero(O + Vector2i(1, 0))
	var objetivo: Combatiente = _enemigo()
	# 20 natural. (d6 3 + Des 4 + furtivo 5) x 2 = 24, + letal d8 (6) = 30.
	var resultado: ResultadoGolpe = _golpe(picaro, objetivo, [20, 3, 5, 6], [picaro, guerrero, objetivo])
	assert_bool(resultado.critico).is_true()
	assert_int(resultado.danio).is_equal(30)


func test_el_guerrero_no_tiene_ataque_furtivo() -> void:
	var guerrero: Combatiente = _guerrero(O + Vector2i(-1, 0))
	var picaro: Combatiente = _picaro(O + Vector2i(1, 0))
	var objetivo: Combatiente = _enemigo()
	var resultado: ResultadoGolpe = _golpe(guerrero, objetivo, [15, 6], [guerrero, picaro, objetivo])
	assert_bool(resultado.flanqueando).is_true()
	assert_int(resultado.danio_adicional.size()).is_equal(0)


func test_el_registro_muestra_el_furtivo() -> void:
	var picaro: Combatiente = _picaro(O + Vector2i(-1, 0))
	var guerrero: Combatiente = _guerrero(O + Vector2i(1, 0))
	var objetivo: Combatiente = _enemigo()
	var resultado: ResultadoGolpe = _golpe(picaro, objetivo, [15, 3, 5], [picaro, guerrero, objetivo])
	var evento: EventoCombate = EventoCombate.new(EventoCombate.Tipo.GOLPE, &"picaro", {"objetivo": &"e", "resultado": resultado})
	assert_str(FormatoRegistro.texto(evento, null)).ends_with("12 de daño (+5 ataque furtivo)")

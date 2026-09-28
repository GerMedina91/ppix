extends GdUnitTestSuite
## Acción de miedo de la criatura de nivel 2 del combate final (construida con el GM Core; ver
## docs/verificacion/m5_criaturas.md): 1 acción, emanación de 30 pies, Voluntad CD 18; fallo asustado 1, fallo
## crítico asustado 2; inmune el resto del combate sea cual sea el resultado. La IA la usa antes de golpear.

const DadosFijos: GDScript = preload("res://tests/utiles/dados_fijos.gd")
const GUERRERO: String = "res://data/builds/guerrero.tres"
const CRIATURA: String = "res://data/criaturas/eco_fallido.tres"
const T: Dictionary = {"ESPECIAL": EventoCombate.Tipo.ACCION_ESPECIAL, "RESULTADO": EventoCombate.Tipo.RESULTADO_ESPECIAL,
	"INVALIDA": EventoCombate.Tipo.ACCION_INVALIDA, "GOLPE": EventoCombate.Tipo.GOLPE}


func _grilla() -> GrillaMapa:
	var grilla: GrillaMapa = GrillaMapa.new(Rect2i(0, 0, 20, 6))
	for x in 20:
		for y in 6:
			grilla.set_transitable(Vector2i(x, y), true)
	return grilla


## La criatura en (2,2) empieza (1 del guerrero contra 15) y el guerrero en `celda`.
func _combate(celda: Vector2i, dados: Array) -> Combate:
	var participantes: Array[Combatiente] = [Combatiente.desde_personaje(&"pj", ArmadorPersonaje.armar(load(GUERRERO)), celda),
		Combatiente.desde_criatura(&"c", load(CRIATURA), Vector2i(2, 2))]
	var combate: Combate = Combate.new(participantes, _grilla(), DadosFijos.new([1, 15] + dados))
	combate.iniciar()
	assert_str(combate.turno_actual().id).is_equal("c")
	return combate


func test_fallo_asustado_1() -> void:
	var combate: Combate = _combate(Vector2i(5, 2), [10])
	var eventos: Array[EventoCombate] = combate.especiales.accion_de_miedo()
	assert_array(eventos.map(func(e: EventoCombate) -> int: return e.tipo)).contains([T.ESPECIAL, T.RESULTADO])
	var guerrero: Combatiente = combate.combatiente(&"pj")
	assert_int(guerrero.condiciones.valor(Condiciones.Tipo.ASUSTADO)).is_equal(1)
	assert_int(combate.combatiente(&"c").acciones_restantes).is_equal(2)
	assert_str(FormatoRegistro.texto(eventos[1], combate)).contains("Voluntad")


func test_fallo_critico_asustado_2() -> void:
	var combate: Combate = _combate(Vector2i(5, 2), [1])
	combate.especiales.accion_de_miedo()
	assert_int(combate.combatiente(&"pj").condiciones.valor(Condiciones.Tipo.ASUSTADO)).is_equal(2)


func test_exito_nada_pero_queda_inmune() -> void:
	var combate: Combate = _combate(Vector2i(5, 2), [20])
	combate.especiales.accion_de_miedo()
	assert_int(combate.combatiente(&"pj").condiciones.valor(Condiciones.Tipo.ASUSTADO)).is_equal(0)
	assert_array(combate.especiales.objetivos_de_miedo(combate.turno_actual())).is_empty()
	var otra: Array[EventoCombate] = combate.especiales.accion_de_miedo()
	assert_int(otra.back().tipo).is_equal(T.INVALIDA)


func test_fuera_de_la_emanacion_no_afecta() -> void:
	# (2,2) a (9,2): 35 pies.
	var combate: Combate = _combate(Vector2i(9, 2), [])
	assert_array(combate.especiales.objetivos_de_miedo(combate.turno_actual())).is_empty()


func test_la_ia_asusta_antes_de_golpear() -> void:
	# Voluntad: 10 (fallo). Después golpea: 10 + 9 contra la CA del guerrero, 1d8.
	var combate: Combate = _combate(Vector2i(3, 2), [10, 10, 4, 10, 4, 10, 4])
	var primera: Array[EventoCombate] = IASimple.jugar_accion(combate)
	assert_int(primera[0].tipo).is_equal(T.ESPECIAL)
	var segunda: Array[EventoCombate] = IASimple.jugar_accion(combate)
	assert_int(segunda[0].tipo).is_equal(T.GOLPE)


func test_datos_de_la_criatura() -> void:
	var criatura: DefinicionCriatura = load(CRIATURA)
	assert_bool(criatura.inmune_mental).is_true()
	assert_int(criatura.nivel).is_equal(2)
	assert_array(criatura.errores_de_datos()).is_empty()
	var miedo: DefinicionAccionMiedo = criatura.accion_miedo
	assert_int(miedo.acciones).is_equal(1)
	assert_int(miedo.cd).is_equal(18)
	assert_int(miedo.emanacion_pies).is_equal(30)

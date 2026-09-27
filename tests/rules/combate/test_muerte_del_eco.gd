extends GdUnitTestSuite
## Muerte del Eco (GDD 4.3): termina el combate, el resultado para el mundo y el rearmado de la party.

const DadosFijos: GDScript = preload("res://tests/utiles/dados_fijos.gd")
const CAC: String = "res://data/personajes/party_prueba_cuerpo_a_cuerpo.tres"
const ENEMIGO: String = "res://data/criaturas/enemigo_prueba_cuerpo_a_cuerpo.tres"


func _grilla() -> GrillaMapa:
	var grilla: GrillaMapa = GrillaMapa.new(Rect2i(0, 0, 10, 6))
	for x in 10:
		for y in 6:
			grilla.set_transitable(Vector2i(x, y), true)
	return grilla


## Eco en (1,1), compañeros "a" y "b", enemigos "e1" y "e2". Ya iniciado.
func _combate() -> Combate:
	var eco: Combatiente = Combatiente.desde_personaje(&"eco", load(CAC), Vector2i(1, 1))
	eco.es_eco = true
	var participantes: Array[Combatiente] = [eco, Combatiente.desde_personaje(&"a", load(CAC), Vector2i(1, 3)),
		Combatiente.desde_personaje(&"b", load(CAC), Vector2i(1, 5)),
		Combatiente.desde_criatura(&"e1", load(ENEMIGO), Vector2i(8, 1)), Combatiente.desde_criatura(&"e2", load(ENEMIGO), Vector2i(8, 3))]
	var combate: Combate = Combate.new(participantes, _grilla(), DadosFijos.new([15, 14, 13, 2, 1]))
	combate.iniciar()
	return combate


func test_si_muere_el_eco_es_derrota_aunque_haya_compañeros_en_pie() -> void:
	var combate: Combate = _combate()
	combate.combatiente(&"eco").condiciones.muerto = true
	combate.verificar_fin()
	assert_int(combate.estado).is_equal(Combate.Estado.DERROTA)


func test_el_eco_caido_sin_morir_no_termina_el_combate() -> void:
	var combate: Combate = _combate()
	combate.combatiente(&"eco").recibir_danio(999, false)
	assert_bool(combate.combatiente(&"eco").condiciones.muerto).is_false()
	combate.verificar_fin()
	assert_int(combate.estado).is_equal(Combate.Estado.EN_CURSO)


func test_resultado_para_el_mundo() -> void:
	var combate: Combate = _combate()
	combate.combatiente(&"e1").condiciones.muerto = true
	combate.combatiente(&"e2").recibir_danio(999, false, true)  # no letal: inconsciente
	combate.combatiente(&"b").condiciones.muerto = true
	combate.combatiente(&"eco").celda = Vector2i(4, 2)
	combate.combatiente(&"eco").condiciones.muerto = true
	combate.verificar_fin()
	var r: ResultadoCombate = ResultadoCombate.desde(combate)
	assert_bool(r.victoria).is_false()
	assert_bool(r.muerte_del_eco).is_true()
	assert_that(r.celda_eco).is_equal(Vector2i(4, 2))
	assert_array(r.enemigos_muertos).contains_exactly([&"e1"])
	assert_array(r.enemigos_inconscientes).contains_exactly([&"e2"])
	assert_array(r.companeros_muertos).contains_exactly([&"b"])


func test_rearmado_moribundo_sobrevive_con_herido_mas_uno_y_los_muertos_siguen_muertos() -> void:
	var combate: Combate = _combate()
	var a: Combatiente = combate.combatiente(&"a")
	a.recibir_danio(999, false)  # moribundo 1
	a.condiciones.herido = 1
	combate.combatiente(&"b").condiciones.muerto = true
	combate.combatiente(&"eco").condiciones.herido = 2
	var estado: Dictionary[StringName, Dictionary] = Rearmado.estado_party(combate)
	assert_int(estado[&"a"].herido).is_equal(2)
	assert_int(estado[&"a"].pg).is_equal(a.pg_maximos())
	assert_bool(estado[&"b"].muerto).is_true()
	assert_bool(estado.has(&"eco")).is_false()  # el Eco se rearma entero


func test_al_ganar_el_inconsciente_estable_despierta_con_1_pg_y_su_herido() -> void:
	var combate: Combate = _combate()
	var a: Combatiente = combate.combatiente(&"a")
	a.recibir_danio(999, false)  # moribundo 1
	a.estabilizar()  # herido 1, inconsciente a 0 PG
	a.despertar_tras_el_combate()
	assert_int(a.pg).is_equal(1)
	assert_bool(a.condiciones.en_pie()).is_true()
	assert_int(a.condiciones.herido).is_equal(1)
	var b: Combatiente = combate.combatiente(&"b")
	b.condiciones.muerto = true
	b.pg = 0
	b.despertar_tras_el_combate()
	assert_bool(b.condiciones.muerto).is_true()
	assert_int(b.pg).is_equal(0)

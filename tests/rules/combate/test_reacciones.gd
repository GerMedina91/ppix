extends GdUnitTestSuite
## Reacciones: Golpe reactivo del guerrero y Esquiva ágil del pícaro (verificado en docs/verificacion/c3_reacciones.md).

const DadosFijos: GDScript = preload("res://tests/utiles/dados_fijos.gd")
const ENEMIGO_CAC: String = "res://data/criaturas/enemigo_prueba_cuerpo_a_cuerpo.tres"
const ENEMIGO_DIST: String = "res://data/criaturas/enemigo_prueba_distancia.tres"
const T: Dictionary = {
	"MOV": EventoCombate.Tipo.MOVIMIENTO, "GOLPE": EventoCombate.Tipo.GOLPE, "REACCION": EventoCombate.Tipo.REACCION,
	"PENDIENTE": EventoCombate.Tipo.REACCION_PENDIENTE, "INVALIDA": EventoCombate.Tipo.ACCION_INVALIDA,
}


func _grilla() -> GrillaMapa:
	var grilla: GrillaMapa = GrillaMapa.new(Rect2i(0, 0, 20, 10))
	for x in 20:
		for y in 10:
			grilla.set_transitable(Vector2i(x, y), true)
	return grilla


func _guerrero(celda: Vector2i) -> Combatiente:
	var g: Combatiente = Combatiente.desde_personaje(&"guerrero", ArmadorPersonaje.armar(load("res://data/builds/guerrero.tres")), celda)
	g.politica_reacciones = Combatiente.PoliticaReaccion.SIEMPRE
	return g


func _picaro(celda: Vector2i) -> Combatiente:
	var p: Combatiente = Combatiente.desde_personaje(&"picaro", ArmadorPersonaje.armar(load("res://data/builds/picaro.tres")), celda)
	p.politica_reacciones = Combatiente.PoliticaReaccion.SIEMPRE
	return p


func _enemigo(celda: Vector2i, ruta: String = ENEMIGO_CAC) -> Combatiente:
	var e: Combatiente = Combatiente.desde_criatura(&"e", load(ruta), celda)
	e.pg = 999
	return e


## El enemigo empieza (iniciativa 20 contra 1) y después los dados de la lista.
func _combate(participantes: Array[Combatiente], dados: Array) -> Combate:
	var iniciativa: Array = []
	for c: Combatiente in participantes:
		iniciativa.append(20 if c.bando == Combatiente.Bando.ENEMIGOS else 1)
	var combate: Combate = Combate.new(participantes, _grilla(), DadosFijos.new(iniciativa + dados))
	combate.iniciar()  # el guerrero todavía no tuvo turno: su reacción está disponible desde el inicio
	return combate


func _tipos(eventos: Array[EventoCombate]) -> Array:
	return eventos.map(func(e: EventoCombate) -> EventoCombate.Tipo: return e.tipo)


func test_salir_del_alcance_del_guerrero_dispara_el_golpe_reactivo() -> void:
	var guerrero: Combatiente = _guerrero(Vector2i(5, 5))
	var enemigo: Combatiente = _enemigo(Vector2i(6, 5))
	var combate: Combate = _combate([guerrero, enemigo], [2])  # el Golpe reactivo falla (2 + 9)
	var eventos: Array[EventoCombate] = combate.zancada(Vector2i(10, 5))
	assert_array(_tipos(eventos)).is_equal([T.REACCION, T.GOLPE, T.MOV])
	assert_bool(eventos[1].datos.reaccion).is_true()
	assert_bool(guerrero.reaccion_disponible).is_false()
	assert_that(enemigo.celda).is_equal(Vector2i(10, 5))


func test_el_paso_no_dispara_reacciones() -> void:
	var guerrero: Combatiente = _guerrero(Vector2i(5, 5))
	var enemigo: Combatiente = _enemigo(Vector2i(6, 5))
	var combate: Combate = _combate([guerrero, enemigo], [])
	assert_array(_tipos(combate.paso(Vector2i(7, 5)))).is_equal([T.MOV])
	assert_bool(guerrero.reaccion_disponible).is_true()


func test_una_zancada_que_entra_y_sale_del_alcance_dispara_al_salir() -> void:
	# El enemigo camina por la fila 3: (7,3) está fuera del alcance del guerrero en (5,4); al salir de (6,3), dentro.
	var guerrero: Combatiente = _guerrero(Vector2i(5, 4))
	var enemigo: Combatiente = _enemigo(Vector2i(8, 3))
	var combate: Combate = _combate([guerrero, enemigo], [2])
	var eventos: Array[EventoCombate] = combate.zancada(Vector2i(4, 3))
	assert_array(_tipos(eventos)).contains([T.REACCION, T.GOLPE])
	assert_int(_tipos(eventos).filter(func(t: int) -> bool: return t == T.MOV).size()).is_equal(2)
	assert_that(enemigo.celda).is_equal(Vector2i(4, 3))
	var primer_tramo: Array = eventos[0].datos.camino
	assert_bool(Medicion.en_alcance(guerrero.celda, primer_tramo.back(), 5)).is_true()


func test_el_golpe_reactivo_no_sufre_ni_suma_al_penalizador_por_ataque_multiple() -> void:
	var guerrero: Combatiente = _guerrero(Vector2i(5, 5))
	guerrero.ataques_en_turno = 2
	var enemigo: Combatiente = _enemigo(Vector2i(6, 5))
	var combate: Combate = _combate([guerrero, enemigo], [10, 6])
	var eventos: Array[EventoCombate] = combate.zancada(Vector2i(10, 5))
	var golpe: ResultadoGolpe = eventos[1].datos.resultado
	assert_int(golpe.prueba.total).is_equal(10 + 9)
	assert_int(guerrero.ataques_en_turno).is_equal(2)


func test_si_el_golpe_reactivo_lo_tumba_el_movimiento_se_corta() -> void:
	var guerrero: Combatiente = _guerrero(Vector2i(5, 5))
	var enemigo: Combatiente = _enemigo(Vector2i(6, 5))
	enemigo.pg = 3
	var combate: Combate = _combate([guerrero, enemigo, Combatiente.desde_criatura(&"e2", load(ENEMIGO_CAC), Vector2i(15, 8))], [15, 6])
	var eventos: Array[EventoCombate] = combate.zancada(Vector2i(10, 5))
	assert_bool(enemigo.condiciones.muerto).is_true()
	assert_that(enemigo.celda).is_equal(Vector2i(6, 5))
	assert_array(_tipos(eventos)).not_contains([T.MOV])


func test_una_sola_reaccion_por_asalto() -> void:
	var guerrero: Combatiente = _guerrero(Vector2i(5, 5))
	var enemigo: Combatiente = _enemigo(Vector2i(6, 5))
	var combate: Combate = _combate([guerrero, enemigo], [2])
	combate.zancada(Vector2i(4, 4))  # sale del alcance y vuelve a pasar cerca
	var segunda: Array[EventoCombate] = combate.zancada(Vector2i(10, 5))
	assert_array(_tipos(segunda)).not_contains([T.REACCION])


func test_ataque_a_distancia_al_alcance_dispara_antes_de_tirar() -> void:
	var guerrero: Combatiente = _guerrero(Vector2i(5, 5))
	var arquero: Combatiente = _enemigo(Vector2i(6, 5), ENEMIGO_DIST)
	var combate: Combate = _combate([guerrero, arquero], [2, 10, 3])
	var eventos: Array[EventoCombate] = combate.golpe(&"guerrero")
	assert_array(_tipos(eventos)).is_equal([T.REACCION, T.GOLPE, T.GOLPE])
	assert_str(eventos[1].actor).is_equal("guerrero")
	assert_str(eventos[2].actor).is_equal("e")


func test_si_el_golpe_reactivo_lo_tumba_el_ataque_a_distancia_se_pierde() -> void:
	var guerrero: Combatiente = _guerrero(Vector2i(5, 5))
	var arquero: Combatiente = _enemigo(Vector2i(6, 5), ENEMIGO_DIST)
	arquero.pg = 3
	var combate: Combate = _combate([guerrero, arquero, Combatiente.desde_criatura(&"e2", load(ENEMIGO_CAC), Vector2i(15, 8))], [15, 6])
	var eventos: Array[EventoCombate] = combate.golpe(&"guerrero")
	assert_bool(arquero.condiciones.muerto).is_true()
	var golpes_del_arquero: Array = eventos.filter(func(e: EventoCombate) -> bool: return e.tipo == T.GOLPE and e.actor == &"e")
	assert_array(golpes_del_arquero).is_empty()


func test_esquiva_agil_suma_2_a_la_ca_contra_ese_ataque() -> void:
	var picaro: Combatiente = _picaro(Vector2i(5, 5))
	var enemigo: Combatiente = _enemigo(Vector2i(6, 5))
	var ca_normal: int = picaro.defensa_contra(false).cd()
	var combate: Combate = _combate([picaro, enemigo], [10, 3])
	var eventos: Array[EventoCombate] = combate.golpe(&"picaro")
	assert_array(_tipos(eventos)).is_equal([T.REACCION, T.GOLPE])
	assert_int((eventos[1].datos.resultado as ResultadoGolpe).prueba.cd).is_equal(ca_normal + 2)
	assert_bool(picaro.reaccion_disponible).is_false()


func test_preguntar_detiene_el_combate_hasta_responder() -> void:
	var guerrero: Combatiente = _guerrero(Vector2i(5, 5))
	guerrero.politica_reacciones = Combatiente.PoliticaReaccion.PREGUNTAR
	var enemigo: Combatiente = _enemigo(Vector2i(6, 5))
	var combate: Combate = _combate([guerrero, enemigo], [2])
	var eventos: Array[EventoCombate] = combate.zancada(Vector2i(10, 5))
	assert_array(_tipos(eventos)).is_equal([T.PENDIENTE])
	assert_bool(combate.hay_reaccion_pendiente()).is_true()
	assert_that(enemigo.celda).is_equal(Vector2i(6, 5))
	# Mientras espera, no se puede hacer otra cosa.
	assert_array(_tipos(combate.golpe(&"guerrero"))).is_equal([T.INVALIDA])
	assert_array(combate.terminar_turno()).is_empty()
	var respuesta: Array[EventoCombate] = combate.responder_reaccion(true)
	assert_array(_tipos(respuesta)).is_equal([T.REACCION, T.GOLPE, T.MOV])
	assert_bool(combate.hay_reaccion_pendiente()).is_false()
	assert_that(enemigo.celda).is_equal(Vector2i(10, 5))


func test_responder_que_no_sigue_sin_usar_la_reaccion() -> void:
	var guerrero: Combatiente = _guerrero(Vector2i(5, 5))
	guerrero.politica_reacciones = Combatiente.PoliticaReaccion.PREGUNTAR
	var enemigo: Combatiente = _enemigo(Vector2i(6, 5))
	var combate: Combate = _combate([guerrero, enemigo], [])
	combate.zancada(Vector2i(10, 5))
	var respuesta: Array[EventoCombate] = combate.responder_reaccion(false)
	assert_array(_tipos(respuesta)).is_equal([T.MOV])
	assert_bool(guerrero.reaccion_disponible).is_true()
	assert_that(enemigo.celda).is_equal(Vector2i(10, 5))


func test_nunca_no_pregunta_ni_reacciona() -> void:
	var guerrero: Combatiente = _guerrero(Vector2i(5, 5))
	guerrero.politica_reacciones = Combatiente.PoliticaReaccion.NUNCA
	var enemigo: Combatiente = _enemigo(Vector2i(6, 5))
	var combate: Combate = _combate([guerrero, enemigo], [])
	assert_array(_tipos(combate.zancada(Vector2i(10, 5)))).is_equal([T.MOV])


func test_con_pausa_tras_reacciones_la_zancada_espera_a_continuar() -> void:
	var guerrero: Combatiente = _guerrero(Vector2i(5, 5))
	var enemigo: Combatiente = _enemigo(Vector2i(6, 5))
	var combate: Combate = _combate([guerrero, enemigo], [2])
	combate.pausar_tras_reacciones = true
	var eventos: Array[EventoCombate] = combate.zancada(Vector2i(10, 5))
	assert_array(_tipos(eventos)).is_equal([T.REACCION, T.GOLPE])
	assert_bool(combate.hay_continuacion()).is_true()
	assert_that(enemigo.celda).is_equal(Vector2i(6, 5))
	assert_array(_tipos(combate.golpe(&"guerrero"))).is_equal([T.INVALIDA])
	assert_array(_tipos(combate.continuar())).is_equal([T.MOV])
	assert_bool(combate.hay_continuacion()).is_false()
	assert_that(enemigo.celda).is_equal(Vector2i(10, 5))


func test_con_pausa_si_nadie_reacciona_no_hay_nada_que_continuar() -> void:
	var guerrero: Combatiente = _guerrero(Vector2i(5, 5))
	guerrero.politica_reacciones = Combatiente.PoliticaReaccion.NUNCA
	var enemigo: Combatiente = _enemigo(Vector2i(6, 5))
	var combate: Combate = _combate([guerrero, enemigo], [])
	combate.pausar_tras_reacciones = true
	assert_array(_tipos(combate.zancada(Vector2i(10, 5)))).is_equal([T.MOV])
	assert_bool(combate.hay_continuacion()).is_false()


func test_con_la_opcion_desactivada_nadie_reacciona_antes_de_su_primer_turno() -> void:
	var guerrero: Combatiente = _guerrero(Vector2i(5, 5))
	var enemigo: Combatiente = _enemigo(Vector2i(6, 5))
	var participantes: Array[Combatiente] = [guerrero, enemigo]
	var combate: Combate = Combate.new(participantes, _grilla(), DadosFijos.new([1, 20]))
	combate.reacciones_antes_del_primer_turno = false
	combate.iniciar()
	assert_array(_tipos(combate.zancada(Vector2i(10, 5)))).is_equal([T.MOV])

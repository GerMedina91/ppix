extends GdUnitTestSuite

const DadosFijos: GDScript = preload("res://tests/utiles/dados_fijos.gd")
const CAC: String = "res://data/personajes/party_prueba_cuerpo_a_cuerpo.tres"
const DIST: String = "res://data/personajes/party_prueba_distancia.tres"
const ENEMIGO: String = "res://data/criaturas/enemigo_prueba_cuerpo_a_cuerpo.tres"
const T: Dictionary = {
	"INICIO_TURNO": EventoCombate.Tipo.INICIO_TURNO, "MOVIMIENTO": EventoCombate.Tipo.MOVIMIENTO,
	"GOLPE": EventoCombate.Tipo.GOLPE, "INVALIDA": EventoCombate.Tipo.ACCION_INVALIDA,
	"MUERTE": EventoCombate.Tipo.MUERTE, "CAIDO": EventoCombate.Tipo.CAIDO,
	"FIN": EventoCombate.Tipo.FIN_COMBATE, "RECUPERACION": EventoCombate.Tipo.RECUPERACION,
	"PERDIDO": EventoCombate.Tipo.TURNO_PERDIDO, "RONDA": EventoCombate.Tipo.INICIO_RONDA,
}


func _grilla(ancho: int = 12, alto: int = 8) -> GrillaMapa:
	var grilla: GrillaMapa = GrillaMapa.new(Rect2i(0, 0, ancho, alto))
	for x in ancho:
		for y in alto:
			grilla.set_transitable(Vector2i(x, y), true)
	return grilla


func _pj(id: StringName, celda: Vector2i, ruta: String = CAC) -> Combatiente:
	return Combatiente.desde_personaje(id, load(ruta), celda)


func _enemigo(id: StringName, celda: Vector2i) -> Combatiente:
	return Combatiente.desde_criatura(id, load(ENEMIGO), celda)


func _tipos(eventos: Array[EventoCombate]) -> Array:
	return eventos.map(func(e: EventoCombate) -> EventoCombate.Tipo: return e.tipo)


## Combate de 1 contra 1 donde el personaje (Percepción +4) empieza (d20 15 contra 5 del enemigo, +6).
func _duelo(dados_extra: Array = []) -> Combate:
	var participantes: Array[Combatiente] = [_pj(&"pj", Vector2i(2, 2)), _enemigo(&"e", Vector2i(3, 2))]
	var combate: Combate = Combate.new(participantes, _grilla(), DadosFijos.new([15, 5] + dados_extra))
	combate.iniciar()
	return combate


func test_iniciativa_ordena_de_mayor_a_menor() -> void:
	var combate: Combate = _duelo()
	assert_array(combate.orden.map(func(c: Combatiente) -> StringName: return c.id)).is_equal([&"pj", &"e"])
	assert_str(combate.turno_actual().id).is_equal("pj")
	assert_int(combate.ronda).is_equal(1)


func test_empate_de_iniciativa_van_primero_los_enemigos() -> void:
	# Personaje Percepción +4, enemigo +6: 12 + 4 = 16 y 10 + 6 = 16.
	var participantes: Array[Combatiente] = [_pj(&"pj", Vector2i(2, 2)), _enemigo(&"e", Vector2i(5, 2))]
	var combate: Combate = Combate.new(participantes, _grilla(), DadosFijos.new([12, 10]))
	combate.iniciar()
	assert_str(combate.orden[0].id).is_equal("e")


func test_cada_accion_cuesta_una_y_hay_tres() -> void:
	var combate: Combate = _duelo([2, 2, 2])  # tres golpes que fallan
	for i in 3:
		assert_array(_tipos(combate.golpe(&"e"))).contains([T.GOLPE])
	assert_int(combate.turno_actual().acciones_restantes).is_equal(0)
	assert_array(_tipos(combate.golpe(&"e"))).is_equal([T.INVALIDA])


func test_zancada_mueve_y_respeta_la_velocidad() -> void:
	var combate: Combate = _duelo()
	var pj: Combatiente = combate.turno_actual()
	assert_array(_tipos(combate.zancada(Vector2i(2, 7)))).is_equal([T.MOVIMIENTO])  # 25 pies
	assert_that(pj.celda).is_equal(Vector2i(2, 7))
	assert_array(_tipos(combate.zancada(Vector2i(8, 7)))).is_equal([T.INVALIDA])    # 30 pies
	assert_int(pj.acciones_restantes).is_equal(2)


func test_zancada_no_atraviesa_enemigos() -> void:
	# Pasillo de una casilla: el enemigo bloquea el paso.
	var grilla: GrillaMapa = GrillaMapa.new(Rect2i(0, 0, 8, 1))
	for x in 8:
		grilla.set_transitable(Vector2i(x, 0), true)
	var participantes: Array[Combatiente] = [_pj(&"pj", Vector2i(0, 0)), _enemigo(&"e", Vector2i(2, 0))]
	var combate: Combate = Combate.new(participantes, grilla, DadosFijos.new([15, 5]))
	combate.iniciar()
	assert_bool(combate.casillas_de_zancada(combate.turno_actual()).has(Vector2i(4, 0))).is_false()
	assert_array(_tipos(combate.zancada(Vector2i(4, 0)))).is_equal([T.INVALIDA])


func test_zancada_atraviesa_aliados_pero_no_termina_ahi() -> void:
	var grilla: GrillaMapa = GrillaMapa.new(Rect2i(0, 0, 8, 1))
	for x in 8:
		grilla.set_transitable(Vector2i(x, 0), true)
	var participantes: Array[Combatiente] = [_pj(&"pj", Vector2i(0, 0)), _pj(&"aliado", Vector2i(1, 0)), _enemigo(&"e", Vector2i(7, 0))]
	var combate: Combate = Combate.new(participantes, grilla, DadosFijos.new([19, 1, 1]))
	combate.iniciar()
	assert_str(combate.turno_actual().id).is_equal("pj")
	assert_array(_tipos(combate.zancada(Vector2i(1, 0)))).is_equal([T.INVALIDA])
	assert_array(_tipos(combate.zancada(Vector2i(3, 0)))).is_equal([T.MOVIMIENTO])


func test_paso_solo_a_una_casilla_libre_adyacente() -> void:
	var combate: Combate = _duelo()
	assert_array(_tipos(combate.paso(Vector2i(3, 2)))).is_equal([T.INVALIDA])  # ocupada por el enemigo
	assert_array(_tipos(combate.paso(Vector2i(4, 4)))).is_equal([T.INVALIDA])  # no adyacente
	assert_array(_tipos(combate.paso(Vector2i(1, 1)))).is_equal([T.MOVIMIENTO])


func test_matar_al_ultimo_enemigo_da_victoria() -> void:
	var combate: Combate = _duelo([19, 8])  # crítico: (8 + 4) * 2 = 24 >= 20 PG
	var eventos: Array[EventoCombate] = combate.golpe(&"e")
	assert_array(_tipos(eventos)).is_equal([T.GOLPE, T.MUERTE, T.FIN])
	assert_int(combate.estado).is_equal(Combate.Estado.VICTORIA)
	assert_object(combate.turno_actual()).is_null()


func test_terminar_turno_pasa_al_siguiente_y_cambia_de_ronda() -> void:
	var combate: Combate = _duelo()
	assert_array(_tipos(combate.terminar_turno())).contains([T.INICIO_TURNO])
	assert_str(combate.turno_actual().id).is_equal("e")
	var eventos: Array[EventoCombate] = combate.terminar_turno()
	assert_array(_tipos(eventos)).contains([T.RONDA])
	assert_int(combate.ronda).is_equal(2)
	assert_str(combate.turno_actual().id).is_equal("pj")


func test_los_muertos_no_tienen_turno() -> void:
	var participantes: Array[Combatiente] = [_pj(&"pj", Vector2i(2, 2)), _enemigo(&"e1", Vector2i(3, 2)), _enemigo(&"e2", Vector2i(8, 2))]
	var combate: Combate = Combate.new(participantes, _grilla(), DadosFijos.new([19, 5, 1, 19, 8]))
	combate.iniciar()
	assert_array(combate.orden.map(func(c: Combatiente) -> StringName: return c.id)).is_equal([&"pj", &"e1", &"e2"])
	combate.golpe(&"e1")  # crítico, muere
	combate.terminar_turno()
	assert_str(combate.turno_actual().id).is_equal("e2")


func test_moribundo_hace_la_prueba_de_recuperacion_y_pierde_el_turno() -> void:
	var participantes: Array[Combatiente] = [_pj(&"pj", Vector2i(2, 2)), _pj(&"otro", Vector2i(6, 6)), _enemigo(&"e", Vector2i(3, 2))]
	# Iniciativa: pj 15+4, otro 1+4, e 10+6. Orden: pj, e, otro.
	var combate: Combate = Combate.new(participantes, _grilla(), DadosFijos.new([15, 1, 10, 15]))
	combate.iniciar()
	var pj: Combatiente = combate.combatiente(&"pj")
	pj.recibir_danio(pj.pg, false)  # moribundo 1
	combate.terminar_turno()          # turno de e
	var eventos: Array[EventoCombate] = combate.terminar_turno()  # turno de otro... y vuelve a pj
	eventos.append_array(combate.terminar_turno())
	assert_array(_tipos(eventos)).contains([T.RECUPERACION, T.PERDIDO])
	assert_int(pj.condiciones.moribundo).is_equal(0)  # 15 contra CD 11: éxito
	assert_str(combate.turno_actual().id).is_equal("e")


func test_toda_la_party_fuera_de_combate_da_derrota() -> void:
	# El enemigo empieza y tumba al personaje con un crítico.
	var participantes: Array[Combatiente] = [_pj(&"pj", Vector2i(2, 2)), _enemigo(&"e", Vector2i(3, 2))]
	var combate: Combate = Combate.new(participantes, _grilla(), DadosFijos.new([1, 19, 20, 6]))
	combate.iniciar()
	assert_str(combate.turno_actual().id).is_equal("e")
	combate.combatiente(&"pj").pg = 5
	var eventos: Array[EventoCombate] = combate.golpe(&"pj")
	assert_array(_tipos(eventos)).is_equal([T.GOLPE, T.CAIDO, T.FIN])
	assert_int(combate.estado).is_equal(Combate.Estado.DERROTA)


func test_misma_semilla_mismo_registro() -> void:
	assert_array(_simular(777)).is_equal(_simular(777))
	assert_array(_simular(777)).is_not_equal(_simular(778))


## Combate guionado: cada uno golpea hasta 3 veces por turno durante 6 turnos.
func _simular(semilla: int) -> Array[String]:
	var participantes: Array[Combatiente] = [
		_pj(&"a", Vector2i(2, 2)), _pj(&"b", Vector2i(4, 2)), _enemigo(&"e1", Vector2i(3, 2)), _enemigo(&"e2", Vector2i(3, 3))]
	var combate: Combate = Combate.new(participantes, _grilla(), Dados.new(semilla))
	combate.iniciar()
	for turno in 6:
		var actor: Combatiente = combate.turno_actual()
		if actor == null:
			break
		for i in 3:
			for otro: Combatiente in participantes:
				if not otro.es_aliado_de(actor) and not otro.condiciones.muerto and Medicion.en_alcance(actor.celda, otro.celda, 5):
					combate.golpe(otro.id)
					break
		combate.terminar_turno()
	var texto: Array[String] = []
	for evento: EventoCombate in combate.registro:
		texto.append("%s %s" % [EventoCombate.Tipo.keys()[evento.tipo], evento.actor])
	for c: Combatiente in participantes:
		texto.append("%s pg=%d" % [c.id, c.pg])
	return texto


func test_golpe_fuera_de_alcance_informa_el_motivo() -> void:
	var participantes: Array[Combatiente] = [_pj(&"pj", Vector2i(2, 2)), _enemigo(&"e", Vector2i(8, 2))]
	var combate: Combate = Combate.new(participantes, _grilla(), DadosFijos.new([15, 5]))
	combate.iniciar()
	var evento: EventoCombate = combate.golpe(&"e")[0]
	assert_int(evento.tipo).is_equal(T.INVALIDA)
	assert_int(evento.datos.motivo_golpe).is_equal(Golpe.Motivo.FUERA_DE_ALCANCE)
	assert_str(evento.datos.motivo).is_equal("fuera de alcance")
	assert_str(evento.datos.accion).is_equal("Golpe")
	assert_int(combate.turno_actual().acciones_restantes).is_equal(3)


func test_golpe_sin_linea_de_vision_informa_el_motivo() -> void:
	var grilla: GrillaMapa = _grilla()
	grilla.set_transitable(Vector2i(5, 2), false)
	var participantes: Array[Combatiente] = [_pj(&"pj", Vector2i(2, 2), DIST), _enemigo(&"e", Vector2i(8, 2))]
	var combate: Combate = Combate.new(participantes, grilla, DadosFijos.new([19, 1]))
	combate.iniciar()
	var evento: EventoCombate = combate.golpe(&"e")[0]
	assert_int(evento.datos.motivo_golpe).is_equal(Golpe.Motivo.SIN_LINEA_DE_VISION)


func test_golpe_sin_acciones_informa_el_motivo() -> void:
	var combate: Combate = _duelo([2, 2, 2])
	for i in 3:
		combate.golpe(&"e")
	var evento: EventoCombate = combate.golpe(&"e")[0]
	assert_int(evento.datos.motivo_golpe).is_equal(Golpe.Motivo.SIN_ACCIONES)
	assert_str(evento.datos.motivo).is_equal("sin acciones")


func test_zancada_imposible_informa_el_motivo() -> void:
	var combate: Combate = _duelo()
	var evento: EventoCombate = combate.zancada(Vector2i(11, 7))[0]
	assert_str(evento.datos.accion).is_equal("Zancada")
	assert_str(evento.datos.motivo).is_equal("fuera del alcance de la Zancada")
	assert_str(FormatoRegistro.texto(evento, combate)).is_equal("pj: Zancada imposible (fuera del alcance de la Zancada)")

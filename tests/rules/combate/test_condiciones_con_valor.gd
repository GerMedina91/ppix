extends GdUnitTestSuite
## Condiciones con valor (docs/verificacion/c4_conjuros.md): asustado, indispuesto, debilitado, aturdido
## y huyendo; duraciones, pisos, Arcadas y su lugar en el turno.

const DadosFijos: GDScript = preload("res://tests/utiles/dados_fijos.gd")
const CAC: String = "res://data/personajes/party_prueba_cuerpo_a_cuerpo.tres"
const DIST: String = "res://data/personajes/party_prueba_distancia.tres"
const ENEMIGO: String = "res://data/criaturas/enemigo_prueba_cuerpo_a_cuerpo.tres"
const A: Condiciones.Tipo = Condiciones.Tipo.ASUSTADO
const I: Condiciones.Tipo = Condiciones.Tipo.INDISPUESTO
const D: Condiciones.Tipo = Condiciones.Tipo.DEBILITADO
const AT: Condiciones.Tipo = Condiciones.Tipo.ATURDIDO
const H: Condiciones.Tipo = Condiciones.Tipo.HUYENDO


func _grilla(ancho: int = 12, alto: int = 8) -> GrillaMapa:
	var grilla: GrillaMapa = GrillaMapa.new(Rect2i(0, 0, ancho, alto))
	for x in ancho:
		for y in alto:
			grilla.set_transitable(Vector2i(x, y), true)
	return grilla


func _pj(id: StringName = &"pj", celda: Vector2i = Vector2i(2, 2), ruta: String = CAC) -> Combatiente:
	return Combatiente.desde_personaje(id, load(ruta), celda)


## Duelo en el que empieza el personaje (d20 15 contra 5).
func _duelo(dados_extra: Array = [], celda_enemigo: Vector2i = Vector2i(3, 2)) -> Combate:
	var participantes: Array[Combatiente] = [_pj(), Combatiente.desde_criatura(&"e", load(ENEMIGO), celda_enemigo)]
	var combate: Combate = Combate.new(participantes, _grilla(), DadosFijos.new([15, 5] + dados_extra))
	combate.iniciar()
	return combate


func _tipos(eventos: Array[EventoCombate]) -> Array:
	return eventos.map(func(e: EventoCombate) -> EventoCombate.Tipo: return e.tipo)


# --- Condiciones ---

func test_vale_el_valor_mas_alto_y_reducir_baja_todas_las_aplicaciones() -> void:
	var c: Condiciones = Condiciones.new()
	c.aplicar(EfectoCondicion.new(D, 1))
	c.aplicar(EfectoCondicion.new(D, 3))
	assert_int(c.valor(D)).is_equal(3)
	c.reducir(D, 1)
	assert_int(c.valor(D)).is_equal(2)  # la de 1 terminó, la de 3 quedó en 2
	c.reducir(D, 2)
	assert_bool(c.tiene(D)).is_false()


func test_quitar_saca_todas_las_aplicaciones() -> void:
	var c: Condiciones = Condiciones.new()
	c.aplicar(EfectoCondicion.new(A, 1))
	c.aplicar(EfectoCondicion.new(A, 2))
	c.quitar(A)
	assert_int(c.valor(A)).is_equal(0)


func test_el_piso_no_deja_bajar_la_condicion_mientras_dura() -> void:
	var c: Condiciones = Condiciones.new()
	c.aplicar(EfectoCondicion.new(I, 2))
	c.fijar_piso(I, &"mal_de_ojo", 1)
	c.reducir(I, 2)
	assert_int(c.valor(I)).is_equal(1)
	c.quitar_piso(I, &"mal_de_ojo")
	c.reducir(I, 1)
	assert_int(c.valor(I)).is_equal(0)


func test_la_duracion_corre_en_los_turnos_de_quien_la_causo() -> void:
	var c: Condiciones = Condiciones.new()
	c.aplicar(EfectoCondicion.new(D, 1).con_duracion(&"bruja", 1, true))   # hasta el inicio de su próximo turno
	c.aplicar(EfectoCondicion.new(D, 2).con_duracion(&"bruja", 10, true))  # 1 minuto
	c.descontar_turno(&"otro", true)
	c.descontar_turno(&"bruja", false)
	assert_int(c.valor(D)).is_equal(2)
	c.descontar_turno(&"bruja", true)
	assert_int(c.valor(D)).is_equal(2)
	for i in 9:
		c.descontar_turno(&"bruja", true)
	assert_bool(c.tiene(D)).is_false()


# --- Penalizadores ---

func test_asustado_resta_de_estatus_a_pruebas_y_cd_incluida_la_ca() -> void:
	var pj: Combatiente = _pj()
	var percepcion: int = pj.prueba_percepcion().modificador_total()
	var ca: int = pj.defensa_contra(false).cd()
	var fortaleza: int = pj.prueba_salvacion(Estadisticas.Salvacion.FORTALEZA).modificador_total()
	pj.condiciones.aplicar(EfectoCondicion.new(A, 2))
	assert_int(pj.prueba_percepcion().modificador_total()).is_equal(percepcion - 2)
	assert_int(pj.defensa_contra(false).cd()).is_equal(ca - 2)
	assert_int(pj.prueba_salvacion(Estadisticas.Salvacion.FORTALEZA).modificador_total()).is_equal(fortaleza - 2)


func test_penalizadores_de_estatus_no_se_suman_vale_el_peor() -> void:
	var pj: Combatiente = _pj()
	var percepcion: int = pj.prueba_percepcion().modificador_total()
	pj.condiciones.aplicar(EfectoCondicion.new(A, 2))
	pj.condiciones.aplicar(EfectoCondicion.new(I, 1))
	assert_int(pj.prueba_percepcion().modificador_total()).is_equal(percepcion - 2)


func test_debilitado_solo_afecta_lo_basado_en_fuerza() -> void:
	var cac: Combatiente = _pj()
	var dist: Combatiente = _pj(&"dist", Vector2i(0, 0), DIST)
	var arma_cac: DefinicionArma = cac.arma_principal()
	var arma_dist: DefinicionArma = dist.arma_principal()
	var antes: Array[int] = [cac.prueba_ataque(arma_cac).modificador_total(), cac.bonificador_danio(arma_cac),
		dist.prueba_ataque(arma_dist).modificador_total(), cac.prueba_habilidad(Habilidad.Tipo.ATLETISMO).modificador_total(),
		cac.prueba_habilidad(Habilidad.Tipo.ACROBACIAS).modificador_total(), cac.prueba_percepcion().modificador_total()]
	cac.condiciones.aplicar(EfectoCondicion.new(D, 2))
	dist.condiciones.aplicar(EfectoCondicion.new(D, 2))
	assert_int(cac.prueba_ataque(arma_cac).modificador_total()).is_equal(antes[0] - 2)
	assert_int(cac.bonificador_danio(arma_cac)).is_equal(antes[1] - 2)
	assert_int(dist.prueba_ataque(arma_dist).modificador_total()).is_equal(antes[2])
	assert_int(cac.prueba_habilidad(Habilidad.Tipo.ATLETISMO).modificador_total()).is_equal(antes[3] - 2)
	assert_int(cac.prueba_habilidad(Habilidad.Tipo.ACROBACIAS).modificador_total()).is_equal(antes[4])
	assert_int(cac.prueba_percepcion().modificador_total()).is_equal(antes[5])


func test_ataque_y_cd_de_conjuro_de_la_bruja_y_el_clerigo() -> void:
	# Atributo clave +4 y entrenado (nivel 1 + 2): ataque de conjuro +7, CD 17.
	for ruta: String in ["res://data/builds/bruja.tres", "res://data/builds/clerigo.tres"]:
		var c: Combatiente = Combatiente.desde_personaje(&"x", ArmadorPersonaje.armar(load(ruta)), Vector2i.ZERO)
		assert_int(c.prueba_conjuro().modificador_total()).override_failure_message(ruta).is_equal(7)
		assert_int(c.prueba_conjuro().cd()).is_equal(17)
		c.condiciones.aplicar(EfectoCondicion.new(A, 1))
		assert_int(c.prueba_conjuro().cd()).is_equal(16)


# --- En el turno ---

func test_asustado_baja_1_al_final_del_turno_propio() -> void:
	var combate: Combate = _duelo()
	var pj: Combatiente = combate.turno_actual()
	var e: Combatiente = combate.combatiente(&"e")
	pj.condiciones.aplicar(EfectoCondicion.new(A, 2))
	e.condiciones.aplicar(EfectoCondicion.new(A, 2))
	var eventos: Array[EventoCombate] = combate.terminar_turno()
	assert_int(pj.condiciones.valor(A)).is_equal(1)
	assert_int(e.condiciones.valor(A)).is_equal(2)  # el turno del enemigo recién empieza
	var cambio: EventoCombate = eventos[0]
	assert_int(cambio.tipo).is_equal(EventoCombate.Tipo.CONDICION)
	assert_dict(cambio.datos).is_equal({"condicion": A, "valor": 1, "anterior": 2})
	assert_int(eventos[1].tipo).is_equal(EventoCombate.Tipo.FIN_TURNO)


func test_aturdido_quita_acciones_al_empezar_el_turno() -> void:
	var combate: Combate = _duelo()
	var e: Combatiente = combate.combatiente(&"e")
	e.condiciones.aplicar(EfectoCondicion.new(AT, 1))
	assert_bool(e.condiciones.puede_actuar()).is_false()  # tampoco puede reaccionar
	var eventos: Array[EventoCombate] = combate.terminar_turno()
	assert_array(_tipos(eventos)).contains([EventoCombate.Tipo.ACCIONES_PERDIDAS])
	assert_str(combate.turno_actual().id).is_equal("e")
	assert_int(e.acciones_restantes).is_equal(2)
	assert_bool(e.condiciones.tiene(AT)).is_false()


func test_aturdido_4_pierde_el_turno_y_le_queda_1() -> void:
	var combate: Combate = _duelo()
	var e: Combatiente = combate.combatiente(&"e")
	e.condiciones.aplicar(EfectoCondicion.new(AT, 4))
	var eventos: Array[EventoCombate] = combate.terminar_turno()
	assert_array(_tipos(eventos)).contains([EventoCombate.Tipo.ACCIONES_PERDIDAS, EventoCombate.Tipo.TURNO_PERDIDO])
	assert_int(e.condiciones.valor(AT)).is_equal(1)
	assert_str(combate.turno_actual().id).is_equal("pj")


func test_debilitado_hasta_el_inicio_del_proximo_turno_de_quien_lo_causo() -> void:
	var combate: Combate = _duelo()
	var e: Combatiente = combate.combatiente(&"e")
	e.condiciones.aplicar(EfectoCondicion.new(D, 1).con_duracion(&"pj", 1, true))
	combate.terminar_turno()
	assert_int(e.condiciones.valor(D)).is_equal(1)  # sigue durante el turno del enemigo
	var eventos: Array[EventoCombate] = combate.terminar_turno()
	assert_bool(e.condiciones.tiene(D)).is_false()
	assert_array(_tipos(eventos)).contains([EventoCombate.Tipo.CONDICION])


# --- Arcadas ---

func test_arcadas_con_exito_baja_1_y_con_critico_baja_2() -> void:
	# Fortaleza del personaje +5. Contra CD 15: 12 = 17 éxito; 20 = 25 crítico; 2 = 7 fallo.
	for caso: Array in [[12, 3, 2], [20, 3, 1], [2, 3, 3]]:
		var combate: Combate = _duelo([caso[0]])
		var pj: Combatiente = combate.turno_actual()
		pj.condiciones.aplicar(EfectoCondicion.new(I, caso[1], 15))
		var eventos: Array[EventoCombate] = combate.arcadas()
		assert_array(_tipos(eventos)).is_equal([EventoCombate.Tipo.ARCADAS])
		assert_int(pj.condiciones.valor(I)).override_failure_message("d20 %d" % caso[0]).is_equal(caso[2])
		assert_int(pj.acciones_restantes).is_equal(2)


func test_arcadas_no_baja_del_piso_de_mal_de_ojo() -> void:
	var combate: Combate = _duelo([20])
	var pj: Combatiente = combate.turno_actual()
	pj.condiciones.aplicar(EfectoCondicion.new(I, 2, 15))
	pj.condiciones.fijar_piso(I, &"e", 1)
	combate.arcadas()
	assert_int(pj.condiciones.valor(I)).is_equal(1)


func test_arcadas_sin_indispuesto_es_imposible() -> void:
	var combate: Combate = _duelo()
	assert_array(_tipos(combate.arcadas())).is_equal([EventoCombate.Tipo.ACCION_INVALIDA])
	assert_int(combate.turno_actual().acciones_restantes).is_equal(3)


# --- Huyendo ---

func test_huyendo_solo_puede_alejarse_de_la_fuente() -> void:
	var combate: Combate = _duelo()
	var pj: Combatiente = combate.turno_actual()
	pj.condiciones.aplicar(EfectoCondicion.new(H, 1, 0, &"e"))
	assert_array(_tipos(combate.golpe(&"e"))).is_equal([EventoCombate.Tipo.ACCION_INVALIDA])
	assert_array(_tipos(combate.arcadas())).is_equal([EventoCombate.Tipo.ACCION_INVALIDA])
	assert_array(_tipos(combate.paso(Vector2i(3, 3)))).is_equal([EventoCombate.Tipo.ACCION_INVALIDA])  # igual de cerca
	assert_array(_tipos(combate.zancada(Vector2i(4, 3)))).is_equal([EventoCombate.Tipo.ACCION_INVALIDA])  # sigue a 5 pies
	assert_array(_tipos(combate.zancada(Vector2i(0, 2)))).is_equal([EventoCombate.Tipo.MOVIMIENTO])
	assert_int(pj.acciones_restantes).is_equal(2)


func test_la_prevision_de_huyendo_no_ofrece_golpes_ni_casillas_que_acerquen() -> void:
	var combate: Combate = _duelo()
	var pj: Combatiente = combate.turno_actual()
	var e: Combatiente = combate.combatiente(&"e")
	pj.condiciones.aplicar(EfectoCondicion.new(H, 1, 0, &"e"))
	var prevision: PrevisionTurno = PrevisionTurno.new(combate)
	assert_dict(prevision.golpeables as Dictionary).is_empty()
	assert_dict(prevision.por_casilla as Dictionary).is_not_empty()
	var inicial: int = Medicion.pies_entre(pj.celda, e.celda)
	for casilla: Vector2i in prevision.por_casilla:
		assert_int(Medicion.pies_entre(casilla, e.celda)).is_greater(inicial)
	assert_int(prevision.costo(e.celda)).is_equal(0)


func test_la_ia_huyendo_se_aleja_y_no_ataca() -> void:
	var combate: Combate = _duelo()
	combate.terminar_turno()
	var e: Combatiente = combate.combatiente(&"e")
	var pj: Combatiente = combate.combatiente(&"pj")
	e.condiciones.aplicar(EfectoCondicion.new(H, 1, 0, &"pj"))
	var antes: int = Medicion.pies_entre(e.celda, pj.celda)
	var eventos: Array[EventoCombate] = IASimple.jugar_accion(combate)
	assert_array(_tipos(eventos)).not_contains([EventoCombate.Tipo.GOLPE])
	assert_int(Medicion.pies_entre(e.celda, pj.celda)).is_greater(antes)

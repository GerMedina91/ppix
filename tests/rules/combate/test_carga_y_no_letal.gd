extends GdUnitTestSuite
## Carga repentina (guerrero; Player Core p. 141, floritura p. 139) y ataque no letal (Player Core p. 407).
## Guerrero: espadón +9 (1d12+4), Velocidad 25, Percepción +7. Enemigo de prueba: CA 16, 20 PG.

const DadosFijos: GDScript = preload("res://tests/utiles/dados_fijos.gd")
const GUERRERO: String = "res://data/builds/guerrero.tres"
const ENEMIGO: String = "res://data/criaturas/enemigo_prueba_cuerpo_a_cuerpo.tres"
const T: Dictionary = {"ESPECIAL": EventoCombate.Tipo.ACCION_ESPECIAL, "MOV": EventoCombate.Tipo.MOVIMIENTO,
	"GOLPE": EventoCombate.Tipo.GOLPE, "INVALIDA": EventoCombate.Tipo.ACCION_INVALIDA, "REACCION": EventoCombate.Tipo.REACCION}


func _grilla() -> GrillaMapa:
	var grilla: GrillaMapa = GrillaMapa.new(Rect2i(0, 0, 20, 8))
	for x in 20:
		for y in 8:
			grilla.set_transitable(Vector2i(x, y), true)
	return grilla


## Guerrero en (2,2) (empieza: d20 15 contra 5) y los que se pasen.
func _combate(otros: Array[Combatiente], dados_extra: Array = []) -> Combate:
	var participantes: Array[Combatiente] = [Combatiente.desde_personaje(&"g", ArmadorPersonaje.armar(load(GUERRERO)), Vector2i(2, 2))]
	participantes.append_array(otros)
	var iniciativa: Array = [15]
	for o in otros:
		iniciativa.append(1)
	var combate: Combate = Combate.new(participantes, _grilla(), DadosFijos.new(iniciativa + dados_extra))
	combate.iniciar()
	assert_str(combate.turno_actual().id).is_equal("g")
	return combate


func _enemigo(id: StringName, celda: Vector2i) -> Combatiente:
	return Combatiente.desde_criatura(id, load(ENEMIGO), celda)


func _tipos(eventos: Array[EventoCombate]) -> Array:
	return eventos.map(func(e: EventoCombate) -> EventoCombate.Tipo: return e.tipo)


# --- Carga repentina ---

func test_dos_zancadas_y_un_golpe() -> void:
	# Enemigo a 45 pies: hace falta llegar pegado a él, a 40 pies (dos Zancadas). Golpe: 10 + 9 = 19, espadón 5 + 4.
	var combate: Combate = _combate([_enemigo(&"e", Vector2i(11, 2))], [10, 5])
	var g: Combatiente = combate.turno_actual()
	var eventos: Array[EventoCombate] = combate.especiales.carga_repentina(&"e")
	assert_array(_tipos(eventos)).is_equal([T.ESPECIAL, T.MOV, T.MOV, T.GOLPE])
	assert_int(Medicion.pies_entre(g.celda, Vector2i(11, 2))).is_equal(5)
	assert_int(combate.combatiente(&"e").pg).is_equal(11)
	assert_int(g.acciones_restantes).is_equal(1)
	assert_int(g.ataques_en_turno).is_equal(1)
	assert_bool(g.floritura_en_turno).is_true()


func test_si_ya_lo_alcanza_golpea_sin_moverse() -> void:
	var combate: Combate = _combate([_enemigo(&"e", Vector2i(3, 2))], [2])
	assert_array(_tipos(combate.especiales.carga_repentina(&"e"))).is_equal([T.ESPECIAL, T.GOLPE])
	assert_that(combate.turno_actual().celda).is_equal(Vector2i(2, 2))


func test_no_llega_mas_alla_de_dos_zancadas() -> void:
	var combate: Combate = _combate([_enemigo(&"e", Vector2i(14, 2))])  # (13,2) queda a 55 pies
	var eventos: Array[EventoCombate] = combate.especiales.carga_repentina(&"e")
	assert_array(_tipos(eventos)).is_equal([T.INVALIDA])
	assert_str(eventos[0].datos.motivo).is_equal("no llega")
	assert_int(combate.turno_actual().acciones_restantes).is_equal(3)


func test_una_sola_floritura_por_turno() -> void:
	var combate: Combate = _combate([_enemigo(&"e", Vector2i(3, 2))], [2])
	combate.especiales.carga_repentina(&"e")
	combate.turno_actual().acciones_restantes = 3
	var eventos: Array[EventoCombate] = combate.especiales.carga_repentina(&"e")
	assert_str(eventos[0].datos.motivo).is_equal("ya usó una floritura este turno")
	combate.terminar_turno()
	combate.terminar_turno()
	assert_bool(combate.turno_actual().floritura_en_turno).is_false()


func test_un_golpe_reactivo_a_mitad_de_la_carga_no_la_corta_si_sigue_en_pie() -> void:
	# Un guerrero enemigo en (2,3) pega al salir de (2,2) y falla (2 + 9); la carga sigue y golpea.
	var reactor: Combatiente = Combatiente.new(&"r", FuentePersonaje.new(ArmadorPersonaje.armar(load(GUERRERO))), Combatiente.Bando.ENEMIGOS, Vector2i(2, 3))
	var combate: Combate = _combate([reactor, _enemigo(&"e", Vector2i(11, 2))], [2, 10, 5])
	var eventos: Array[EventoCombate] = combate.especiales.carga_repentina(&"e")
	assert_array(_tipos(eventos)).is_equal([T.ESPECIAL, T.REACCION, T.GOLPE, T.MOV, T.MOV, T.GOLPE])
	assert_int(combate.combatiente(&"e").pg).is_equal(11)


func test_con_pausa_tras_reacciones_la_carga_sigue_con_continuar() -> void:
	var reactor: Combatiente = Combatiente.new(&"r", FuentePersonaje.new(ArmadorPersonaje.armar(load(GUERRERO))), Combatiente.Bando.ENEMIGOS, Vector2i(2, 3))
	var combate: Combate = _combate([reactor, _enemigo(&"e", Vector2i(11, 2))], [2, 10, 5])
	combate.pausar_tras_reacciones = true
	assert_array(_tipos(combate.especiales.carga_repentina(&"e"))).is_equal([T.ESPECIAL, T.REACCION, T.GOLPE])
	assert_bool(combate.hay_continuacion()).is_true()
	assert_array(_tipos(combate.continuar())).is_equal([T.MOV, T.MOV, T.GOLPE])


# --- Ataque no letal ---

func test_el_ataque_no_letal_tiene_menos_2_y_deja_inconsciente() -> void:
	# 12 + 9 - 2 = 19 contra CA 16: acierta; 5 + 4 = 9 contra 3 PG → inconsciente, no muerto.
	var e: Combatiente = _enemigo(&"e", Vector2i(3, 2))
	var combate: Combate = _combate([e], [12, 5])
	e.pg = 3
	var eventos: Array[EventoCombate] = combate.golpe(&"e", null, true)
	var resultado: ResultadoGolpe = eventos[0].datos.resultado
	assert_int(resultado.prueba.total).is_equal(19)
	assert_bool(resultado.no_letal).is_true()
	assert_bool(e.condiciones.muerto).is_false()
	assert_bool(e.condiciones.inconsciente).is_true()
	assert_int(combate.estado).is_equal(Combate.Estado.VICTORIA)
	assert_str(FormatoRegistro.texto(eventos[0], combate)).contains("[no letal]")

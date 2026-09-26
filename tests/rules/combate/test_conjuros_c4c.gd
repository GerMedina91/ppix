extends GdUnitTestSuite
## Conjuros con daño y el resto de la lista del slice (c4_conjuros.md): Proyectil telequinético, Lanza
## divina, Aturdir (salvación básica, no letal), Miedo, Estabilizar; Esquiva ágil ante un ataque de conjuro.
## Bruja y clérigo: ataque de conjuro +7, CD 17. Enemigo de prueba: CA 16, 20 PG, Fortaleza +8, Voluntad +5.

const DadosFijos: GDScript = preload("res://tests/utiles/dados_fijos.gd")
const BRUJA: String = "res://data/builds/bruja.tres"
const CLERIGO: String = "res://data/builds/clerigo.tres"
const PICARO: String = "res://data/builds/picaro.tres"
const ENEMIGO: String = "res://data/criaturas/enemigo_prueba_cuerpo_a_cuerpo.tres"
const C: String = "res://data/conjuros/%s.tres"
const E: Dictionary = {"LANZA": EventoCombate.Tipo.LANZAMIENTO, "EFECTO": EventoCombate.Tipo.EFECTO_CONJURO,
	"INVALIDA": EventoCombate.Tipo.ACCION_INVALIDA, "FIN": EventoCombate.Tipo.FIN_COMBATE}


func _grilla() -> GrillaMapa:
	var grilla: GrillaMapa = GrillaMapa.new(Rect2i(0, 0, 16, 10))
	for x in 16:
		for y in 10:
			grilla.set_transitable(Vector2i(x, y), true)
	return grilla


func _personaje(id: StringName, build: String, celda: Vector2i) -> Combatiente:
	return Combatiente.desde_personaje(id, ArmadorPersonaje.armar(load(build)), celda)


## `build` en (2,2) empieza (d20 15 contra 5); el enemigo en (5,2).
func _combate(build: String, dados_extra: Array = []) -> Combate:
	var participantes: Array[Combatiente] = [_personaje(&"pj", build, Vector2i(2, 2)),
		Combatiente.desde_criatura(&"e", load(ENEMIGO), Vector2i(5, 2))]
	var combate: Combate = Combate.new(participantes, _grilla(), DadosFijos.new([15, 5] + dados_extra))
	combate.iniciar()
	return combate


func _efecto(eventos: Array[EventoCombate]) -> EventoCombate:
	for evento: EventoCombate in eventos:
		if evento.tipo == E.EFECTO:
			return evento
	return null


# --- Ataques de conjuro ---

func test_proyectil_telequinetico_segun_el_ataque() -> void:
	# +7 contra CA 16: 2 = 9 fallo; 10 = 17 éxito (2d6: 3 + 4 = 7); 19 = 26 crítico (7 × 2 = 14).
	for caso: Array in [[[2], 0], [[10, 3, 4], 7], [[19, 3, 4], 14]]:
		var combate: Combate = _combate(BRUJA, caso[0])
		var eventos: Array[EventoCombate] = combate.lanzar_conjuro(load(C % "proyectil_telequinetico"), &"e")
		assert_int(_efecto(eventos).datos.danio).override_failure_message(str(caso[0])).is_equal(caso[1])
		assert_int(combate.combatiente(&"e").pg).is_equal(20 - caso[1])
		assert_int(combate.turno_actual().ataques_en_turno).is_equal(1)


func test_el_ataque_de_conjuro_sufre_el_penalizador_por_ataque_multiple() -> void:
	var combate: Combate = _combate(BRUJA, [15, 1, 1])
	combate.turno_actual().ataques_en_turno = 1
	var resultado: ResultadoPrueba = _efecto(combate.lanzar_conjuro(load(C % "proyectil_telequinetico"), &"e")).datos.resultado
	assert_int(resultado.total).is_equal(15 + 7 - 5)  # 17 contra 16: acierta igual


func test_lanza_divina_llega_a_60_pies_con_dano_de_espiritu() -> void:
	var participantes: Array[Combatiente] = [_personaje(&"pj", CLERIGO, Vector2i(2, 2)),
		Combatiente.desde_criatura(&"e", load(ENEMIGO), Vector2i(14, 2))]  # 60 pies
	var combate: Combate = Combate.new(participantes, _grilla(), DadosFijos.new([15, 5, 12, 2, 3]))
	combate.iniciar()
	var efecto: EventoCombate = _efecto(combate.lanzar_conjuro(load(C % "lanza_divina"), &"e"))
	assert_int(efecto.datos.danio).is_equal(5)  # 2d4: 2 + 3
	assert_str(FormatoRegistro.texto(efecto, combate)).ends_with("5 de daño de espíritu")


func test_esquiva_agil_suma_a_la_ca_contra_un_ataque_de_conjuro() -> void:
	# El pícaro (CA 18) es aliado de la bruja: se puede elegir. 12 + 7 = 19: sin Esquiva acertaría; con +2 (CA 20), falla.
	var picaro: Combatiente = _personaje(&"picaro", PICARO, Vector2i(4, 2))
	picaro.politica_reacciones = Combatiente.PoliticaReaccion.SIEMPRE
	var participantes: Array[Combatiente] = [_personaje(&"pj", BRUJA, Vector2i(2, 2)), picaro,
		Combatiente.desde_criatura(&"e", load(ENEMIGO), Vector2i(12, 8))]
	var combate: Combate = Combate.new(participantes, _grilla(), DadosFijos.new([15, 1, 5, 12]))
	combate.iniciar()
	var eventos: Array[EventoCombate] = combate.lanzar_conjuro(load(C % "proyectil_telequinetico"), &"picaro")
	var resultado: ResultadoPrueba = _efecto(eventos).datos.resultado
	assert_int(resultado.cd).is_equal(20)
	assert_int(resultado.grado).is_equal(GradoExito.Grado.FALLO)


# --- Aturdir: salvación básica y no letal ---

func test_aturdir_con_salvacion_basica() -> void:
	# Voluntad +5 contra CD 17. 1d6 = 5: fallo crítico (2 = 7) doble y aturdido 1; fallo (8 = 13) 5;
	# éxito (15 = 20) mitad = 2; éxito crítico (20 natural: 25 éxito + 1 grado) nada.
	for caso: Array in [[[2, 5], 10, 1], [[8, 5], 5, 0], [[15, 5], 2, 0], [[20], 0, 0]]:
		var combate: Combate = _combate(BRUJA, caso[0])
		var efecto: EventoCombate = _efecto(combate.lanzar_conjuro(load(C % "aturdir"), &"e"))
		var e: Combatiente = combate.combatiente(&"e")
		assert_int(efecto.datos.danio).override_failure_message(str(caso[0])).is_equal(caso[1])
		assert_int(e.condiciones.valor(Condiciones.Tipo.ATURDIDO)).is_equal(caso[2])


func test_la_mitad_de_1_de_dano_sigue_siendo_1() -> void:
	var combate: Combate = _combate(BRUJA, [15, 1])
	assert_int(_efecto(combate.lanzar_conjuro(load(C % "aturdir"), &"e")).datos.danio).is_equal(1)


func test_aturdir_no_letal_noquea_y_cuenta_como_victoria() -> void:
	var combate: Combate = _combate(BRUJA, [8, 5])
	var e: Combatiente = combate.combatiente(&"e")
	e.pg = 3
	var eventos: Array[EventoCombate] = combate.lanzar_conjuro(load(C % "aturdir"), &"e")
	assert_bool(e.condiciones.muerto).is_false()
	assert_bool(e.condiciones.inconsciente).is_true()
	assert_int(eventos.back().tipo).is_equal(E.FIN)
	assert_int(combate.estado).is_equal(Combate.Estado.VICTORIA)


# --- Miedo ---

func test_miedo_segun_la_voluntad_y_huyendo_en_el_fallo_critico() -> void:
	# 15 = 20 éxito: asustado 1; 8 = 13 fallo: asustado 2; 2 = 7 fallo crítico: asustado 3 y huyendo.
	for caso: Array in [[15, 1, false], [8, 2, false], [2, 3, true]]:
		var combate: Combate = _combate(BRUJA, [caso[0]])
		combate.lanzar_conjuro(load(C % "miedo"), &"e")
		var e: Combatiente = combate.combatiente(&"e")
		assert_int(e.condiciones.valor(Condiciones.Tipo.ASUSTADO)).is_equal(caso[1])
		assert_bool(e.condiciones.tiene(Condiciones.Tipo.HUYENDO)).is_equal(caso[2])


func test_huyendo_de_miedo_dura_hasta_el_inicio_del_proximo_turno_de_la_bruja() -> void:
	var combate: Combate = _combate(BRUJA, [2])
	combate.lanzar_conjuro(load(C % "miedo"), &"e")
	var e: Combatiente = combate.combatiente(&"e")
	assert_object(ReglasCondiciones.fuente_de_huida(combate, e)).is_same(combate.combatiente(&"pj"))
	combate.terminar_turno()
	assert_bool(e.condiciones.tiene(Condiciones.Tipo.HUYENDO)).is_true()
	combate.terminar_turno()
	assert_bool(e.condiciones.tiene(Condiciones.Tipo.HUYENDO)).is_false()
	assert_int(e.condiciones.valor(Condiciones.Tipo.ASUSTADO)).is_equal(2)  # bajó 1 al final de su turno


# --- Estabilizar ---

func test_estabilizar_saca_de_moribundo_a_un_aliado() -> void:
	var caido: Combatiente = _personaje(&"caido", BRUJA, Vector2i(4, 4))
	var participantes: Array[Combatiente] = [_personaje(&"pj", CLERIGO, Vector2i(2, 2)), caido,
		Combatiente.desde_criatura(&"e", load(ENEMIGO), Vector2i(12, 8))]
	var combate: Combate = Combate.new(participantes, _grilla(), DadosFijos.new([15, 1, 5]))
	combate.iniciar()
	assert_array(combate.lanzar_conjuro(load(C % "estabilizar"), &"caido").map(func(x: EventoCombate) -> int: return x.tipo)) \
		.is_equal([E.INVALIDA])  # todavía no está moribundo
	caido.recibir_danio(caido.pg, false)
	assert_int(caido.condiciones.moribundo).is_equal(1)
	var efecto: EventoCombate = _efecto(combate.lanzar_conjuro(load(C % "estabilizar"), &"caido"))
	assert_str(FormatoRegistro.texto(efecto, combate)).is_equal("caido se estabiliza")
	assert_int(caido.condiciones.moribundo).is_equal(0)
	assert_int(caido.condiciones.herido).is_equal(1)
	assert_bool(caido.condiciones.inconsciente).is_true()


# --- Builds ---

func test_listas_de_conjuros_del_slice() -> void:
	var bruja: DefinicionPersonaje = ArmadorPersonaje.armar(load(BRUJA))
	var clerigo: DefinicionPersonaje = ArmadorPersonaje.armar(load(CLERIGO))
	assert_array(bruja.trucos.map(func(c: DefinicionConjuro) -> StringName: return c.id)) \
		.is_equal([&"proyectil_telequinetico", &"aturdir", &"mal_de_ojo"])
	assert_array(bruja.conjuros_preparados.map(func(c: DefinicionConjuro) -> StringName: return c.id)).is_equal([&"debilitar", &"miedo"])
	assert_array(clerigo.trucos.map(func(c: DefinicionConjuro) -> StringName: return c.id)).is_equal([&"lanza_divina", &"estabilizar"])
	assert_array(clerigo.conjuros_preparados.map(func(c: DefinicionConjuro) -> StringName: return c.id)).is_equal([&"miedo", &"miedo"])
	assert_array(ArmadorPersonaje.validar(load(BRUJA))).is_empty()
	assert_array(ArmadorPersonaje.validar(load(CLERIGO))).is_empty()

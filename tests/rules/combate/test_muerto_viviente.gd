extends GdUnitTestSuite
## Muerto viviente de prueba (base: Zombie Shambler, Monster Core p. 356): debilidad a cortante y vitalidad 5,
## inmune a lo mental, lento 1 permanente, destruido a 0 PG aunque el daño sea no letal. CA 12, 20 PG, Fort +6.

const DadosFijos: GDScript = preload("res://tests/utiles/dados_fijos.gd")
const MUERTO: String = "res://data/criaturas/muerto_viviente_prueba.tres"


func _grilla() -> GrillaMapa:
	var grilla: GrillaMapa = GrillaMapa.new(Rect2i(0, 0, 12, 6))
	for x in 12:
		for y in 6:
			grilla.set_transitable(Vector2i(x, y), true)
	return grilla


## El personaje del build en (2,2) empieza (15 contra 1); el muerto viviente en `celda`.
func _combate(build: String, celda: Vector2i, dados: Array) -> Combate:
	var participantes: Array[Combatiente] = [Combatiente.desde_personaje(&"pj", ArmadorPersonaje.armar(load("res://data/builds/%s.tres" % build)), Vector2i(2, 2)),
		Combatiente.desde_criatura(&"m", load(MUERTO), celda)]
	var combate: Combate = Combate.new(participantes, _grilla(), DadosFijos.new([15, 1] + dados))
	combate.iniciar()
	assert_str(combate.turno_actual().id).is_equal("pj")
	return combate


func test_el_golpe_cortante_suma_la_debilidad() -> void:
	# Espadón +9: 10 + 9 = 19 contra CA 12; 1d12 = 5 + 4 = 9, +5 de debilidad a cortante.
	var combate: Combate = _combate("guerrero", Vector2i(3, 2), [10, 5])
	var eventos: Array[EventoCombate] = combate.golpe(&"m")
	assert_int(combate.combatiente(&"m").pg).is_equal(6)
	assert_str(FormatoRegistro.texto(eventos[0], combate)).ends_with("14 de daño (+5 debilidad)")


func test_curar_le_hace_dano_de_vitalidad_con_la_debilidad() -> void:
	# Fortaleza +6 contra CD 17: 2 = 8, fallo: 1d8 = 6 completo, +5 de debilidad a vitalidad.
	var combate: Combate = _combate("clerigo", Vector2i(6, 2), [6, 2])
	combate.lanzar_conjuro(load("res://data/conjuros/curar.tres"), &"m", AccionesConjuro.SIN_CELDA, [], false, 2)
	assert_int(combate.combatiente(&"m").pg).is_equal(9)


func test_es_inmune_a_los_efectos_mentales() -> void:
	# Aturdir (mental): se lo puede elegir, pero no tiene efecto (ni daño ni aturdido).
	var combate: Combate = _combate("bruja", Vector2i(5, 2), [1, 6])
	var eventos: Array[EventoCombate] = combate.lanzar_conjuro(load("res://data/conjuros/aturdir.tres"), &"m")
	var fallido: Array[EventoCombate] = eventos.filter(func(e: EventoCombate) -> bool: return e.tipo == EventoCombate.Tipo.CONJURO_FALLIDO)
	assert_int(fallido.size()).is_equal(1)
	assert_str(FormatoRegistro.texto(fallido[0], combate)).is_equal("Aturdir de pj no tiene efecto (m es inmune a los efectos mentales)")
	assert_int(combate.combatiente(&"m").pg).is_equal(20)
	assert_int(combate.combatiente(&"m").condiciones.valor(Condiciones.Tipo.ATURDIDO)).is_equal(0)


func test_lento_empieza_cada_turno_con_una_accion_menos() -> void:
	var combate: Combate = _combate("guerrero", Vector2i(8, 2), [])
	combate.terminar_turno()
	assert_str(combate.turno_actual().id).is_equal("m")
	assert_int(combate.turno_actual().acciones_restantes).is_equal(2)


func test_el_dano_no_letal_lo_destruye_igual() -> void:
	var combate: Combate = _combate("guerrero", Vector2i(3, 2), [12, 5])
	combate.combatiente(&"m").pg = 3
	combate.golpe(&"m", null, true)
	assert_bool(combate.combatiente(&"m").condiciones.muerto).is_true()


func test_recordar_conocimiento_usa_religion() -> void:
	var combate: Combate = _combate("clerigo", Vector2i(5, 2), [15])
	var eventos: Array[EventoCombate] = combate.habilidades.recordar_conocimiento(&"m")
	assert_int(eventos[0].datos.habilidad).is_equal(Habilidad.Tipo.RELIGION)

extends GdUnitTestSuite
## Lista de acciones del jugador (conjuros, Sostener, Arcadas) y lo que hace el click con un conjuro elegido.

const DadosFijos: GDScript = preload("res://tests/utiles/dados_fijos.gd")
const ENEMIGO: String = "res://data/criaturas/enemigo_prueba_cuerpo_a_cuerpo.tres"


func _combate(build: String, dados_extra: Array = []) -> Combate:
	var grilla: GrillaMapa = GrillaMapa.new(Rect2i(0, 0, 14, 12))
	for x in 14:
		for y in 12:
			grilla.set_transitable(Vector2i(x, y), true)
	var pj: Combatiente = Combatiente.desde_personaje(&"pj", ArmadorPersonaje.armar(load(build)), Vector2i(2, 2))
	var participantes: Array[Combatiente] = [pj, Combatiente.desde_criatura(&"e", load(ENEMIGO), Vector2i(5, 2))]
	var combate: Combate = Combate.new(participantes, grilla, DadosFijos.new([15, 5] + dados_extra))
	combate.iniciar()
	return combate


func _textos(combate: Combate) -> Array:
	return ModoAccion.opciones(combate, combate.turno_actual()).map(func(o: Dictionary) -> String: return o.texto)


func test_la_bruja_ve_sus_conjuros_con_costo_y_espacios() -> void:
	var combate: Combate = _combate("res://data/builds/bruja.tres")
	assert_array(_textos(combate)).is_equal(["Proyectil telequinético ◆◆", "Aturdir ◆◆", "Mal de ojo ◆",
		"Debilitar ◆◆ (1)", "Miedo ◆◆ (1)"])


func test_despues_de_un_maleficio_no_se_ofrece_otro_y_aparecen_sostener_y_arcadas() -> void:
	var combate: Combate = _combate("res://data/builds/bruja.tres", [8])
	combate.lanzar_conjuro(load("res://data/conjuros/mal_de_ojo.tres"), &"e")
	assert_array(_textos(combate)).not_contains(["Mal de ojo ◆"])
	combate.terminar_turno()
	combate.terminar_turno()
	combate.turno_actual().condiciones.aplicar(EfectoCondicion.new(Condiciones.Tipo.INDISPUESTO, 1, 15))
	var textos: Array = _textos(combate)
	assert_array(textos).contains(["Mal de ojo ◆"])
	assert_array(textos.slice(-2)).is_equal(["Sostener Mal de ojo ◆", "Arcadas ◆"])


func test_elegir_un_conjuro_y_hacer_click_en_el_objetivo_lo_lanza() -> void:
	var combate: Combate = _combate("res://data/builds/bruja.tres", [8])
	var modo: ModoAccion = ModoAccion.new()
	var actor: Combatiente = combate.turno_actual()
	assert_bool(modo.elegir(combate, actor, 2).is_valid()).is_false()  # Mal de ojo
	assert_object(modo.elegido).is_not_null()
	assert_array(modo.objetivos(combate, actor)).contains([combate.combatiente(&"e")])
	var eventos: Array[EventoCombate] = modo.al_click(combate, actor, Vector2i(5, 2), false).call()
	assert_int(eventos[0].tipo).is_equal(EventoCombate.Tipo.LANZAMIENTO)
	assert_object(modo.elegido).is_null()


func test_pies_agiles_ofrece_su_zancada_con_5_pies_mas() -> void:
	var combate: Combate = _combate("res://data/builds/clerigo.tres")
	var modo: ModoAccion = ModoAccion.new()
	var actor: Combatiente = combate.turno_actual()
	modo.elegir(combate, actor, 3)  # Lanza divina, Estabilizar, Miedo, Pies ágiles
	var normal: Dictionary = combate.casillas_de_zancada(actor)
	assert_int(modo.casillas_movimiento.size()).is_greater(normal.size())
	assert_int(actor.bonificador_velocidad).is_equal(0)  # solo se usó para calcular


func test_sostener_y_arcadas_no_piden_objetivo() -> void:
	var combate: Combate = _combate("res://data/builds/bruja.tres")
	combate.turno_actual().condiciones.aplicar(EfectoCondicion.new(Condiciones.Tipo.INDISPUESTO, 1, 15))
	var modo: ModoAccion = ModoAccion.new()
	assert_bool(modo.elegir(combate, combate.turno_actual(), 5).is_valid()).is_true()  # Arcadas, al final
	assert_object(modo.elegido).is_null()

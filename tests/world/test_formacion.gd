extends GdUnitTestSuite


func _grilla(filas: Array[String]) -> GrillaMapa:
	var grilla: GrillaMapa = GrillaMapa.new(Rect2i(0, 0, filas[0].length(), filas.size()))
	for y in filas.size():
		for x in filas[y].length():
			grilla.set_transitable(Vector2i(x, y), filas[y][x] == ".")
	return grilla


func _es_cadena(celdas: Array[Vector2i], grilla: GrillaMapa) -> bool:
	for i in range(1, celdas.size()):
		if not grilla.puede_dar_paso(celdas[i - 1], celdas[i]):
			return false
	return celdas.size() == Dictionary(Array(celdas).reduce(func(d: Dictionary, c: Vector2i) -> Dictionary:
		d[c] = true
		return d, {})).size()


func test_en_campo_abierto_se_aleja_de_la_salida_en_linea() -> void:
	var grilla: GrillaMapa = _grilla(["........", "........", "........"])
	var celdas: Array[Vector2i] = Formacion.cadena(grilla, Vector2i(6, 1), 4, [Vector2i(7, 1)])
	assert_array(celdas).is_equal([Vector2i(6, 1), Vector2i(5, 1), Vector2i(4, 1), Vector2i(3, 1)])


func test_dobla_si_hay_pared_y_sigue_siendo_una_cadena() -> void:
	var grilla: GrillaMapa = _grilla(["#####", "#...#", "#...#", "#####"])
	var celdas: Array[Vector2i] = Formacion.cadena(grilla, Vector2i(1, 1), 4, [])
	assert_int(celdas.size()).is_equal(4)
	assert_bool(_es_cadena(celdas, grilla)).is_true()


func test_si_no_entran_todos_devuelve_las_que_pudo() -> void:
	var grilla: GrillaMapa = _grilla(["###", "#.#", "#.#", "###"])
	assert_int(Formacion.cadena(grilla, Vector2i(1, 1), 4, []).size()).is_equal(2)


func test_no_usa_casillas_a_evitar() -> void:
	var grilla: GrillaMapa = _grilla([".....", "....."])
	var celdas: Array[Vector2i] = Formacion.cadena(grilla, Vector2i(2, 0), 4, [Vector2i(1, 0), Vector2i(3, 0)])
	assert_array(celdas).not_contains([Vector2i(1, 0), Vector2i(3, 0)])
	assert_bool(_es_cadena(celdas, grilla)).is_true()


func test_la_party_entra_al_mapa_a_en_formacion() -> void:
	var runner: GdUnitSceneRunner = scene_runner("res://scenes/world/mundo.tscn")
	var party: ControlParty = runner.find_child("Party")
	var mapa: Mapa = runner.find_child("MapaActual").get_child(0)
	var celdas: Array[Vector2i] = []
	for m: MiembroParty in party.miembros():
		celdas.append(m.celda)
	assert_that(celdas[0]).is_equal(Vector2i(3, 5))
	assert_bool(_es_cadena(celdas, mapa.construir_grilla())).is_true()


func test_los_miembros_tienen_definicion_de_reglas() -> void:
	var runner: GdUnitSceneRunner = scene_runner("res://scenes/world/mundo.tscn")
	for m: MiembroParty in (runner.find_child("Party") as ControlParty).miembros():
		assert_object(m.definicion).is_not_null()

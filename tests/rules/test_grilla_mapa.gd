extends GdUnitTestSuite

## Arma una grilla desde ASCII: '#' pared, '.' suelo. La esquina superior izquierda es (0, 0).
func _grilla(filas: Array[String]) -> GrillaMapa:
	var grilla: GrillaMapa = GrillaMapa.new(Rect2i(0, 0, filas[0].length(), filas.size()))
	for y in filas.size():
		for x in filas[y].length():
			grilla.set_transitable(Vector2i(x, y), filas[y][x] == ".")
	return grilla


func test_celdas_nuevas_no_son_transitables() -> void:
	var grilla: GrillaMapa = GrillaMapa.new(Rect2i(0, 0, 3, 3))
	assert_bool(grilla.es_transitable(Vector2i(1, 1))).is_false()


func test_fuera_de_la_region_no_es_transitable() -> void:
	var grilla: GrillaMapa = _grilla(["...", "...", "..."])
	assert_bool(grilla.es_transitable(Vector2i(-1, 0))).is_false()
	assert_bool(grilla.es_transitable(Vector2i(3, 0))).is_false()


func test_camino_recto_no_incluye_el_origen() -> void:
	var grilla: GrillaMapa = _grilla(["....."])
	assert_array(grilla.camino(Vector2i(0, 0), Vector2i(3, 0))).is_equal(
		[Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)])


func test_camino_usa_diagonales_en_campo_abierto() -> void:
	var grilla: GrillaMapa = _grilla(["...", "...", "..."])
	assert_array(grilla.camino(Vector2i(0, 0), Vector2i(2, 2))).is_equal([Vector2i(1, 1), Vector2i(2, 2)])


func test_no_corta_esquinas() -> void:
	# Ir de (0,0) a (1,1) en diagonal cortaría la esquina de la pared en (1,0).
	var grilla: GrillaMapa = _grilla([".#", ".."])
	assert_array(grilla.camino(Vector2i(0, 0), Vector2i(1, 1))).is_equal([Vector2i(0, 1), Vector2i(1, 1)])


func test_no_pasa_entre_dos_paredes_en_diagonal() -> void:
	var grilla: GrillaMapa = _grilla([".#", "#."])
	assert_array(grilla.camino(Vector2i(0, 0), Vector2i(1, 1))).is_empty()


func test_rodea_obstaculos() -> void:
	var grilla: GrillaMapa = _grilla([
		".....",
		".###.",
		".....",
	])
	var camino: Array[Vector2i] = grilla.camino(Vector2i(0, 1), Vector2i(4, 1))
	assert_array(camino).is_not_empty()
	assert_array(camino).contains([Vector2i(4, 1)])
	for celda in camino:
		assert_bool(grilla.es_transitable(celda)).is_true()


func test_destino_no_transitable_da_camino_vacio() -> void:
	var grilla: GrillaMapa = _grilla(["..#"])
	assert_array(grilla.camino(Vector2i(0, 0), Vector2i(2, 0))).is_empty()


func test_destino_inalcanzable_da_camino_vacio() -> void:
	var grilla: GrillaMapa = _grilla([".#."])
	assert_array(grilla.camino(Vector2i(0, 0), Vector2i(2, 0))).is_empty()


func test_mismo_origen_y_destino_da_camino_vacio() -> void:
	var grilla: GrillaMapa = _grilla(["..."])
	assert_array(grilla.camino(Vector2i(1, 0), Vector2i(1, 0))).is_empty()


func test_puede_dar_paso_ortogonal_y_diagonal() -> void:
	var grilla: GrillaMapa = _grilla(["...", "...", "..."])
	assert_bool(grilla.puede_dar_paso(Vector2i(1, 1), Vector2i(2, 1))).is_true()
	assert_bool(grilla.puede_dar_paso(Vector2i(1, 1), Vector2i(2, 2))).is_true()


func test_puede_dar_paso_rechaza_celdas_no_vecinas_y_quedarse_quieto() -> void:
	var grilla: GrillaMapa = _grilla(["...", "...", "..."])
	assert_bool(grilla.puede_dar_paso(Vector2i(0, 0), Vector2i(2, 0))).is_false()
	assert_bool(grilla.puede_dar_paso(Vector2i(1, 1), Vector2i(1, 1))).is_false()


func test_puede_dar_paso_no_corta_esquinas() -> void:
	var grilla: GrillaMapa = _grilla([".#", ".."])
	assert_bool(grilla.puede_dar_paso(Vector2i(0, 0), Vector2i(1, 1))).is_false()
	assert_bool(grilla.puede_dar_paso(Vector2i(0, 0), Vector2i(0, 1))).is_true()


func test_puede_dar_paso_a_pared() -> void:
	var grilla: GrillaMapa = _grilla([".#"])
	assert_bool(grilla.puede_dar_paso(Vector2i(0, 0), Vector2i(1, 0))).is_false()

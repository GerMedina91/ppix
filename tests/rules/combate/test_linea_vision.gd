extends GdUnitTestSuite
## Línea de visión fiel a PF2e (decisión A): se puede apuntar si algún segmento desde tu casilla (centro o
## esquina) llega a la del objetivo (centro o esquina) sin pasar por pared; la recta central decide la cobertura.


## '#' pared, '.' suelo.
func _vision(filas: Array[String]) -> LineaVision:
	var grilla: GrillaMapa = GrillaMapa.new(Rect2i(0, 0, filas[0].length(), filas.size()))
	for y in filas.size():
		for x in filas[y].length():
			grilla.set_transitable(Vector2i(x, y), filas[y][x] == ".")
	return LineaVision.new(grilla)


func test_en_campo_abierto_hay_linea_y_la_recta_central_esta_libre() -> void:
	var vision: LineaVision = _vision([".....", ".....", "....."])
	assert_bool(vision.hay_linea(Vector2i(0, 0), Vector2i(4, 2))).is_true()
	assert_bool(vision.tapa_la_recta_central(Vector2i(0, 0), Vector2i(4, 2))).is_false()


func test_un_pilar_en_el_medio_no_bloquea_pero_tapa_la_recta_central() -> void:
	# Se ve por encima o por debajo del pilar; la recta central lo atraviesa: cobertura normal.
	var vision: LineaVision = _vision([".....", "..#..", "....."])
	assert_bool(vision.hay_linea(Vector2i(0, 1), Vector2i(4, 1))).is_true()
	assert_bool(vision.tapa_la_recta_central(Vector2i(0, 1), Vector2i(4, 1))).is_true()


func test_un_muro_entero_bloquea() -> void:
	var vision: LineaVision = _vision([".#.", ".#.", ".#."])
	assert_bool(vision.hay_linea(Vector2i(0, 1), Vector2i(2, 1))).is_false()
	assert_bool(vision.hay_linea(Vector2i(0, 0), Vector2i(2, 2))).is_false()


func test_asomarse_por_el_borde_de_un_muro_deja_ver() -> void:
	# El muro termina en la fila 1: desde (0,2) se ve (2,0) por la esquina de (1,1), con la recta central tapada.
	var vision: LineaVision = _vision(["...", ".#.", ".#."])
	assert_bool(vision.hay_linea(Vector2i(0, 2), Vector2i(2, 0))).is_true()
	assert_bool(vision.tapa_la_recta_central(Vector2i(0, 2), Vector2i(2, 0))).is_true()


func test_no_se_ve_entre_dos_paredes_que_se_tocan_en_diagonal() -> void:
	var vision: LineaVision = _vision([".#", "#."])
	assert_bool(vision.hay_linea(Vector2i(0, 0), Vector2i(1, 1))).is_false()


func test_no_se_ve_por_la_juntura_entre_dos_paredes() -> void:
	# Las paredes (0,1) y (1,1) comparten un borde: ningún segmento pasa por ahí.
	var vision: LineaVision = _vision(["..#", "###", "..#"])
	assert_bool(vision.hay_linea(Vector2i(0, 0), Vector2i(0, 2))).is_false()
	assert_bool(vision.hay_linea(Vector2i(1, 0), Vector2i(0, 2))).is_false()


func test_rozar_una_sola_esquina_deja_ver_sin_tapar_la_recta_central() -> void:
	var vision: LineaVision = _vision([".#", ".."])
	assert_bool(vision.hay_linea(Vector2i(0, 0), Vector2i(1, 1))).is_true()
	assert_bool(vision.tapa_la_recta_central(Vector2i(0, 0), Vector2i(1, 1))).is_false()


func test_casillas_adyacentes_siempre_se_ven() -> void:
	var vision: LineaVision = _vision(["###", "#.#", "###"])
	for d: Vector2i in [Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(0, -1)]:
		assert_bool(vision.hay_linea(Vector2i(1, 1), Vector2i(1, 1) + d)).is_true()


func test_casillas_atravesadas_de_la_recta_central() -> void:
	var vision: LineaVision = _vision([".....", ".....", "....."])
	assert_array(vision.casillas_atravesadas(Vector2i(0, 0), Vector2i(4, 0))).is_equal(
		[Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)])


func test_es_simetrica() -> void:
	var vision: LineaVision = _vision([
		"........",
		"..#.....",
		"....#...",
		".#......",
		"......#.",
	])
	for a: Vector2i in [Vector2i(0, 0), Vector2i(7, 4), Vector2i(3, 1), Vector2i(0, 4)]:
		for b: Vector2i in [Vector2i(7, 0), Vector2i(2, 4), Vector2i(5, 3), Vector2i(6, 1)]:
			assert_bool(vision.hay_linea(a, b)).override_failure_message("%s <-> %s" % [a, b]).is_equal(vision.hay_linea(b, a))
			assert_bool(vision.tapa_la_recta_central(a, b)).is_equal(vision.tapa_la_recta_central(b, a))

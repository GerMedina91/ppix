extends GdUnitTestSuite
## Posicionamiento previo: hasta 10 pies caminando, pisable, libre y no al lado de un enemigo.


## '#' pared, '.' suelo.
func _grilla(filas: Array[String]) -> GrillaMapa:
	var grilla: GrillaMapa = GrillaMapa.new(Rect2i(0, 0, filas[0].length(), filas.size()))
	for y in filas.size():
		for x in filas[y].length():
			grilla.set_transitable(Vector2i(x, y), filas[y][x] == ".")
	return grilla


func test_en_campo_abierto_llega_a_10_pies_con_la_regla_de_diagonales() -> void:
	var grilla: GrillaMapa = _grilla([".......", ".......", ".......", ".......", "......."])
	var casillas: Array[Vector2i] = Posicionamiento.casillas_posibles(grilla, Vector2i(3, 2), {}, [])
	assert_bool(casillas.has(Vector2i(5, 2))).is_true()   # 2 ortogonales = 10
	assert_bool(casillas.has(Vector2i(4, 4))).is_true()   # diagonal (5) + ortogonal (5) = 10
	assert_bool(casillas.has(Vector2i(5, 4))).is_false()  # 2 diagonales = 5 + 10 = 15
	assert_bool(casillas.has(Vector2i(6, 2))).is_false()  # 15 pies
	assert_bool(casillas.has(Vector2i(3, 2))).is_true()   # quedarse donde está


func test_no_atraviesa_paredes_ni_criaturas_ni_queda_al_lado_de_un_enemigo() -> void:
	var grilla: GrillaMapa = _grilla(["......", "..#...", "......"])
	var ocupadas: Dictionary[Vector2i, bool] = {Vector2i(1, 0): true}
	var casillas: Array[Vector2i] = Posicionamiento.casillas_posibles(grilla, Vector2i(1, 1), ocupadas, [Vector2i(5, 1)])
	assert_bool(casillas.has(Vector2i(2, 1))).is_false()  # pared
	assert_bool(casillas.has(Vector2i(1, 0))).is_false()  # ocupada
	assert_bool(casillas.has(Vector2i(3, 1))).is_false()  # detrás de la pared: son más de 10 pies caminando
	var junto: Array[Vector2i] = Posicionamiento.casillas_posibles(_grilla([".....", ".....", "....."]), Vector2i(1, 1), {}, [Vector2i(3, 1)])
	assert_bool(junto.has(Vector2i(2, 1))).is_false()  # al lado del enemigo
	assert_bool(junto.has(Vector2i(1, 1))).is_true()

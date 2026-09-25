extends GdUnitTestSuite

const SEGUNDOS: float = 0.2


func test_paso_ortogonal_dura_segundos_por_celda() -> void:
	for paso: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		assert_float(ControlParty.duracion_de_paso(Vector2i(5, 5), Vector2i(5, 5) + paso, SEGUNDOS)).is_equal_approx(SEGUNDOS, 0.0001)


func test_paso_diagonal_dura_raiz_de_dos_veces_mas() -> void:
	for paso: Vector2i in [Vector2i(1, 1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(-1, -1)]:
		assert_float(ControlParty.duracion_de_paso(Vector2i(5, 5), Vector2i(5, 5) + paso, SEGUNDOS)).is_equal_approx(SEGUNDOS * sqrt(2.0), 0.0001)

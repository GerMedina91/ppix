extends GdUnitTestSuite

const O: Vector2i = Vector2i(10, 10)


func test_distancias_con_diagonales_alternadas() -> void:
	# [desplazamiento, pies]
	for caso: Array in [
			[Vector2i(1, 0), 5], [Vector2i(0, -3), 15], [Vector2i(1, 1), 5], [Vector2i(2, 2), 15],
			[Vector2i(3, 3), 20], [Vector2i(4, 4), 30], [Vector2i(5, 5), 35], [Vector2i(2, 1), 10],
			[Vector2i(4, 1), 20], [Vector2i(-3, 2), 20]]:
		assert_int(Medicion.pies_entre(O, O + caso[0])).override_failure_message("%s" % caso[0]).is_equal(caso[1])


func test_alcance_de_5_pies_incluye_las_diagonales_adyacentes() -> void:
	for d: Vector2i in [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(-1, -1)]:
		assert_bool(Medicion.en_alcance(O, O + d, 5)).is_true()
	assert_bool(Medicion.en_alcance(O, O + Vector2i(2, 0), 5)).is_false()
	assert_bool(Medicion.en_alcance(O, O + Vector2i(2, 1), 5)).is_false()


func test_alcance_de_10_pies_llega_a_dos_casillas_en_diagonal() -> void:
	# Por la regla de diagonales (2,2) mide 15 pies, pero el alcance de 10 pies llega igual.
	assert_int(Medicion.pies_entre(O, O + Vector2i(2, 2))).is_equal(15)
	for d: Vector2i in [Vector2i(2, 2), Vector2i(-2, 2), Vector2i(2, -2), Vector2i(-2, -2)]:
		assert_bool(Medicion.en_alcance(O, O + d, 10)).override_failure_message("%s" % d).is_true()
	for d: Vector2i in [Vector2i(2, 0), Vector2i(2, 1), Vector2i(1, 1)]:
		assert_bool(Medicion.en_alcance(O, O + d, 10)).is_true()


func test_alcance_de_10_pies_no_se_extiende_mas_alla() -> void:
	for d: Vector2i in [Vector2i(3, 0), Vector2i(3, 3), Vector2i(3, 2), Vector2i(2, 3)]:
		assert_bool(Medicion.en_alcance(O, O + d, 10)).override_failure_message("%s" % d).is_false()


func test_la_excepcion_es_solo_para_10_pies() -> void:
	# Con 15 pies (2,2) entra por medición normal; con 5 pies no.
	assert_bool(Medicion.en_alcance(O, O + Vector2i(2, 2), 15)).is_true()
	assert_bool(Medicion.en_alcance(O, O + Vector2i(2, 2), 5)).is_false()


func test_la_misma_casilla_no_esta_en_alcance() -> void:
	assert_bool(Medicion.en_alcance(O, O, 5)).is_false()

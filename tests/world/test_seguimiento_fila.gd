extends GdUnitTestSuite


func test_cada_seguidor_va_a_la_celda_del_de_adelante() -> void:
	var antes: Array[Vector2i] = [Vector2i(4, 0), Vector2i(3, 0), Vector2i(2, 0), Vector2i(1, 0)]
	assert_array(SeguimientoFila.destinos(antes)).is_equal([Vector2i(4, 0), Vector2i(3, 0), Vector2i(2, 0)])


func test_party_apilada_se_despliega_de_a_uno() -> void:
	# Todos arrancan en la misma celda: solo el primer seguidor queda en la celda original
	# y los demás se quedan donde están hasta que el de adelante se mueva.
	var antes: Array[Vector2i] = [Vector2i(0, 0), Vector2i(0, 0), Vector2i(0, 0), Vector2i(0, 0)]
	assert_array(SeguimientoFila.destinos(antes)).is_equal([Vector2i(0, 0), Vector2i(0, 0), Vector2i(0, 0)])


func test_party_de_uno_no_tiene_seguidores() -> void:
	var antes: Array[Vector2i] = [Vector2i(2, 2)]
	assert_array(SeguimientoFila.destinos(antes)).is_empty()

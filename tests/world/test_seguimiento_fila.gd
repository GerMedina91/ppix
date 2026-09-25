extends GdUnitTestSuite


func _recorrido(seguimiento: SeguimientoFila) -> Array[Vector2i]:
	var celdas: Array[Vector2i] = []
	while seguimiento.tiene_pendientes():
		celdas.append(seguimiento.proxima())
	return celdas


func test_recorre_las_celdas_que_deja_el_de_adelante_en_orden() -> void:
	var seguimiento: SeguimientoFila = SeguimientoFila.new()
	seguimiento.registrar_salida(Vector2i(1, 0), Vector2i(0, 0))
	seguimiento.registrar_salida(Vector2i(2, 0), Vector2i(0, 0))
	seguimiento.registrar_salida(Vector2i(3, 1), Vector2i(0, 0))
	assert_array(_recorrido(seguimiento)).is_equal([Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 1)])


func test_no_agrega_la_celda_donde_ya_esta_el_seguidor() -> void:
	# Party apilada: el líder deja la celda donde también está el seguidor.
	var seguimiento: SeguimientoFila = SeguimientoFila.new()
	seguimiento.registrar_salida(Vector2i(0, 0), Vector2i(0, 0))
	assert_bool(seguimiento.tiene_pendientes()).is_false()


func test_no_duplica_la_ultima_celda_pendiente() -> void:
	var seguimiento: SeguimientoFila = SeguimientoFila.new()
	seguimiento.registrar_salida(Vector2i(1, 0), Vector2i(0, 0))
	seguimiento.registrar_salida(Vector2i(1, 0), Vector2i(0, 0))
	assert_array(_recorrido(seguimiento)).is_equal([Vector2i(1, 0)])


func test_limpiar_vacia_el_recorrido() -> void:
	var seguimiento: SeguimientoFila = SeguimientoFila.new()
	seguimiento.registrar_salida(Vector2i(1, 0), Vector2i(0, 0))
	seguimiento.limpiar()
	assert_bool(seguimiento.tiene_pendientes()).is_false()

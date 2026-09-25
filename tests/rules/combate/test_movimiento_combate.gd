extends GdUnitTestSuite


## Grilla desde ASCII: '#' pared, '.' suelo.
func _grilla(filas: Array[String]) -> GrillaMapa:
	var grilla: GrillaMapa = GrillaMapa.new(Rect2i(0, 0, filas[0].length(), filas.size()))
	for y in filas.size():
		for x in filas[y].length():
			grilla.set_transitable(Vector2i(x, y), filas[y][x] == ".")
	return grilla


func _abierta(tamano: int) -> GrillaMapa:
	var filas: Array[String] = []
	for i in tamano:
		filas.append(".".repeat(tamano))
	return _grilla(filas)


func test_en_linea_recta_llega_a_la_velocidad() -> void:
	var alcanzables: Dictionary = MovimientoCombate.new(_abierta(12)).alcanzables(Vector2i(0, 0), 25, {}, {})
	assert_int(alcanzables[Vector2i(5, 0)]).is_equal(25)
	assert_bool(alcanzables.has(Vector2i(6, 0))).is_false()
	assert_bool(alcanzables.has(Vector2i(0, 0))).is_false()


func test_diagonales_alternan_5_y_10() -> void:
	var alcanzables: Dictionary = MovimientoCombate.new(_abierta(12)).alcanzables(Vector2i(0, 0), 25, {}, {})
	assert_int(alcanzables[Vector2i(1, 1)]).is_equal(5)
	assert_int(alcanzables[Vector2i(2, 2)]).is_equal(15)
	assert_int(alcanzables[Vector2i(3, 3)]).is_equal(20)
	assert_int(alcanzables[Vector2i(4, 3)]).is_equal(25)
	assert_bool(alcanzables.has(Vector2i(4, 4))).is_false()  # 30 pies


func test_costo_de_un_camino_cuenta_la_alternancia_entera() -> void:
	# Diagonal, recta, diagonal: la segunda diagonal cuesta 10 aunque haya una recta en el medio.
	var casillas: Array[Vector2i] = [Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 2)]
	assert_int(MovimientoCombate.costo_de(Vector2i(0, 0), casillas)).is_equal(20)


func test_camino_es_el_mas_barato_y_su_costo_coincide() -> void:
	var movimiento: MovimientoCombate = MovimientoCombate.new(_abierta(12))
	var camino: Array[Vector2i] = movimiento.camino(Vector2i(0, 0), Vector2i(4, 3), {}, {})
	assert_that(camino.back()).is_equal(Vector2i(4, 3))
	assert_int(MovimientoCombate.costo_de(Vector2i(0, 0), camino)).is_equal(25)


func test_enemigos_bloquean_el_paso() -> void:
	# Pasillo de una casilla de ancho con un enemigo en el medio.
	var grilla: GrillaMapa = _grilla(["#######", "#.....#", "#######"])
	var enemigo: Dictionary = {Vector2i(3, 1): true}
	var alcanzables: Dictionary = MovimientoCombate.new(grilla).alcanzables(Vector2i(1, 1), 30, enemigo, {})
	assert_bool(alcanzables.has(Vector2i(2, 1))).is_true()
	assert_bool(alcanzables.has(Vector2i(3, 1))).is_false()
	assert_bool(alcanzables.has(Vector2i(4, 1))).is_false()


func test_aliados_se_atraviesan_pero_no_se_termina_ahi() -> void:
	var grilla: GrillaMapa = _grilla(["#######", "#.....#", "#######"])
	var aliado: Dictionary = {Vector2i(3, 1): true}
	var movimiento: MovimientoCombate = MovimientoCombate.new(grilla)
	var alcanzables: Dictionary = movimiento.alcanzables(Vector2i(1, 1), 30, {}, aliado)
	assert_bool(alcanzables.has(Vector2i(3, 1))).is_false()
	assert_int(alcanzables[Vector2i(4, 1)]).is_equal(15)
	assert_array(movimiento.camino(Vector2i(1, 1), Vector2i(3, 1), {}, aliado)).is_empty()
	assert_array(movimiento.camino(Vector2i(1, 1), Vector2i(5, 1), {}, aliado)).is_equal(
		[Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1), Vector2i(5, 1)])


func test_no_corta_esquinas_de_paredes() -> void:
	var grilla: GrillaMapa = _grilla([".#", ".."])
	var camino: Array[Vector2i] = MovimientoCombate.new(grilla).camino(Vector2i(0, 0), Vector2i(1, 1), {}, {})
	assert_array(camino).is_equal([Vector2i(0, 1), Vector2i(1, 1)])


func test_destino_inalcanzable_da_camino_vacio() -> void:
	var grilla: GrillaMapa = _grilla([".#."])
	assert_array(MovimientoCombate.new(grilla).camino(Vector2i(0, 0), Vector2i(2, 0), {}, {})).is_empty()


func test_alcance_por_zancadas_en_linea_recta() -> void:
	var alcance: Dictionary = MovimientoCombate.new(_abierta(20)).alcance_por_zancadas(Vector2i(0, 0), 25, 3, {}, {})
	assert_int(alcance[Vector2i(5, 0)]).is_equal(1)
	assert_int(alcance[Vector2i(6, 0)]).is_equal(2)
	assert_int(alcance[Vector2i(10, 0)]).is_equal(2)
	assert_int(alcance[Vector2i(15, 0)]).is_equal(3)
	assert_bool(alcance.has(Vector2i(16, 0))).is_false()


func test_la_alternancia_de_diagonales_empieza_de_nuevo_en_cada_zancada() -> void:
	# (4,4) mide 30 pies en un solo movimiento (no entra en una Zancada de 25) pero sí en dos:
	# (3,3) = 20 pies y después (1,1) = 5 pies, porque la segunda Zancada vuelve a empezar la alternancia.
	var alcance: Dictionary = MovimientoCombate.new(_abierta(20)).alcance_por_zancadas(Vector2i(0, 0), 25, 3, {}, {})
	assert_int(alcance[Vector2i(4, 4)]).is_equal(2)


func test_con_menos_acciones_llega_menos_lejos() -> void:
	var alcance: Dictionary = MovimientoCombate.new(_abierta(20)).alcance_por_zancadas(Vector2i(0, 0), 25, 2, {}, {})
	assert_bool(alcance.has(Vector2i(15, 0))).is_false()
	assert_int(alcance[Vector2i(10, 0)]).is_equal(2)


func test_plan_de_zancadas_encadena_movimientos_validos() -> void:
	var movimiento: MovimientoCombate = MovimientoCombate.new(_abierta(20))
	var plan: Array[Vector2i] = movimiento.plan_de_zancadas(Vector2i(0, 0), Vector2i(12, 3), 25, 3, {}, {})
	assert_int(plan.size()).is_equal(3)
	assert_that(plan.back()).is_equal(Vector2i(12, 3))
	var desde: Vector2i = Vector2i(0, 0)
	for fin: Vector2i in plan:
		var tramo: Array[Vector2i] = movimiento.camino(desde, fin, {}, {})
		assert_int(MovimientoCombate.costo_de(desde, tramo)).is_less_equal(25)
		desde = fin


func test_una_zancada_intermedia_no_termina_en_un_aliado() -> void:
	# Pasillo: el aliado ocupa justo el final de la primera Zancada posible (5,0); la primera termina antes.
	var grilla: GrillaMapa = _grilla(["............"])
	var aliado: Dictionary = {Vector2i(5, 0): true}
	var plan: Array[Vector2i] = MovimientoCombate.new(grilla).plan_de_zancadas(Vector2i(0, 0), Vector2i(9, 0), 25, 2, {}, aliado)
	assert_int(plan.size()).is_equal(2)
	assert_array(plan).not_contains([Vector2i(5, 0)])


func test_plan_imposible_da_vacio() -> void:
	var grilla: GrillaMapa = _grilla([".#."])
	assert_array(MovimientoCombate.new(grilla).plan_de_zancadas(Vector2i(0, 0), Vector2i(2, 0), 25, 3, {}, {})).is_empty()

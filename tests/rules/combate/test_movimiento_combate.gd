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


func test_alcance_de_zancadas_en_linea_recta() -> void:
	var alcance: Dictionary = MovimientoCombate.new(_abierta(20)).alcance_de_zancadas(Vector2i(0, 0), 25, 3, {}, {}).por_casilla
	assert_int(alcance[Vector2i(5, 0)]).is_equal(1)
	assert_int(alcance[Vector2i(6, 0)]).is_equal(2)
	assert_int(alcance[Vector2i(10, 0)]).is_equal(2)
	assert_int(alcance[Vector2i(15, 0)]).is_equal(3)
	assert_bool(alcance.has(Vector2i(16, 0))).is_false()


func test_la_alternancia_de_diagonales_empieza_de_nuevo_en_cada_zancada() -> void:
	# (4,4) mide 30 pies en un solo movimiento (no entra en una Zancada de 25) pero sí en dos:
	# (3,3) = 20 pies y después (1,1) = 5 pies, porque la segunda Zancada vuelve a empezar la alternancia.
	var alcance: Dictionary = MovimientoCombate.new(_abierta(20)).alcance_de_zancadas(Vector2i(0, 0), 25, 3, {}, {}).por_casilla
	assert_int(alcance[Vector2i(4, 4)]).is_equal(2)


func test_con_menos_acciones_llega_menos_lejos() -> void:
	var alcance: Dictionary = MovimientoCombate.new(_abierta(20)).alcance_de_zancadas(Vector2i(0, 0), 25, 2, {}, {}).por_casilla
	assert_bool(alcance.has(Vector2i(15, 0))).is_false()
	assert_int(alcance[Vector2i(10, 0)]).is_equal(2)


func test_plan_de_zancadas_encadena_movimientos_validos() -> void:
	var movimiento: MovimientoCombate = MovimientoCombate.new(_abierta(20))
	var plan: Array[Vector2i] = movimiento.alcance_de_zancadas(Vector2i(0, 0), 25, 3, {}, {}).plan(Vector2i(12, 3))
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
	var plan: Array[Vector2i] = MovimientoCombate.new(grilla).alcance_de_zancadas(Vector2i(0, 0), 25, 2, {}, aliado).plan(Vector2i(9, 0))
	assert_int(plan.size()).is_equal(2)
	assert_array(plan).not_contains([Vector2i(5, 0)])


func test_plan_imposible_da_vacio() -> void:
	var grilla: GrillaMapa = _grilla([".#."])
	assert_array(MovimientoCombate.new(grilla).alcance_de_zancadas(Vector2i(0, 0), 25, 3, {}, {}).plan(Vector2i(2, 0))).is_empty()


## El algoritmo de antes (una búsqueda de una Zancada desde cada casilla de la frontera), como referencia.
func _alcance_de_referencia(movimiento: MovimientoCombate, origen: Vector2i, velocidad: int, zancadas_max: int,
		bloqueadas: Dictionary, de_aliados: Dictionary) -> Dictionary:
	var zancadas: Dictionary = {}
	var frontera: Array[Vector2i] = [origen]
	for n in range(1, zancadas_max + 1):
		var nueva: Array[Vector2i] = []
		for inicio: Vector2i in frontera:
			for casilla: Vector2i in movimiento.alcanzables(inicio, velocidad, bloqueadas, de_aliados):
				if casilla != origen and not zancadas.has(casilla):
					zancadas[casilla] = n
					nueva.append(casilla)
		frontera = nueva
	return zancadas


func test_la_busqueda_multi_origen_da_lo_mismo_que_una_busqueda_por_casilla() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 7
	for caso in 12:
		var filas: Array[String] = []
		for y in 16:
			var fila: String = ""
			for x in 16:
				fila += "#" if rng.randf() < 0.2 else "."
			filas.append(fila)
		var grilla: GrillaMapa = _grilla(filas)
		var origen: Vector2i = Vector2i(8, 8)
		grilla.set_transitable(origen, true)
		var bloqueadas: Dictionary = {}
		var aliados: Dictionary = {}
		for i in 4:
			bloqueadas[Vector2i(rng.randi_range(0, 15), rng.randi_range(0, 15))] = true
			aliados[Vector2i(rng.randi_range(0, 15), rng.randi_range(0, 15))] = true
		bloqueadas.erase(origen)
		aliados.erase(origen)
		var movimiento: MovimientoCombate = MovimientoCombate.new(grilla)
		var alcance: AlcanceZancadas = movimiento.alcance_de_zancadas(origen, 25, 3, bloqueadas, aliados)
		assert_dict(alcance.por_casilla as Dictionary).override_failure_message("caso %d" % caso) \
			.is_equal(_alcance_de_referencia(movimiento, origen, 25, 3, bloqueadas, aliados))
		_verificar_tramos(movimiento, alcance, 25, bloqueadas, aliados)


## Cada tramo es una Zancada válida que empieza donde terminó la anterior y cabe en la velocidad.
func _verificar_tramos(movimiento: MovimientoCombate, alcance: AlcanceZancadas, velocidad: int,
		bloqueadas: Dictionary, aliados: Dictionary) -> void:
	for destino: Vector2i in alcance.por_casilla:
		var tramos: Array[Array] = alcance.tramos(destino)
		assert_int(tramos.size()).is_equal(alcance.por_casilla[destino])
		var desde: Vector2i = alcance.origen
		for t: Array in tramos:
			var tramo: Array[Vector2i] = []
			tramo.assign(t)
			assert_bool(movimiento.es_camino_valido(desde, tramo, bloqueadas, aliados)).is_true()
			assert_int(MovimientoCombate.costo_de(desde, tramo)).is_less_equal(velocidad)
			desde = tramo.back()
		assert_that(desde).is_equal(destino)


func test_es_camino_valido_rechaza_saltos_esquinas_y_oponentes() -> void:
	var grilla: GrillaMapa = _grilla([".#.", "...", "..."])
	var movimiento: MovimientoCombate = MovimientoCombate.new(grilla)
	var ok: Array[Vector2i] = [Vector2i(0, 1), Vector2i(1, 2)]
	var salto: Array[Vector2i] = [Vector2i(2, 2)]
	var esquina: Array[Vector2i] = [Vector2i(1, 1), Vector2i(2, 0)]
	assert_bool(movimiento.es_camino_valido(Vector2i(0, 0), ok, {}, {})).is_true()
	assert_bool(movimiento.es_camino_valido(Vector2i(0, 0), salto, {}, {})).is_false()
	assert_bool(movimiento.es_camino_valido(Vector2i(0, 0), esquina, {}, {})).is_false()
	assert_bool(movimiento.es_camino_valido(Vector2i(0, 0), ok, {Vector2i(0, 1): true}, {})).is_false()
	assert_bool(movimiento.es_camino_valido(Vector2i(0, 0), ok, {}, {Vector2i(1, 2): true})).is_false()

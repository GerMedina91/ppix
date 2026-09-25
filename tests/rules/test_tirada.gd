extends GdUnitTestSuite


func test_interpreta_expresiones_validas(texto: String, cantidad: int, caras: int, modificador: int, test_parameters := [
		["1d20", 1, 20, 0], ["2d6+3", 2, 6, 3], ["1d8-1", 1, 8, -1], [" 3D4+10 ", 3, 4, 10],
	]) -> void:
	var tirada: Tirada = Tirada.desde_texto(texto)
	assert_object(tirada).is_not_null()
	assert_int(tirada.cantidad).is_equal(cantidad)
	assert_int(tirada.caras).is_equal(caras)
	assert_int(tirada.modificador).is_equal(modificador)


func test_rechaza_expresiones_invalidas(texto: String, test_parameters := [
		[""], ["d20"], ["2d"], ["0d6"], ["1d0"], ["2d6+"], ["2x6"], ["1d20+1d4"],
	]) -> void:
	assert_object(Tirada.desde_texto(texto)).is_null()


func test_texto_ida_y_vuelta() -> void:
	assert_str(str(Tirada.desde_texto("2d6+3"))).is_equal("2d6+3")
	assert_str(str(Tirada.desde_texto("1d8-1"))).is_equal("1d8-1")
	assert_str(str(Tirada.desde_texto("1d20"))).is_equal("1d20")


func test_resultado_guarda_cada_dado_y_suma_el_modificador() -> void:
	var tirada: Tirada = Tirada.new(3, 6, 2)
	var resultado: ResultadoTirada = tirada.tirar(Dados.new(8))
	assert_int(resultado.dados.size()).is_equal(3)
	var suma: int = 2
	for valor in resultado.dados:
		suma += valor
	assert_int(resultado.total()).is_equal(suma)
	assert_int(resultado.total()).is_between(tirada.minimo(), tirada.maximo())


func test_minimo_y_maximo() -> void:
	var tirada: Tirada = Tirada.new(2, 6, 3)
	assert_int(tirada.minimo()).is_equal(5)
	assert_int(tirada.maximo()).is_equal(15)

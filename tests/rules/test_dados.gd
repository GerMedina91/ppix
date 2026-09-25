extends GdUnitTestSuite

const TIRADAS: int = 1000


func _secuencia(dados: Dados, caras: int, cantidad: int) -> Array[int]:
	var resultado: Array[int] = []
	for i in cantidad:
		resultado.append(dados.tirar(caras))
	return resultado


func test_misma_semilla_misma_secuencia() -> void:
	var a: Array[int] = _secuencia(Dados.new(1234), 20, 50)
	var b: Array[int] = _secuencia(Dados.new(1234), 20, 50)
	assert_array(a).is_equal(b)


func test_semillas_distintas_secuencias_distintas() -> void:
	var a: Array[int] = _secuencia(Dados.new(1), 20, 50)
	var b: Array[int] = _secuencia(Dados.new(2), 20, 50)
	assert_array(a).is_not_equal(b)


func test_tirar_queda_en_rango(caras: int, test_parameters := [[4], [6], [8], [10], [12], [20]]) -> void:
	var dados: Dados = Dados.new(42)
	for valor in _secuencia(dados, caras, TIRADAS):
		assert_int(valor).is_between(1, caras)


func test_d20_saca_todos_los_valores() -> void:
	var vistos: Dictionary[int, bool] = {}
	var dados: Dados = Dados.new(7)
	for i in TIRADAS:
		vistos[dados.d20()] = true
	assert_int(vistos.size()).is_equal(20)


func test_restaurar_estado_reproduce_las_tiradas_siguientes() -> void:
	var dados: Dados = Dados.new(99)
	_secuencia(dados, 20, 10)  # avanzar el RNG
	var guardado: int = dados.estado()
	var esperadas: Array[int] = _secuencia(dados, 20, 30)
	dados.restaurar_estado(guardado)
	assert_array(_secuencia(dados, 20, 30)).is_equal(esperadas)


func test_estado_restaurado_en_otra_instancia() -> void:
	var original: Dados = Dados.new(5)
	_secuencia(original, 6, 7)
	var copia: Dados = Dados.new(12345)
	copia.restaurar_estado(original.estado())
	assert_array(_secuencia(copia, 6, 20)).is_equal(_secuencia(original, 6, 20))


func test_tirar_varios_devuelve_cada_dado() -> void:
	var resultados: Array[int] = Dados.new(3).tirar_varios(4, 6)
	assert_int(resultados.size()).is_equal(4)
	for valor in resultados:
		assert_int(valor).is_between(1, 6)

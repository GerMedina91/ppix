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

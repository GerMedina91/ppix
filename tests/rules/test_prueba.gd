extends GdUnitTestSuite

const DadosFijos: GDScript = preload("res://tests/utiles/dados_fijos.gd")
const EC: GradoExito.Grado = GradoExito.Grado.EXITO_CRITICO
const E: GradoExito.Grado = GradoExito.Grado.EXITO
const F: GradoExito.Grado = GradoExito.Grado.FALLO
const FC: GradoExito.Grado = GradoExito.Grado.FALLO_CRITICO


## Prueba de ejemplo: atributo +3, entrenado a nivel 1 (+3) => +6 sin modificadores.
func _prueba() -> Prueba:
	return Prueba.new("Percepción", "Sabiduría", 3, Competencia.Rango.ENTRENADO, 1)


func test_total_suma_d20_atributo_competencia_y_modificadores() -> void:
	var prueba: Prueba = _prueba()
	prueba.modificadores = [
		Modificador.new(2, Modificador.Tipo.CIRCUNSTANCIA, "Cobertura"),
		Modificador.new(1, Modificador.Tipo.CIRCUNSTANCIA, "Ayuda"),
		Modificador.new(-1, Modificador.Tipo.ESTADO, "Asustado"),
	]
	var resultado: ResultadoPrueba = prueba.resolver(DadosFijos.new([10]), 15)
	assert_int(resultado.total).is_equal(10 + 3 + 3 + 2 - 1)
	assert_int(resultado.grado).is_equal(E)


func test_desglose_muestra_solo_lo_que_aplica() -> void:
	var prueba: Prueba = _prueba()
	prueba.modificadores = [
		Modificador.new(1, Modificador.Tipo.CIRCUNSTANCIA, "Ayuda"),
		Modificador.new(2, Modificador.Tipo.CIRCUNSTANCIA, "Cobertura"),
	]
	assert_array(prueba.desglose()).is_equal([
		{"fuente": "Sabiduría", "valor": 3},
		{"fuente": "competencia (entrenado)", "valor": 3},
		{"fuente": "Cobertura", "valor": 2},
	])


func test_cd_derivada_es_diez_mas_el_modificador() -> void:
	assert_int(_prueba().cd()).is_equal(16)


func test_sin_fortuna_ni_infortunio_tira_una_vez() -> void:
	var dados: Variant = DadosFijos.new([12, 7])
	var resultado: ResultadoPrueba = _prueba().resolver(dados, 15)
	assert_array(resultado.tiradas).is_equal([12])
	assert_int(dados.restantes()).is_equal(1)


func test_fortuna_tira_dos_y_usa_el_mejor() -> void:
	var prueba: Prueba = _prueba()
	prueba.fortuna = true
	var resultado: ResultadoPrueba = prueba.resolver(DadosFijos.new([5, 14]), 15)
	assert_array(resultado.tiradas).is_equal([5, 14])
	assert_int(resultado.natural).is_equal(14)
	assert_int(resultado.total).is_equal(20)


func test_infortunio_tira_dos_y_usa_el_peor() -> void:
	var prueba: Prueba = _prueba()
	prueba.infortunio = true
	var resultado: ResultadoPrueba = prueba.resolver(DadosFijos.new([5, 14]), 15)
	assert_int(resultado.natural).is_equal(5)
	assert_int(resultado.total).is_equal(11)


func test_fortuna_e_infortunio_se_cancelan() -> void:
	var prueba: Prueba = _prueba()
	prueba.fortuna = true
	prueba.infortunio = true
	var dados: Variant = DadosFijos.new([5, 14])
	var resultado: ResultadoPrueba = prueba.resolver(dados, 15)
	assert_array(resultado.tiradas).is_equal([5])
	assert_int(dados.restantes()).is_equal(1)


func test_con_fortuna_el_20_natural_del_dado_elegido_mejora_el_grado() -> void:
	var prueba: Prueba = _prueba()
	prueba.fortuna = true
	# 20 + 6 = 26 contra CD 30 sería fallo; el 20 natural lo sube a éxito.
	var resultado: ResultadoPrueba = prueba.resolver(DadosFijos.new([3, 20]), 30)
	assert_int(resultado.natural).is_equal(20)
	assert_int(resultado.grado).is_equal(E)


func test_con_infortunio_el_20_descartado_no_cuenta() -> void:
	var prueba: Prueba = _prueba()
	prueba.infortunio = true
	# Se usa el 12: 12 + 6 = 18 contra CD 20 es fallo, sin ajuste por el 20 descartado.
	var resultado: ResultadoPrueba = prueba.resolver(DadosFijos.new([20, 12]), 20)
	assert_int(resultado.natural).is_equal(12)
	assert_int(resultado.grado).is_equal(F)


func test_con_infortunio_el_1_elegido_empeora_el_grado() -> void:
	var prueba: Prueba = _prueba()
	prueba.infortunio = true
	# 1 + 6 = 7 contra CD 10 es fallo; el 1 natural lo baja a fallo crítico.
	var resultado: ResultadoPrueba = prueba.resolver(DadosFijos.new([15, 1]), 10)
	assert_int(resultado.natural).is_equal(1)
	assert_int(resultado.grado).is_equal(FC)


func test_con_fortuna_el_1_descartado_no_cuenta() -> void:
	var prueba: Prueba = _prueba()
	prueba.fortuna = true
	# Se usa el 14: 14 + 6 = 20 contra CD 10 es éxito crítico; el 1 descartado no lo baja.
	var resultado: ResultadoPrueba = prueba.resolver(DadosFijos.new([1, 14]), 10)
	assert_int(resultado.natural).is_equal(14)
	assert_int(resultado.grado).is_equal(EC)

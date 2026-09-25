extends GdUnitTestSuite

const CD: int = 20
const EC: GradoExito.Grado = GradoExito.Grado.EXITO_CRITICO
const E: GradoExito.Grado = GradoExito.Grado.EXITO
const F: GradoExito.Grado = GradoExito.Grado.FALLO
const FC: GradoExito.Grado = GradoExito.Grado.FALLO_CRITICO

## [total, natural, grado esperado] contra CD 20. El natural 10 no ajusta nada.
const CASOS: Array = [
	# Sin ajuste por natural: bordes de cada grado.
	[31, 10, EC], [30, 10, EC], [29, 10, E], [20, 10, E], [19, 10, F], [11, 10, F], [10, 10, FC], [0, 10, FC],
	# 20 natural: sube un grado, sin pasar de éxito crítico.
	[30, 20, EC], [29, 20, EC], [20, 20, EC], [19, 20, E], [11, 20, E], [10, 20, F],
	# 1 natural: baja un grado, sin pasar de fallo crítico.
	[30, 1, E], [29, 1, F], [20, 1, F], [19, 1, FC], [11, 1, FC], [10, 1, FC],
]


func test_tabla_completa_de_grados() -> void:
	for caso: Array in CASOS:
		var obtenido: GradoExito.Grado = GradoExito.calcular(caso[0], CD, caso[1])
		assert_int(obtenido).override_failure_message(
			"total %d, natural %d: esperaba %s, obtuve %s" % [caso[0], caso[1], GradoExito.nombre(caso[2]), GradoExito.nombre(obtenido)]
		).is_equal(caso[2])


func test_mejorar_y_empeorar_respetan_los_extremos() -> void:
	assert_int(GradoExito.mejorar(EC)).is_equal(EC)
	assert_int(GradoExito.empeorar(FC)).is_equal(FC)
	assert_int(GradoExito.mejorar(F)).is_equal(E)
	assert_int(GradoExito.empeorar(E)).is_equal(F)


func test_nombres_segun_el_glosario() -> void:
	assert_str(GradoExito.nombre(EC)).is_equal("éxito crítico")
	assert_str(GradoExito.nombre(E)).is_equal("éxito")
	assert_str(GradoExito.nombre(F)).is_equal("fallo")
	assert_str(GradoExito.nombre(FC)).is_equal("fallo crítico")

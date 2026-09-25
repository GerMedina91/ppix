extends GdUnitTestSuite

const R: Dictionary = {
	"no_entrenado": Competencia.Rango.NO_ENTRENADO, "entrenado": Competencia.Rango.ENTRENADO,
	"experto": Competencia.Rango.EXPERTO, "maestro": Competencia.Rango.MAESTRO, "legendario": Competencia.Rango.LEGENDARIO,
}


func test_no_entrenado_no_suma_el_nivel() -> void:
	for nivel: int in [1, 5, 20]:
		assert_int(Competencia.bonificador(R.no_entrenado, nivel)).is_equal(0)


func test_rangos_entrenados_suman_nivel_mas_fijo() -> void:
	# [rango, nivel, esperado]
	for caso: Array in [
			[R.entrenado, 1, 3], [R.experto, 1, 5], [R.maestro, 1, 7], [R.legendario, 1, 9],
			[R.entrenado, 7, 9], [R.experto, 10, 14], [R.maestro, 15, 21], [R.legendario, 20, 28]]:
		assert_int(Competencia.bonificador(caso[0], caso[1])).override_failure_message(
			"%s a nivel %d" % [Competencia.nombre(caso[0]), caso[1]]).is_equal(caso[2])


func test_nombres_segun_el_glosario() -> void:
	assert_array(R.values().map(func(r: Competencia.Rango) -> String: return Competencia.nombre(r))).is_equal(
		["no entrenado", "entrenado", "experto", "maestro", "legendario"])

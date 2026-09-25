extends GdUnitTestSuite

const CIRC: Modificador.Tipo = Modificador.Tipo.CIRCUNSTANCIA
const ESTADO: Modificador.Tipo = Modificador.Tipo.ESTADO
const OBJETO: Modificador.Tipo = Modificador.Tipo.OBJETO
const SIN_TIPO: Modificador.Tipo = Modificador.Tipo.SIN_TIPO


func _m(valor: int, tipo: Modificador.Tipo, fuente: String = "prueba") -> Modificador:
	return Modificador.new(valor, tipo, fuente)


func test_sin_modificadores_suma_cero() -> void:
	assert_int(SumaModificadores.total([])).is_equal(0)


func test_bonificadores_del_mismo_tipo_no_se_apilan() -> void:
	assert_int(SumaModificadores.total([_m(1, CIRC), _m(2, CIRC), _m(1, CIRC)])).is_equal(2)


func test_bonificadores_de_distinto_tipo_se_suman() -> void:
	assert_int(SumaModificadores.total([_m(1, CIRC), _m(2, ESTADO), _m(1, OBJETO)])).is_equal(4)


func test_penalizadores_del_mismo_tipo_aplica_el_peor() -> void:
	assert_int(SumaModificadores.total([_m(-1, ESTADO), _m(-2, ESTADO)])).is_equal(-2)


func test_penalizadores_sin_tipo_se_suman_todos() -> void:
	assert_int(SumaModificadores.total([_m(-1, SIN_TIPO), _m(-2, SIN_TIPO), _m(-1, SIN_TIPO)])).is_equal(-4)


func test_bonificador_y_penalizador_del_mismo_tipo_se_suman() -> void:
	# El mejor bonificador y el peor penalizador de un tipo aplican los dos.
	assert_int(SumaModificadores.total([_m(2, CIRC), _m(-1, CIRC), _m(-2, CIRC), _m(1, CIRC)])).is_equal(0)


func test_caso_mixto() -> void:
	var modificadores: Array[Modificador] = [
		_m(1, CIRC), _m(2, CIRC),      # +2
		_m(1, ESTADO),                 # +1
		_m(-1, ESTADO), _m(-2, ESTADO),# -2
		_m(-1, SIN_TIPO), _m(-1, SIN_TIPO), # -2
		_m(0, OBJETO),                 # no aplica
	]
	assert_int(SumaModificadores.total(modificadores)).is_equal(-1)


func test_aplicados_para_el_desglose_mantiene_el_orden_y_descarta_el_resto() -> void:
	var chico: Modificador = _m(1, CIRC, "Ayuda")
	var grande: Modificador = _m(2, CIRC, "Cobertura")
	var estado: Modificador = _m(-1, ESTADO, "Asustado")
	var cero: Modificador = _m(0, OBJETO, "Nada")
	assert_array(SumaModificadores.aplicados([chico, estado, grande, cero])).is_equal([estado, grande])


func test_con_empate_aplica_uno_solo() -> void:
	var primero: Modificador = _m(2, OBJETO, "A")
	var segundo: Modificador = _m(2, OBJETO, "B")
	assert_array(SumaModificadores.aplicados([primero, segundo])).is_equal([primero])

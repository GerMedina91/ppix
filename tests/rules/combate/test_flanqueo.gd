extends GdUnitTestSuite

const CAC: String = "res://data/personajes/party_prueba_cuerpo_a_cuerpo.tres"
const DIST: String = "res://data/personajes/party_prueba_distancia.tres"
const ENEMIGO: String = "res://data/criaturas/enemigo_prueba_cuerpo_a_cuerpo.tres"
const O: Vector2i = Vector2i(5, 5)


func _pj(id: StringName, celda: Vector2i, ruta: String = CAC) -> Combatiente:
	return Combatiente.desde_personaje(id, load(ruta), celda)


func _enemigo(celda: Vector2i = O) -> Combatiente:
	return Combatiente.desde_criatura(&"enemigo", load(ENEMIGO), celda)


func test_geometria_lados_opuestos() -> void:
	# [a, b, flanquean]
	for caso: Array in [
			[Vector2i(-1, 0), Vector2i(1, 0), true],     # oeste - este
			[Vector2i(0, -1), Vector2i(0, 1), true],     # norte - sur
			[Vector2i(-1, -1), Vector2i(1, 1), true],    # esquinas opuestas
			[Vector2i(-1, 1), Vector2i(1, -1), true],
			[Vector2i(-1, 0), Vector2i(0, -1), false],   # en L
			[Vector2i(-1, 0), Vector2i(1, 1), false],    # izquierda y abajo: no opuestos
			[Vector2i(-2, -1), Vector2i(2, 1), true],    # alcance 10: la recta cruza izquierda-derecha
			[Vector2i(-1, 0), Vector2i(-1, 1), false]]:  # la recta no cruza al objetivo
		assert_bool(Flanqueo.lados_opuestos(O + caso[0], O + caso[1], O)).override_failure_message(
			"%s / %s" % [caso[0], caso[1]]).is_equal(caso[2])


func test_dos_aliados_en_lados_opuestos_flanquean() -> void:
	var a: Combatiente = _pj(&"a", O + Vector2i(-1, 0))
	var b: Combatiente = _pj(&"b", O + Vector2i(1, 0))
	var objetivo: Combatiente = _enemigo()
	var todos: Array[Combatiente] = [a, b, objetivo]
	assert_bool(Flanqueo.atacante_flanquea(a, objetivo, todos)).is_true()
	assert_bool(Flanqueo.atacante_flanquea(b, objetivo, todos)).is_true()


func test_un_tercer_atacante_que_no_flanquea_no_se_beneficia() -> void:
	var a: Combatiente = _pj(&"a", O + Vector2i(-1, 0))
	var b: Combatiente = _pj(&"b", O + Vector2i(1, 0))
	var c: Combatiente = _pj(&"c", O + Vector2i(0, -1))   # al norte: sin nadie al sur
	var objetivo: Combatiente = _enemigo()
	var todos: Array[Combatiente] = [a, b, c, objetivo]
	assert_bool(Flanqueo.atacante_flanquea(a, objetivo, todos)).is_true()
	assert_bool(Flanqueo.atacante_flanquea(c, objetivo, todos)).is_false()


func test_aliado_inconsciente_no_flanquea() -> void:
	var a: Combatiente = _pj(&"a", O + Vector2i(-1, 0))
	var b: Combatiente = _pj(&"b", O + Vector2i(1, 0))
	b.recibir_danio(b.pg, false)
	var objetivo: Combatiente = _enemigo()
	assert_bool(Flanqueo.atacante_flanquea(a, objetivo, [a, b, objetivo])).is_false()


func test_aliado_sin_arma_cuerpo_a_cuerpo_no_flanquea() -> void:
	var a: Combatiente = _pj(&"a", O + Vector2i(-1, 0))
	var b: Combatiente = _pj(&"b", O + Vector2i(1, 0), DIST)  # solo arma a distancia
	var objetivo: Combatiente = _enemigo()
	assert_bool(Flanqueo.atacante_flanquea(a, objetivo, [a, b, objetivo])).is_false()


func test_un_enemigo_del_otro_lado_no_cuenta_como_aliado() -> void:
	var a: Combatiente = _pj(&"a", O + Vector2i(-1, 0))
	var otro_enemigo: Combatiente = _enemigo(O + Vector2i(1, 0))
	var objetivo: Combatiente = _enemigo()
	assert_bool(Flanqueo.atacante_flanquea(a, objetivo, [a, otro_enemigo, objetivo])).is_false()


func test_desprevenido_por_flanqueo_solo_frente_al_que_flanquea() -> void:
	var objetivo: Combatiente = _enemigo()
	assert_int(objetivo.defensa_contra(true).cd()).is_equal(objetivo.defensa_contra(false).cd() - 2)

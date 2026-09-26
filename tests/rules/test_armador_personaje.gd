extends GdUnitTestSuite
## Builds fijos del slice (nivel 1, humano) armados con las reglas del Player Core. Los números esperados
## están calculados a mano a partir de docs/verificacion/c1_clases.md.

const AT: Dictionary = {
	"FUE": Atributo.Tipo.FUERZA, "DES": Atributo.Tipo.DESTREZA, "CON": Atributo.Tipo.CONSTITUCION,
	"INT": Atributo.Tipo.INTELIGENCIA, "SAB": Atributo.Tipo.SABIDURIA, "CAR": Atributo.Tipo.CARISMA,
}


func _armar(id: String) -> DefinicionPersonaje:
	return ArmadorPersonaje.armar(load("res://data/builds/%s.tres" % id))


func _atributos(p: DefinicionPersonaje) -> Array[int]:
	return [p.fuerza, p.destreza, p.constitucion, p.inteligencia, p.sabiduria, p.carisma]


func _salvacion(p: DefinicionPersonaje, s: Estadisticas.Salvacion) -> int:
	return Estadisticas.prueba_salvacion(p, s).modificador_total()


func _ataque(p: DefinicionPersonaje) -> int:
	return Estadisticas.prueba_ataque(p, p.armas[0]).modificador_total()


func test_los_cuatro_builds_son_validos() -> void:
	for id: String in ["guerrero", "picaro", "clerigo", "bruja"]:
		assert_array(Array(ArmadorPersonaje.validar(load("res://data/builds/%s.tres" % id)))).override_failure_message(id).is_empty()


func test_guerrero() -> void:
	var p: DefinicionPersonaje = _armar("guerrero")
	assert_array(_atributos(p)).is_equal([4, 1, 2, 0, 2, 0])
	assert_int(Estadisticas.pg_maximos(p)).is_equal(8 + 10 + 2)
	# Cota de malla: 10 + Des 1 (tope 1) + media entrenado 3 + 4.
	assert_int(Estadisticas.ca(p)).is_equal(18)
	assert_int(Estadisticas.velocidad(p)).is_equal(25)  # Fuerza 4 >= requisito 3
	# Espadón (marcial): Fuerza 4 + experto 5.
	assert_int(_ataque(p)).is_equal(9)
	assert_int(Estadisticas.prueba_percepcion(p).modificador_total()).is_equal(2 + 5)
	assert_int(_salvacion(p, Estadisticas.Salvacion.FORTALEZA)).is_equal(2 + 5)
	assert_int(_salvacion(p, Estadisticas.Salvacion.REFLEJOS)).is_equal(1 + 5)
	assert_int(_salvacion(p, Estadisticas.Salvacion.VOLUNTAD)).is_equal(2 + 3)
	assert_int(Estadisticas.cd_clase(p)).is_equal(10 + 4 + 3)
	assert_bool(p.habilidades.has(Habilidad.Tipo.ATLETISMO)).is_true()


func test_picaro() -> void:
	var p: DefinicionPersonaje = _armar("picaro")
	assert_array(_atributos(p)).is_equal([0, 4, 1, 1, 1, 2])
	assert_int(Estadisticas.pg_maximos(p)).is_equal(8 + 8 + 1)
	# Cuero: 10 + Des 4 (tope 4) + ligera entrenado 3 + 1.
	assert_int(Estadisticas.ca(p)).is_equal(18)
	# Estoque (marcial, sutil): Destreza 4 + entrenado 3.
	assert_int(_ataque(p)).is_equal(7)
	assert_int(_salvacion(p, Estadisticas.Salvacion.REFLEJOS)).is_equal(4 + 5)
	assert_int(_salvacion(p, Estadisticas.Salvacion.VOLUNTAD)).is_equal(1 + 5)
	assert_bool(p.habilidades.has(Habilidad.Tipo.SIGILO)).is_true()
	assert_bool(p.habilidades.has(Habilidad.Tipo.LATROCINIO)).is_true()  # tejemaneje Ladrón
	# Sigilo 1 fija + Latrocinio + 8 libres (7 + Int 1) + 1 de trasfondo.
	assert_int(p.habilidades.size()).is_equal(11)


func test_clerigo() -> void:
	var p: DefinicionPersonaje = _armar("clerigo")
	assert_array(_atributos(p)).is_equal([1, 1, 2, 0, 4, 1])
	assert_int(Estadisticas.pg_maximos(p)).is_equal(8 + 8 + 2)
	# Sin armadura: 10 + Des 1 + sin armadura entrenado 3.
	assert_int(Estadisticas.ca(p)).is_equal(14)
	# Alabarda (marcial) entrenado por ser el arma predilecta de El Umbral: Fuerza 1 + 3.
	assert_int(_ataque(p)).is_equal(4)
	assert_int(p.armas[0].alcance_pies).is_equal(10)
	assert_int(_salvacion(p, Estadisticas.Salvacion.VOLUNTAD)).is_equal(4 + 5)
	assert_bool(p.habilidades.has(Habilidad.Tipo.RELIGION)).is_true()
	assert_bool(p.habilidades.has(Habilidad.Tipo.OCULTISMO)).is_true()  # habilidad divina


func test_bruja() -> void:
	var p: DefinicionPersonaje = _armar("bruja")
	assert_array(_atributos(p)).is_equal([0, 2, 1, 4, 2, 0])
	assert_int(Estadisticas.pg_maximos(p)).is_equal(8 + 6 + 1)
	assert_int(Estadisticas.ca(p)).is_equal(10 + 2 + 3)
	# Daga (simple, sutil): Destreza 2 + 3.
	assert_int(_ataque(p)).is_equal(5)
	assert_bool(p.habilidades.has(Habilidad.Tipo.OCULTISMO)).is_true()  # patrón
	assert_int(p.habilidades.size()).is_equal(1 + 7 + 1)


func test_valida_mejoras_repetidas_en_una_fuente() -> void:
	var b: DefinicionBuild = load("res://data/builds/guerrero.tres").duplicate()
	b.mejoras_libres = [Atributo.Tipo.FUERZA, Atributo.Tipo.FUERZA, Atributo.Tipo.CONSTITUCION, Atributo.Tipo.SABIDURIA]
	assert_array(Array(ArmadorPersonaje.validar(b))).is_not_empty()


func test_valida_el_maximo_de_4_a_nivel_1() -> void:
	var b: DefinicionBuild = load("res://data/builds/guerrero.tres").duplicate()
	# Fuerza ya llega a +4; una mejora más de ascendencia la llevaría a +5.
	b.mejoras_ascendencia = [Atributo.Tipo.FUERZA, Atributo.Tipo.FUERZA]
	var errores: Array = Array(ArmadorPersonaje.validar(b))
	assert_bool(errores.any(func(e: String) -> bool: return e.contains("supera +4"))).is_true()


func test_valida_la_cantidad_de_habilidades_libres() -> void:
	var b: DefinicionBuild = load("res://data/builds/bruja.tres").duplicate()
	b.habilidades_libres = b.habilidades_libres.slice(0, 3)
	assert_array(Array(ArmadorPersonaje.validar(b))).is_not_empty()


func test_valida_competencia_en_la_armadura() -> void:
	var b: DefinicionBuild = load("res://data/builds/bruja.tres").duplicate()
	b.armadura = load("res://data/armaduras/cota_de_malla.tres")
	assert_array(Array(ArmadorPersonaje.validar(b))).is_not_empty()


func test_valida_el_atributo_clave() -> void:
	var b: DefinicionBuild = load("res://data/builds/clerigo.tres").duplicate()
	b.atributo_clave = Atributo.Tipo.FUERZA
	assert_array(Array(ArmadorPersonaje.validar(b))).is_not_empty()


func test_el_personaje_armado_funciona_en_combate() -> void:
	var c: Combatiente = Combatiente.desde_personaje(&"g", _armar("guerrero"), Vector2i.ZERO)
	assert_int(c.pg).is_equal(20)
	assert_int(c.fuente.defensa().cd()).is_equal(18)
	assert_int(c.fuente.velocidad_pies()).is_equal(25)


func test_conjuros_de_los_builds() -> void:
	var bruja: DefinicionPersonaje = ArmadorPersonaje.armar(load("res://data/builds/bruja.tres"))
	var clerigo: DefinicionPersonaje = ArmadorPersonaje.armar(load("res://data/builds/clerigo.tres"))
	assert_bool(bruja.trucos.has(load("res://data/conjuros/mal_de_ojo.tres"))).is_true()  # del patrón
	assert_array(bruja.conjuros_preparados).contains([load("res://data/conjuros/debilitar.tres")])
	assert_array(clerigo.conjuros_foco).is_equal([load("res://data/conjuros/pies_agiles.tres")])


func test_un_conjuro_de_otra_tradicion_no_se_puede_preparar() -> void:
	var build: DefinicionBuild = (load("res://data/builds/bruja.tres") as DefinicionBuild).duplicate()
	var divino: DefinicionConjuro = (load("res://data/conjuros/debilitar.tres") as DefinicionConjuro).duplicate()
	divino.tradiciones = [Tradicion.Tipo.DIVINA]
	build.conjuros_preparados = [divino]
	assert_str(" ".join(ArmadorPersonaje.validar(build))).contains("no es de su tradición")


func test_no_se_preparan_mas_conjuros_que_espacios() -> void:
	var build: DefinicionBuild = (load("res://data/builds/bruja.tres") as DefinicionBuild).duplicate()
	var debilitar: DefinicionConjuro = load("res://data/conjuros/debilitar.tres")
	build.conjuros_preparados = [debilitar, debilitar, debilitar]
	assert_str(" ".join(ArmadorPersonaje.validar(build))).contains("espacios de rango 1")


func test_el_conjuro_de_dominio_tiene_que_ser_de_la_entidad() -> void:
	var build: DefinicionBuild = (load("res://data/builds/clerigo.tres") as DefinicionBuild).duplicate()
	var ajeno: DefinicionConjuro = (load("res://data/conjuros/pies_agiles.tres") as DefinicionConjuro).duplicate()
	ajeno.dominio = &"fuego"
	build.conjuros_foco = [ajeno]
	assert_str(" ".join(ArmadorPersonaje.validar(build))).contains("dominio que su entidad no tiene")

extends GdUnitTestSuite

const CAC: String = "res://data/personajes/party_prueba_cuerpo_a_cuerpo.tres"
const DIST: String = "res://data/personajes/party_prueba_distancia.tres"
const ENEMIGO: String = "res://data/criaturas/enemigo_prueba_cuerpo_a_cuerpo.tres"


func test_combatiente_de_personaje_usa_estadisticas() -> void:
	var personaje: DefinicionPersonaje = load(CAC)
	var c: Combatiente = Combatiente.desde_personaje(&"cac", personaje, Vector2i(2, 3))
	assert_int(c.pg_maximos()).is_equal(Estadisticas.pg_maximos(personaje))
	assert_int(c.pg).is_equal(c.pg_maximos())
	assert_int(c.fuente.defensa().cd()).is_equal(Estadisticas.ca(personaje))
	assert_int(c.fuente.velocidad_pies()).is_equal(25)
	assert_int(c.bando).is_equal(Combatiente.Bando.PARTY)
	assert_bool(c.fuente.usa_reglas_de_moribundo()).is_true()


func test_ataque_cuerpo_a_cuerpo_usa_fuerza_y_suma_fuerza_al_danio() -> void:
	var personaje: DefinicionPersonaje = load(CAC)
	var fuente: FuentePersonaje = FuentePersonaje.new(personaje)
	var arma: DefinicionArma = personaje.armas[0]
	# Fuerza +4, entrenado a nivel 1 (+3).
	assert_int(fuente.prueba_ataque(arma).modificador_total()).is_equal(7)
	assert_int(fuente.bonificador_danio(arma)).is_equal(4)


func test_ataque_a_distancia_usa_destreza_y_no_suma_fuerza() -> void:
	var personaje: DefinicionPersonaje = load(DIST)
	var fuente: FuentePersonaje = FuentePersonaje.new(personaje)
	var arma: DefinicionArma = personaje.armas[0]
	assert_int(fuente.prueba_ataque(arma).modificador_total()).is_equal(4 + 3)
	assert_int(fuente.bonificador_danio(arma)).is_equal(0)


func test_arma_sutil_usa_la_mejor_entre_fuerza_y_destreza() -> void:
	var personaje: DefinicionPersonaje = DefinicionPersonaje.new()
	personaje.fuerza = 1
	personaje.destreza = 3
	var arma: DefinicionArma = DefinicionArma.new()
	arma.sutil = true
	assert_int(Estadisticas.atributo_de_ataque(personaje, arma)).is_equal(Atributo.Tipo.DESTREZA)
	arma.sutil = false
	assert_int(Estadisticas.atributo_de_ataque(personaje, arma)).is_equal(Atributo.Tipo.FUERZA)


func test_combatiente_de_criatura_usa_sus_numeros_directos() -> void:
	var criatura: DefinicionCriatura = load(ENEMIGO)
	var c: Combatiente = Combatiente.desde_criatura(&"e1", criatura, Vector2i.ZERO)
	assert_int(c.pg).is_equal(20)
	assert_int(c.fuente.defensa().cd()).is_equal(16)
	assert_int(c.fuente.prueba_ataque(c.arma_principal()).modificador_total()).is_equal(9)
	assert_int(c.fuente.bonificador_danio(c.arma_principal())).is_equal(3)
	assert_int(c.bando).is_equal(Combatiente.Bando.ENEMIGOS)
	assert_bool(c.fuente.usa_reglas_de_moribundo()).is_false()


func test_desglose_de_criatura_sin_linea_de_competencia() -> void:
	var c: Combatiente = Combatiente.desde_criatura(&"e1", load(ENEMIGO), Vector2i.ZERO)
	assert_array(c.fuente.prueba_ataque(c.arma_principal()).desglose()).is_equal([{"fuente": "bonificador de ataque", "valor": 9}])


func test_turno_da_tres_acciones_y_reaccion() -> void:
	var c: Combatiente = Combatiente.desde_criatura(&"e1", load(ENEMIGO), Vector2i.ZERO)
	c.empezar_turno()
	assert_int(c.acciones_restantes).is_equal(3)
	assert_bool(c.reaccion_disponible).is_true()
	assert_bool(c.gastar_acciones(2)).is_true()
	assert_bool(c.gastar_acciones(2)).is_false()
	assert_int(c.acciones_restantes).is_equal(1)


func test_prueba_plana_no_suma_nada() -> void:
	var prueba: Prueba = Prueba.plana("prueba de recuperación")
	assert_int(prueba.modificador_total()).is_equal(0)
	assert_array(prueba.desglose()).is_empty()


func test_arma_a_distancia_sin_incremento_es_invalida() -> void:
	var arma: DefinicionArma = DefinicionArma.new()
	arma.a_distancia = true
	assert_array(Array(arma.errores_de_datos())).is_not_empty()
	arma.incremento_rango_pies = 60
	assert_array(Array(arma.errores_de_datos())).is_empty()


func test_criatura_sin_armas_es_invalida() -> void:
	assert_array(Array(DefinicionCriatura.new().errores_de_datos())).is_not_empty()

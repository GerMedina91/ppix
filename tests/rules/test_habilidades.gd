extends GdUnitTestSuite
## Pruebas de habilidad y penalizador a pruebas de la armadura (Player Core, verificado en AoN).

const E: Competencia.Rango = Competencia.Rango.ENTRENADO


func _personaje() -> DefinicionPersonaje:
	var p: DefinicionPersonaje = DefinicionPersonaje.new()
	p.nivel = 1
	p.fuerza = 2
	p.destreza = 3
	p.inteligencia = 1
	p.habilidades = {Habilidad.Tipo.SIGILO: E, Habilidad.Tipo.OCULTISMO: E}
	return p


func _cota_de_malla() -> DefinicionArmadura:
	var a: DefinicionArmadura = DefinicionArmadura.new()
	a.nombre = "cota de malla"
	a.categoria = DefinicionArmadura.Categoria.MEDIA
	a.requisito_fuerza = 3
	a.penalizador_pruebas = -2
	return a


func test_cada_habilidad_usa_su_atributo() -> void:
	assert_int(Habilidad.ATRIBUTO.size()).is_equal(16)
	assert_int(Habilidad.ATRIBUTO[Habilidad.Tipo.LATROCINIO]).is_equal(Atributo.Tipo.DESTREZA)
	assert_int(Habilidad.ATRIBUTO[Habilidad.Tipo.RELIGION]).is_equal(Atributo.Tipo.SABIDURIA)
	assert_int(Habilidad.ATRIBUTO[Habilidad.Tipo.OCULTISMO]).is_equal(Atributo.Tipo.INTELIGENCIA)


func test_entrenada_suma_atributo_y_competencia() -> void:
	# Sigilo: Destreza +3, entrenado a nivel 1 (+3).
	assert_int(Estadisticas.prueba_habilidad(_personaje(), Habilidad.Tipo.SIGILO).modificador_total()).is_equal(6)


func test_no_entrenada_suma_solo_el_atributo() -> void:
	assert_int(Estadisticas.prueba_habilidad(_personaje(), Habilidad.Tipo.ACROBACIAS).modificador_total()).is_equal(3)


func test_armadura_penaliza_habilidades_de_fuerza_y_destreza_si_falta_fuerza() -> void:
	var p: DefinicionPersonaje = _personaje()
	p.armadura = _cota_de_malla()
	assert_int(Estadisticas.prueba_habilidad(p, Habilidad.Tipo.SIGILO).modificador_total()).is_equal(6 - 2)
	assert_int(Estadisticas.prueba_habilidad(p, Habilidad.Tipo.ATLETISMO).modificador_total()).is_equal(2 - 2)
	assert_int(Estadisticas.prueba_habilidad(p, Habilidad.Tipo.OCULTISMO).modificador_total()).is_equal(1 + 3)


func test_con_fuerza_suficiente_no_hay_penalizador() -> void:
	var p: DefinicionPersonaje = _personaje()
	p.armadura = _cota_de_malla()
	p.fuerza = 3
	assert_int(Estadisticas.prueba_habilidad(p, Habilidad.Tipo.SIGILO).modificador_total()).is_equal(6)


func test_con_rasgo_ataque_no_hay_penalizador() -> void:
	var p: DefinicionPersonaje = _personaje()
	p.armadura = _cota_de_malla()
	assert_int(Estadisticas.prueba_habilidad(p, Habilidad.Tipo.ATLETISMO, true).modificador_total()).is_equal(2)


func test_criatura_usa_su_modificador_directo() -> void:
	var criatura: DefinicionCriatura = load("res://data/criaturas/enemigo_prueba_cuerpo_a_cuerpo.tres").duplicate()
	criatura.habilidades = {Habilidad.Tipo.ATLETISMO: 7}
	var fuente: FuenteCriatura = FuenteCriatura.new(criatura)
	assert_int(fuente.prueba_habilidad(Habilidad.Tipo.ATLETISMO).modificador_total()).is_equal(7)
	assert_int(fuente.prueba_habilidad(Habilidad.Tipo.SIGILO).modificador_total()).is_equal(0)

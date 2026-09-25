extends GdUnitTestSuite
## Competencias por categoría de arma y armadura, Velocidad con armadura y rasgo letal
## (reglas verificadas en docs/verificacion/c1_clases.md).

const DadosFijos: GDScript = preload("res://tests/utiles/dados_fijos.gd")
const E: Competencia.Rango = Competencia.Rango.ENTRENADO
const X: Competencia.Rango = Competencia.Rango.EXPERTO


func _arma(categoria: DefinicionArma.Categoria, id: StringName = &"") -> DefinicionArma:
	var a: DefinicionArma = DefinicionArma.new()
	a.categoria = categoria
	a.id = id
	return a


## Cota de malla del Player Core: +4 CA, tope +1, media, Fuerza +3, -2 a pruebas, -5 pies.
func _cota_de_malla() -> DefinicionArmadura:
	var a: DefinicionArmadura = DefinicionArmadura.new()
	a.categoria = DefinicionArmadura.Categoria.MEDIA
	a.bonificador_ca = 4
	a.tope_destreza = 1
	a.requisito_fuerza = 3
	a.penalizador_pruebas = -2
	a.penalizador_velocidad_pies = 5
	return a


func test_el_rango_de_ataque_depende_de_la_categoria_del_arma() -> void:
	var p: DefinicionPersonaje = DefinicionPersonaje.new()
	p.ataques = {DefinicionArma.Categoria.SIMPLE: X, DefinicionArma.Categoria.MARCIAL: E}
	assert_int(Estadisticas.rango_de_ataque(p, _arma(DefinicionArma.Categoria.SIMPLE))).is_equal(X)
	assert_int(Estadisticas.rango_de_ataque(p, _arma(DefinicionArma.Categoria.MARCIAL))).is_equal(E)
	assert_int(Estadisticas.rango_de_ataque(p, _arma(DefinicionArma.Categoria.AVANZADA))).is_equal(Competencia.Rango.NO_ENTRENADO)


func test_competencia_en_un_arma_especifica_gana_si_es_mejor() -> void:
	# Clérigo: arma predilecta marcial (alabarda) entrenado, sin competencia en marciales.
	var p: DefinicionPersonaje = DefinicionPersonaje.new()
	p.ataques = {DefinicionArma.Categoria.SIMPLE: E}
	p.armas_con_competencia = {&"alabarda": E}
	assert_int(Estadisticas.rango_de_ataque(p, _arma(DefinicionArma.Categoria.MARCIAL, &"alabarda"))).is_equal(E)
	assert_int(Estadisticas.rango_de_ataque(p, _arma(DefinicionArma.Categoria.MARCIAL, &"espadon"))).is_equal(Competencia.Rango.NO_ENTRENADO)


func test_la_defensa_usa_la_categoria_de_la_armadura_puesta() -> void:
	var p: DefinicionPersonaje = DefinicionPersonaje.new()
	p.defensas = {DefinicionArmadura.Categoria.SIN_ARMADURA: E, DefinicionArmadura.Categoria.MEDIA: X}
	assert_int(Estadisticas.rango_de_defensa(p)).is_equal(E)
	p.armadura = _cota_de_malla()
	assert_int(Estadisticas.rango_de_defensa(p)).is_equal(X)


func test_con_armadura_sin_competencia_no_suma_competencia() -> void:
	var p: DefinicionPersonaje = DefinicionPersonaje.new()
	p.defensas = {DefinicionArmadura.Categoria.SIN_ARMADURA: E}
	p.armadura = _cota_de_malla()
	assert_int(Estadisticas.rango_de_defensa(p)).is_equal(Competencia.Rango.NO_ENTRENADO)


func test_velocidad_con_fuerza_suficiente_no_pierde_los_5_pies() -> void:
	var p: DefinicionPersonaje = DefinicionPersonaje.new()
	p.velocidad_pies = 25
	p.armadura = _cota_de_malla()
	p.fuerza = 3
	assert_int(Estadisticas.velocidad(p)).is_equal(25)
	p.fuerza = 2
	assert_int(Estadisticas.velocidad(p)).is_equal(20)


func test_velocidad_con_penalizador_de_10_baja_a_5_con_fuerza() -> void:
	var p: DefinicionPersonaje = DefinicionPersonaje.new()
	p.velocidad_pies = 25
	p.armadura = _cota_de_malla()
	p.armadura.penalizador_velocidad_pies = 10
	p.fuerza = 3
	assert_int(Estadisticas.velocidad(p)).is_equal(20)
	p.fuerza = 0
	assert_int(Estadisticas.velocidad(p)).is_equal(15)


func test_letal_suma_un_dado_despues_de_duplicar() -> void:
	var grilla: GrillaMapa = GrillaMapa.new(Rect2i(0, 0, 5, 5))
	for x in 5:
		for y in 5:
			grilla.set_transitable(Vector2i(x, y), true)
	var personaje: DefinicionPersonaje = DefinicionPersonaje.new()
	personaje.destreza = 4
	personaje.ataques = {DefinicionArma.Categoria.MARCIAL: E}
	var estoque: DefinicionArma = _arma(DefinicionArma.Categoria.MARCIAL, &"estoque")
	estoque.caras_dado = 6
	estoque.sutil = true
	estoque.letal_caras = 8
	personaje.armas = [estoque]
	var atacante: Combatiente = Combatiente.desde_personaje(&"a", personaje, Vector2i(1, 1))
	var objetivo: Combatiente = Combatiente.desde_criatura(&"e", load("res://data/criaturas/enemigo_prueba_cuerpo_a_cuerpo.tres"), Vector2i(2, 1))
	# 20 natural: crítico. Daño d6 (5) + Fuerza 0 = 5, doble = 10, + letal d8 (7) = 17.
	var resultado: ResultadoGolpe = Golpe.resolver(atacante, objetivo, estoque, DadosFijos.new([20, 5, 7]), [atacante, objetivo], LineaVision.new(grilla))
	assert_bool(resultado.critico).is_true()
	assert_int(resultado.danio_letal).is_equal(7)
	assert_int(resultado.danio).is_equal(17)


func test_letal_no_aplica_sin_critico() -> void:
	var grilla: GrillaMapa = GrillaMapa.new(Rect2i(0, 0, 5, 5))
	for x in 5:
		for y in 5:
			grilla.set_transitable(Vector2i(x, y), true)
	var personaje: DefinicionPersonaje = DefinicionPersonaje.new()
	personaje.ataques = {DefinicionArma.Categoria.MARCIAL: E}
	var estoque: DefinicionArma = _arma(DefinicionArma.Categoria.MARCIAL, &"estoque")
	estoque.caras_dado = 6
	estoque.letal_caras = 8
	personaje.armas = [estoque]
	var atacante: Combatiente = Combatiente.desde_personaje(&"a", personaje, Vector2i(1, 1))
	var objetivo: Combatiente = Combatiente.desde_criatura(&"e", load("res://data/criaturas/enemigo_prueba_cuerpo_a_cuerpo.tres"), Vector2i(2, 1))
	var resultado: ResultadoGolpe = Golpe.resolver(atacante, objetivo, estoque, DadosFijos.new([15, 5]), [atacante, objetivo], LineaVision.new(grilla))
	assert_bool(resultado.critico).is_false()
	assert_int(resultado.danio_letal).is_equal(0)

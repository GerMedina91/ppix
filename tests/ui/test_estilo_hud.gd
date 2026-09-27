extends GdUnitTestSuite
## El aspecto del combate sale del EstiloHud (sin colores ni tamaños sueltos en la lógica).


func test_el_tema_toma_fuente_tamano_y_fondo_del_estilo() -> void:
	var estilo: EstiloHud = EstiloHud.new()
	estilo.tamano_fuente = 14
	estilo.color_fondo = Color(0.1, 0.2, 0.3, 0.4)
	var tema: Theme = estilo.tema()
	assert_int(tema.default_font_size).is_equal(14)
	assert_that((tema.get_stylebox("panel", "PanelContainer") as StyleBoxFlat).bg_color).is_equal(Color(0.1, 0.2, 0.3, 0.4))


func test_color_por_zancadas_de_1_a_3() -> void:
	var estilo: EstiloHud = EstiloHud.new()
	assert_that(estilo.color_zancadas(1)).is_equal(estilo.resaltado_zancadas[0])
	assert_that(estilo.color_zancadas(3)).is_equal(estilo.resaltado_zancadas[2])


func test_la_config_sin_estilo_usa_el_de_por_defecto() -> void:
	var config: ConfigCombate = ConfigCombate.new()
	assert_object(config.estilo_efectivo()).is_not_null()
	assert_object(config.estilo_efectivo()).is_same(config.estilo_efectivo())


func test_la_config_del_juego_trae_su_estilo() -> void:
	var config: ConfigCombate = load("res://data/config/config_combate.tres")
	assert_object(config.estilo).is_not_null()

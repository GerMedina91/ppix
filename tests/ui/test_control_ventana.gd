extends GdUnitTestSuite


func test_desde_ventana_pasa_a_pantalla_completa() -> void:
	for actual: DisplayServer.WindowMode in [DisplayServer.WINDOW_MODE_WINDOWED, DisplayServer.WINDOW_MODE_MAXIMIZED, DisplayServer.WINDOW_MODE_MINIMIZED]:
		assert_int(ControlVentana.modo_siguiente(actual)).is_equal(DisplayServer.WINDOW_MODE_FULLSCREEN)


func test_desde_pantalla_completa_vuelve_a_ventana() -> void:
	for actual: DisplayServer.WindowMode in [DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN]:
		assert_int(ControlVentana.modo_siguiente(actual)).is_equal(DisplayServer.WINDOW_MODE_WINDOWED)

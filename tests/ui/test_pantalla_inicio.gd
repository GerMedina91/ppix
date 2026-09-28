extends GdUnitTestSuite
## Pantalla de inicio (M4g): Continuar solo si hay partida; Nueva partida confirma si pisa la existente.


func before_test() -> void:
	SaveSystem.borrar()


func after_test() -> void:
	SaveSystem.borrar()
	GameState.nueva_partida()


func test_sin_partida_continuar_esta_deshabilitado() -> void:
	var inicio: PantallaInicio = auto_free(load("res://scenes/ui/inicio.tscn").instantiate())
	add_child(inicio)
	var continuar: Button = inicio.find_children("*", "Button", true, false)[0]
	assert_str(continuar.text).is_equal("Continuar")
	assert_bool(continuar.disabled).is_true()


func test_con_partida_nueva_partida_pide_confirmacion() -> void:
	GameState.nueva_partida()
	SaveSystem.guardar()
	var inicio: PantallaInicio = auto_free(load("res://scenes/ui/inicio.tscn").instantiate())
	add_child(inicio)
	assert_array(Array(inicio.botones())).is_equal(["Continuar", "Nueva partida", "Pantalla completa"])
	inicio.nueva_partida()
	assert_array(Array(inicio.botones())).is_equal(["Sí, empezar de nuevo", "No"])
	assert_bool(SaveSystem.hay_partida()).is_true()

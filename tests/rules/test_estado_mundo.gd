extends GdUnitTestSuite
## Lo que no se revierte en los mapas: encuentros resueltos y enemigos retirados.


func test_registra_por_mapa_y_vuelve_por_json() -> void:
	var mundo: EstadoMundo = EstadoMundo.new()
	mundo.resolver_encuentro(&"mapa_b", &"encuentro_prueba")
	mundo.retirar_enemigo(&"mapa_b", &"EnemigoDistancia")
	assert_bool(mundo.encuentro_resuelto(&"mapa_b", &"encuentro_prueba")).is_true()
	assert_bool(mundo.encuentro_resuelto(&"mapa_a", &"encuentro_prueba")).is_false()
	var cargado: EstadoMundo = EstadoMundo.desde_diccionario(JSON.parse_string(JSON.stringify(mundo.a_diccionario())))
	assert_bool(cargado.enemigo_retirado(&"mapa_b", &"EnemigoDistancia")).is_true()
	assert_bool(cargado.encuentro_resuelto(&"mapa_b", &"encuentro_prueba")).is_true()

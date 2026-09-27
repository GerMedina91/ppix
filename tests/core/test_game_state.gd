extends GdUnitTestSuite
## Serialización de GameState a JSON (lo que existe hasta M4c; M4g suma la party y el RNG).

const GameStateScript: GDScript = preload("res://core/game_state.gd")


func test_ida_y_vuelta_por_json() -> void:
	var estado: Node = auto_free(GameStateScript.new())
	estado.id_ultimo_punto_estable = &"punto_a"
	estado.id_mapa_ultimo_punto_estable = &"mapa_a"
	estado.suenos_vistos.append(&"sueno_placeholder_1")
	var texto: String = JSON.stringify(estado.a_diccionario())
	var cargado: Node = auto_free(GameStateScript.new())
	cargado.cargar_diccionario(JSON.parse_string(texto), CatalogoRecuerdos.new())
	assert_str(cargado.id_ultimo_punto_estable).is_equal("punto_a")
	assert_str(cargado.id_mapa_ultimo_punto_estable).is_equal("mapa_a")
	assert_array(cargado.suenos_vistos).contains_exactly([&"sueno_placeholder_1"])

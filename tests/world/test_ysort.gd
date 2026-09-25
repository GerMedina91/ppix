extends GdUnitTestSuite
## La party y las paredes solo se ordenan juntas si toda la cadena de nodos tiene y-sort.

const ESCENA: String = "res://scenes/world/mundo.tscn"

var _runner: GdUnitSceneRunner


func before_test() -> void:
	_runner = scene_runner(ESCENA)


func test_cadena_de_y_sort_completa() -> void:
	var mundo: Node2D = _runner.scene()
	var contenedor: Node2D = _runner.find_child("MapaActual")
	var mapa: Node2D = contenedor.get_child(0)
	for nodo: CanvasItem in [mundo, contenedor, mapa, mapa.get_node("Paredes"), _runner.find_child("Party")]:
		assert_bool(nodo.y_sort_enabled).override_failure_message("%s sin y_sort_enabled" % nodo.name).is_true()


func test_suelo_se_dibuja_debajo_de_todo() -> void:
	var mapa: Node2D = _runner.find_child("MapaActual").get_child(0)
	var suelo: TileMapLayer = mapa.get_node("Suelo")
	assert_bool(suelo.y_sort_enabled).is_false()
	assert_int(suelo.z_index).is_less(0)

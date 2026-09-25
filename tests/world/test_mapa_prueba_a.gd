extends GdUnitTestSuite
## Test de integración: el mapa de prueba A arma una grilla coherente con sus tiles y marcadores.

const ESCENA: String = "res://scenes/world/mapas/mapa_prueba_a.tscn"

var _mapa: Mapa
var _grilla: GrillaMapa


func before_test() -> void:
	_mapa = auto_free(load(ESCENA).instantiate())
	add_child(_mapa)
	_grilla = _mapa.construir_grilla()


func test_region_cubre_todo_el_mapa() -> void:
	assert_that(_grilla.region()).is_equal(Rect2i(0, 0, 20, 12))


func test_paredes_del_borde_no_son_transitables() -> void:
	assert_bool(_grilla.es_transitable(Vector2i(0, 0))).is_false()
	assert_bool(_grilla.es_transitable(Vector2i(10, 11))).is_false()


func test_entradas_y_salida_son_transitables() -> void:
	assert_bool(_grilla.es_transitable(_mapa.celda_de_entrada(&"inicio"))).is_true()
	assert_bool(_grilla.es_transitable(_mapa.celda_de_entrada(&"desde_b"))).is_true()
	assert_bool(_grilla.es_transitable(Vector2i(19, 5))).is_true()


func test_salida_se_encuentra_por_celda() -> void:
	var salida: SalidaMapa = _mapa.salida_en(Vector2i(19, 5))
	assert_object(salida).is_not_null()
	assert_str(salida.id_mapa_destino).is_equal("mapa_prueba_b")
	assert_object(_mapa.salida_en(Vector2i(5, 5))).is_null()


func test_hay_camino_de_la_entrada_a_la_salida() -> void:
	var camino: Array[Vector2i] = _grilla.camino(_mapa.celda_de_entrada(&"inicio"), Vector2i(19, 5))
	assert_array(camino).is_not_empty()

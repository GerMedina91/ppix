extends GdUnitTestSuite
## Integración de la cámara con el mapa isométrico de prueba A.

const ESCENA: String = "res://scenes/world/mundo.tscn"
const ESPERA_MS: int = 8000

var _runner: GdUnitSceneRunner
var _party: ControlParty
var _camara: CamaraMundo
var _mapa: Mapa


func before_test() -> void:
	_runner = scene_runner(ESCENA)
	_party = _runner.find_child("Party")
	_camara = _runner.find_child("Camara")
	_mapa = _runner.find_child("MapaActual").get_child(0)


func _rect_visible() -> Rect2:
	var tamano: Vector2 = _camara.get_viewport_rect().size / _camara.zoom
	return Rect2(_camara.get_screen_center_position() - tamano / 2.0, tamano)


func test_limites_envuelven_el_mapa() -> void:
	var rect: Rect2 = _mapa.rect_global()
	assert_int(_camara.limit_left).is_equal(roundi(rect.position.x))
	assert_int(_camara.limit_top).is_equal(roundi(rect.position.y))
	assert_int(_camara.limit_right).is_equal(roundi(rect.end.x))
	assert_int(_camara.limit_bottom).is_equal(roundi(rect.end.y))


func test_la_vista_no_sale_del_mapa_en_las_esquinas(celda: Vector2i, test_parameters := [
		[Vector2i(1, 10)], [Vector2i(18, 1)], [Vector2i(1, 1)], [Vector2i(18, 10)],
	]) -> void:
	_party.ir_a_celda(celda)
	await _runner.await_func_on(_party, "celda_lider").wait_until(ESPERA_MS).is_equal(celda)
	await _runner.await_func_on(_party.lider(), "esta_moviendose").wait_until(ESPERA_MS).is_false()
	await _runner.simulate_frames(5)
	var visible: Rect2 = _rect_visible()
	assert_bool(_mapa.rect_global().grow(0.5).encloses(visible)) \
		.override_failure_message("Vista %s fuera del mapa %s" % [visible, _mapa.rect_global()]).is_true()

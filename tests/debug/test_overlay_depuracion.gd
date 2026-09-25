extends GdUnitTestSuite

const ESCENA: String = "res://scenes/world/mundo.tscn"

var _runner: GdUnitSceneRunner


func before_test() -> void:
	_runner = scene_runner(ESCENA)


func test_arranca_oculto_y_f3_lo_alterna() -> void:
	var overlay: OverlayDepuracion = _runner.find_child("OverlayDepuracion")
	assert_bool(overlay.visible).is_false()
	_runner.simulate_action_pressed(OverlayDepuracion.ACCION)
	await _runner.simulate_frames(2)
	assert_bool(overlay.visible).is_true()
	_runner.simulate_action_pressed(OverlayDepuracion.ACCION)
	await _runner.simulate_frames(2)
	assert_bool(overlay.visible).is_false()


func test_trae_la_capa_de_oclusion_y_acepta_capas_nuevas() -> void:
	var overlay: OverlayDepuracion = _runner.find_child("OverlayDepuracion")
	assert_bool(overlay.capas().any(func(c: CapaDepuracion) -> bool: return c is CapaDepuracionOclusion)).is_true()
	overlay.registrar(CapaDepuracion.new())
	assert_int(overlay.capas().size()).is_equal(2)

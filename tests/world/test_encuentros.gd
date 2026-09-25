extends GdUnitTestSuite

const ESCENA: String = "res://scenes/world/mundo.tscn"
const ESPERA_MS: int = 8000


func test_zona_dispara_si_algun_miembro_esta_adentro() -> void:
	var zona: ZonaEncuentro = auto_free(ZonaEncuentro.new())
	zona.zona = Rect2i(5, 5, 2, 2)
	assert_bool(zona.debe_disparar([Vector2i(0, 0), Vector2i(6, 6)], null)).is_true()
	assert_bool(zona.debe_disparar([Vector2i(0, 0), Vector2i(7, 7)], null)).is_false()


func test_encuentro_resuelto_no_vuelve_a_dispararse() -> void:
	var encuentro: Encuentro = auto_free(Encuentro.new())
	var zona: ZonaEncuentro = ZonaEncuentro.new()
	zona.zona = Rect2i(0, 0, 3, 3)
	encuentro.add_child(zona)
	assert_bool(encuentro.evaluar([Vector2i(1, 1)])).is_true()
	encuentro.resuelto = true
	assert_bool(encuentro.evaluar([Vector2i(1, 1)])).is_false()


func test_un_disparador_generico_nuevo_funciona_sin_tocar_nada() -> void:
	var encuentro: Encuentro = auto_free(Encuentro.new())
	encuentro.add_child(_SiempreDispara.new())
	assert_bool(encuentro.evaluar([])).is_true()


func test_el_mapa_a_tiene_el_encuentro_de_prueba_con_dos_enemigos() -> void:
	var runner: GdUnitSceneRunner = scene_runner(ESCENA)
	var mapa: Mapa = runner.find_child("MapaActual").get_child(0)
	var encuentros: Array[Encuentro] = mapa.encuentros()
	assert_int(encuentros.size()).is_equal(1)
	var celdas: Array = encuentros[0].enemigos().map(func(e: EnemigoEnMapa) -> Vector2i: return e.celda)
	assert_array(celdas).contains_exactly([Vector2i(13, 8), Vector2i(16, 9)])


func test_caminar_hasta_la_zona_dispara_el_encuentro() -> void:
	var runner: GdUnitSceneRunner = scene_runner(ESCENA)
	var mundo: Node = runner.scene()
	monitor_signals(mundo)
	(runner.find_child("Party") as ControlParty).ir_a_celda(Vector2i(10, 5))
	await assert_signal(mundo).wait_until(ESPERA_MS).is_emitted("encuentro_disparado", [any()])


func test_en_exploracion_no_se_camina_a_traves_de_los_enemigos() -> void:
	var runner: GdUnitSceneRunner = scene_runner(ESCENA)
	var party: ControlParty = runner.find_child("Party")
	party.ir_a_celda(Vector2i(13, 8))
	await runner.simulate_frames(10)
	assert_that(party.celda_lider()).is_equal(Vector2i(3, 5))


class _SiempreDispara extends DisparadorEncuentro:
	func debe_disparar(_celdas: Array[Vector2i], _encuentro: Encuentro) -> bool:
		return true

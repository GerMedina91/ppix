extends GdUnitTestSuite

const ESCENA: String = "res://scenes/world/mundo.tscn"
const ESPERA_MS: int = 8000
const FRAMES_MAXIMOS: int = 3000


## Cruza del mapa A al B (donde está el encuentro de prueba) y espera a que la party se pueda mover.
func _ir_al_mapa_b(runner: GdUnitSceneRunner) -> void:
	var party: ControlParty = runner.find_child("Party")
	party.ir_a_celda(Vector2i(19, 5))
	for i in FRAMES_MAXIMOS:
		if GameState.id_mapa_actual == &"mapa_prueba_b" and not party.bloqueado:
			return
		await runner.simulate_frames(1)
	fail("no se llegó al mapa B")


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


func test_el_mapa_b_tiene_el_encuentro_de_prueba_con_dos_enemigos() -> void:
	var runner: GdUnitSceneRunner = scene_runner(ESCENA)
	await _ir_al_mapa_b(runner)
	var mapa: Mapa = runner.find_child("MapaActual").get_child(0)
	var encuentros: Array[Encuentro] = mapa.encuentros()
	assert_int(encuentros.size()).is_equal(1)
	var celdas: Array = encuentros[0].enemigos().map(func(e: EnemigoEnMapa) -> Vector2i: return e.celda)
	assert_array(celdas).contains_exactly([Vector2i(20, 9), Vector2i(24, 11)])


func test_el_mapa_a_no_tiene_encuentros() -> void:
	var runner: GdUnitSceneRunner = scene_runner(ESCENA)
	assert_array((runner.find_child("MapaActual").get_child(0) as Mapa).encuentros()).is_empty()


func test_caminar_hasta_la_zona_dispara_el_encuentro() -> void:
	var runner: GdUnitSceneRunner = scene_runner(ESCENA)
	await _ir_al_mapa_b(runner)
	var mundo: Node = runner.scene()
	monitor_signals(mundo)
	(runner.find_child("Party") as ControlParty).ir_a_celda(Vector2i(13, 10))
	await assert_signal(mundo).wait_until(ESPERA_MS).is_emitted("encuentro_disparado", [any()])


func test_en_exploracion_no_se_camina_a_traves_de_los_enemigos() -> void:
	var runner: GdUnitSceneRunner = scene_runner(ESCENA)
	await _ir_al_mapa_b(runner)
	var party: ControlParty = runner.find_child("Party")
	var antes: Vector2i = party.celda_lider()
	party.ir_a_celda(Vector2i(20, 9))
	await runner.simulate_frames(10)
	assert_that(party.celda_lider()).is_equal(antes)


class _SiempreDispara extends DisparadorEncuentro:
	func debe_disparar(_celdas: Array[Vector2i], _encuentro: Encuentro) -> bool:
		return true

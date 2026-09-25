extends GdUnitTestSuite
## Test de integración de las transiciones entre los mapas de prueba A y B.

const ESCENA: String = "res://scenes/world/mundo.tscn"
const SALIDA_A_HACIA_B: Vector2i = Vector2i(19, 5)
const ENTRADA_B_DESDE_A: Vector2i = Vector2i(1, 10)
const SALIDA_B_HACIA_A: Vector2i = Vector2i(0, 10)
const ENTRADA_A_DESDE_B: Vector2i = Vector2i(18, 5)
const ESPERA_MS: int = 8000
const MAX_FRAMES_DESBLOQUEO: int = 300

var _runner: GdUnitSceneRunner
var _party: ControlParty


func before_test() -> void:
	_runner = scene_runner(ESCENA)
	_party = _runner.find_child("Party")
	# false: no liberar el autoload al terminar el test
	monitor_signals(EventBus, false)


func _esperar_desbloqueo() -> void:
	for i in MAX_FRAMES_DESBLOQUEO:
		if not _party.bloqueado:
			return
		await _runner.simulate_frames(1)
	fail("La party quedó bloqueada después de la transición")


func _ir_a_b() -> void:
	_party.ir_a_celda(SALIDA_A_HACIA_B)
	await assert_signal(EventBus).wait_until(ESPERA_MS).is_emitted("mapa_cambiado", [&"mapa_prueba_b"])


func test_pisar_la_salida_lleva_al_mapa_b() -> void:
	await _ir_a_b()
	assert_str(GameState.id_mapa_actual).is_equal("mapa_prueba_b")
	assert_that(_party.celda_lider()).is_equal(ENTRADA_B_DESDE_A)
	await _esperar_desbloqueo()
	assert_that(_party.celda_lider()).is_equal(ENTRADA_B_DESDE_A)


func test_ida_y_vuelta() -> void:
	await _ir_a_b()
	await _esperar_desbloqueo()
	_party.ir_a_celda(SALIDA_B_HACIA_A)
	await assert_signal(EventBus).wait_until(ESPERA_MS).is_emitted("mapa_cambiado", [&"mapa_prueba_a"])
	assert_str(GameState.id_mapa_actual).is_equal("mapa_prueba_a")
	assert_that(_party.celda_lider()).is_equal(ENTRADA_A_DESDE_B)


func test_la_entrada_se_ignora_durante_la_transicion() -> void:
	await _ir_a_b()
	assert_bool(_party.bloqueado).is_true()
	_party.ir_a_celda(Vector2i(5, 10))
	await _esperar_desbloqueo()
	await _runner.simulate_frames(20)
	assert_that(_party.celda_lider()).is_equal(ENTRADA_B_DESDE_A)

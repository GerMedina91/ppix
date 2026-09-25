extends GdUnitTestSuite
## Test de integración del movimiento de la party en el mundo, arrancando en el mapa de prueba A.

const ESCENA: String = "res://scenes/world/mundo.tscn"
const ENTRADA_INICIAL: Vector2i = Vector2i(3, 5)
const ESPERA_MS: int = 5000

var _runner: GdUnitSceneRunner
var _party: ControlParty


func before_test() -> void:
	_runner = scene_runner(ESCENA)
	_party = _runner.find_child("Party")


func _esperar_quieto() -> void:
	await _runner.await_func_on(_party.lider(), "esta_moviendose").wait_until(ESPERA_MS).is_false()


func test_arranca_en_la_entrada_inicial() -> void:
	assert_that(_party.celda_lider()).is_equal(ENTRADA_INICIAL)


func test_click_lleva_al_lider_rodeando_paredes() -> void:
	_party.ir_a_celda(Vector2i(10, 2))
	await _runner.await_func_on(_party, "celda_lider").wait_until(ESPERA_MS).is_equal(Vector2i(10, 2))
	await _esperar_quieto()
	assert_that(_party.celda_lider()).is_equal(Vector2i(10, 2))


func test_click_en_pared_no_mueve() -> void:
	_party.ir_a_celda(Vector2i(0, 0))
	await _runner.simulate_frames(10)
	assert_bool(_party.lider().esta_moviendose()).is_false()
	assert_that(_party.celda_lider()).is_equal(ENTRADA_INICIAL)


func test_teclado_mueve_y_se_detiene_contra_la_pared() -> void:
	# Desde (3,5) hacia la izquierda: (2,5), (1,5) y después la pared en (0,5).
	_runner.simulate_action_press("mover_izquierda")
	await _runner.await_func_on(_party, "celda_lider").wait_until(ESPERA_MS).is_equal(Vector2i(1, 5))
	await _esperar_quieto()
	await _runner.simulate_frames(20)
	_runner.simulate_action_release("mover_izquierda")
	assert_that(_party.celda_lider()).is_equal(Vector2i(1, 5))


func test_teclado_cancela_el_camino_del_click() -> void:
	_party.ir_a_celda(Vector2i(18, 5))
	# El primer paso del camino arranca en el acto; el teclado toma el control desde esa celda.
	var primer_paso: Vector2i = _party.celda_lider()
	_runner.simulate_action_press("mover_abajo")
	await _runner.await_func_on(_party, "celda_lider").wait_until(ESPERA_MS).is_equal(primer_paso + Vector2i(0, 2))
	_runner.simulate_action_release("mover_abajo")
	await _esperar_quieto()
	await _runner.simulate_frames(20)
	assert_bool(_party.lider().esta_moviendose()).is_false()
	assert_that(_party.celda_lider()).is_not_equal(Vector2i(18, 5))

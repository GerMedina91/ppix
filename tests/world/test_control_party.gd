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


func _mantener_teclas(acciones: Array[String], celda_esperada: Vector2i) -> void:
	for accion in acciones:
		_runner.simulate_action_press(accion)
	await _runner.await_func_on(_party, "celda_lider").wait_until(ESPERA_MS).is_equal(celda_esperada)
	await _esperar_quieto()
	await _runner.simulate_frames(20)
	for accion in acciones:
		_runner.simulate_action_release(accion)


func test_tecla_izquierda_va_a_la_izquierda_de_la_pantalla() -> void:
	# Izquierda de pantalla = paso de grilla (-1, +1). Desde (3,5): (2,6), (1,7) y pared en (0,8).
	await _mantener_teclas(["mover_izquierda"], Vector2i(1, 7))
	assert_that(_party.celda_lider()).is_equal(Vector2i(1, 7))


func test_dos_teclas_dan_un_paso_ortogonal() -> void:
	# Arriba + derecha de pantalla = paso de grilla (0, -1). Desde (3,5) hasta la pared en (3,0).
	await _mantener_teclas(["mover_arriba", "mover_derecha"], Vector2i(3, 1))
	assert_that(_party.celda_lider()).is_equal(Vector2i(3, 1))


func test_el_teclado_no_corta_esquinas() -> void:
	# En (4,3), derecha de pantalla = (5,2): libre, pero la esquina (5,3) es pared.
	_party.ir_a_celda(Vector2i(4, 3))
	await _runner.await_func_on(_party, "celda_lider").wait_until(ESPERA_MS).is_equal(Vector2i(4, 3))
	await _esperar_quieto()
	_runner.simulate_action_press("mover_derecha")
	await _runner.simulate_frames(30)
	_runner.simulate_action_release("mover_derecha")
	assert_that(_party.celda_lider()).is_equal(Vector2i(4, 3))


func test_teclado_cancela_el_camino_del_click() -> void:
	_party.ir_a_celda(Vector2i(18, 5))
	# El primer paso del camino arranca en el acto; el teclado toma el control desde esa celda.
	var primer_paso: Vector2i = _party.celda_lider()
	await _mantener_teclas(["mover_arriba"], primer_paso + Vector2i(-2, -2))
	assert_bool(_party.lider().esta_moviendose()).is_false()
	assert_that(_party.celda_lider()).is_not_equal(Vector2i(18, 5))


func test_la_party_sigue_en_fila_india() -> void:
	# Desde (3,5) hasta (7,5) en línea recta: 4 pasos, alcanza para desplegar a los 4 miembros.
	_party.ir_a_celda(Vector2i(7, 5))
	await _runner.await_func_on(_party, "celda_lider").wait_until(ESPERA_MS).is_equal(Vector2i(7, 5))
	await _esperar_quieto()
	await _runner.simulate_frames(5)
	var celdas: Array[Vector2i] = []
	for miembro: Node in _party.get_children():
		celdas.append((miembro as MiembroParty).celda)
	assert_array(celdas).is_equal([Vector2i(7, 5), Vector2i(6, 5), Vector2i(5, 5), Vector2i(4, 5)])

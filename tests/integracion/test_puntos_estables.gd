extends GdUnitTestSuite
## Punto estable del mapa de prueba A (en (4,9)): click, la party camina al lado, se abre el panel y descansa.

const ESCENA: String = "res://tests/escenas/mundo_prueba.tscn"
const CELDA_PUNTO: Vector2i = Vector2i(4, 9)
const ESPERA_MS: int = 5000

var _runner: GdUnitSceneRunner
var _party: ControlParty
var _panel: PanelPuntoEstable


func before_test() -> void:
	GameState.nueva_partida()
	_runner = scene_runner(ESCENA)
	_party = _runner.find_child("Party")
	_panel = _runner.find_child("PanelPuntoEstable")


func after_test() -> void:
	GameState.estado_party.clear()
	GameState.suenos_vistos.clear()


func _punto() -> PuntoEstable:
	return _runner.find_child("PuntoEstablePrueba")


func _ir_y_abrir() -> void:
	_party.ir_a_interactuar(_punto())
	await _runner.await_func_on(_panel, "abierto").wait_until(ESPERA_MS).is_true()


func test_el_punto_ocupa_su_casilla() -> void:
	assert_that(_punto().celda).is_equal(CELDA_PUNTO)
	assert_bool(_party.grilla().es_transitable(CELDA_PUNTO)).is_false()


func test_la_party_camina_al_lado_y_se_abre_el_panel() -> void:
	await _ir_y_abrir()
	var distancia: Vector2i = (_party.celda_lider() - CELDA_PUNTO).abs()
	assert_int(maxi(distancia.x, distancia.y)).is_equal(1)
	assert_bool(_party.bloqueado).is_true()
	_panel.cerrar()
	assert_bool(_party.bloqueado).is_false()


func test_descansar_recupera_y_registra_el_punto() -> void:
	GameState.estado_party[&"Miembro2"] = {"pg": 3, "herido": 1}
	GameState.estado_party[&"Miembro3"] = {"pg": 0, "herido": 1, "muerto": true}
	await _ir_y_abrir()
	_panel.descansar()
	assert_bool(GameState.estado_party.has(&"Miembro2")).is_false()
	assert_bool(GameState.estado_party[&"Miembro3"].muerto).is_true()
	assert_str(GameState.id_ultimo_punto_estable).is_equal("punto_estable_prueba_a")
	assert_str(GameState.id_mapa_ultimo_punto_estable).is_equal("mapa_prueba_a")


func test_otro_click_cancela_la_interaccion() -> void:
	_party.ir_a_interactuar(_punto())
	_party.ir_a_celda(Vector2i(10, 2))
	await _runner.await_func_on(_party, "celda_lider").wait_until(ESPERA_MS).is_equal(Vector2i(10, 2))
	await _runner.simulate_frames(10)
	assert_bool(_panel.abierto()).is_false()


func test_al_descansar_suena_una_vez_cada_sueno() -> void:
	var avisados: Array[StringName] = []
	var al_sonar: Callable = func(id: StringName) -> void: avisados.append(id)
	EventBus.sueno_en_descanso.connect(al_sonar)
	await _ir_y_abrir()
	_panel.descansar()
	_panel.cerrar()
	_party.ir_a_interactuar(_punto())
	await _runner.await_func_on(_panel, "abierto").wait_until(ESPERA_MS).is_true()
	_panel.descansar()
	EventBus.sueno_en_descanso.disconnect(al_sonar)
	assert_array(avisados).contains_exactly([&"sueno_placeholder_1", &"sueno_placeholder_2"])
	assert_array(GameState.suenos_vistos).contains_exactly([&"sueno_placeholder_1", &"sueno_placeholder_2"])

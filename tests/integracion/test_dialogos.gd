extends GdUnitTestSuite
## Diálogos con Dialogue Manager (M5-prep b): Tasador (presentación obligatoria y después comercio con
## "Hablar"), compañeros en el punto estable y disparadores de diálogo con condición.

const ESCENA: String = "res://scenes/world/mundo.tscn"
const FRAMES_MAXIMOS: int = 3000

var _runner: GdUnitSceneRunner
var _party: ControlParty
var _caja: CajaDialogo


func before_test() -> void:
	GameState.nueva_partida()
	_runner = scene_runner(ESCENA)
	_party = _runner.find_child("Party")
	_caja = _runner.find_child("CajaDialogo")


func after_test() -> void:
	await _runner.simulate_frames(2)  # libera los botones reemplazados (queue_free)
	GameState.nueva_partida()


func _esperar(condicion: Callable) -> bool:
	for i in FRAMES_MAXIMOS:
		if condicion.call():
			return true
		await _runner.simulate_frames(1)
	return false


func _avanzar_hasta_opciones() -> void:
	for i in 10:
		if not _caja.opciones().is_empty():
			return
		_caja.avanzar()
		await _runner.simulate_frames(2)


func test_el_tasador_se_presenta_la_primera_vez_y_despues_abre_el_comercio() -> void:
	var tasador: PantallaTasador = _runner.find_child("PantallaTasador")
	_party.ir_a_interactuar(_runner.find_child("Tasador"))
	assert_bool(await _esperar(func() -> bool: return _caja.abierta())).is_true()
	assert_bool(tasador.abierta()).is_false()
	assert_str(_caja.texto_actual()).is_equal("Tasador: TODO_LORE: el Tasador se presenta la primera vez.")
	await _avanzar_hasta_opciones()
	assert_array(Array(_caja.opciones())).is_equal(["Comerciar", "Irse"])
	_caja.elegir(0)
	assert_bool(await _esperar(func() -> bool: return tasador.abierta())).is_true()
	assert_bool(GameState.marcas.has(&"tasador_presentado")).is_true()
	# La segunda vez: comercio directo, y "Hablar" abre la charla.
	tasador.cerrar()
	_party.ir_a_interactuar(_runner.find_child("Tasador"))
	assert_bool(await _esperar(func() -> bool: return tasador.abierta())).is_true()
	assert_bool(_caja.abierta()).is_false()
	tasador.hablar_pedido.emit()
	assert_bool(await _esperar(func() -> bool: return _caja.abierta())).is_true()
	await _avanzar_hasta_opciones()
	var boton_fragmentos: Button = _caja.find_children("*", "Button", true, false)[0]
	assert_bool(boton_fragmentos.disabled).is_true()
	assert_str(boton_fragmentos.tooltip_text).is_equal("todavía no viste ningún fragmento")
	_caja.elegir(2)  # Irse
	assert_bool(await _esperar(func() -> bool: return not _caja.abierta())).is_true()
	assert_bool(_party.bloqueado).is_false()


func test_en_el_punto_estable_se_habla_con_los_companeros_vivos() -> void:
	GameState.estado_party[&"Miembro3"] = {"pg": 0, "herido": 1, "muerto": true}
	var panel: PanelPuntoEstable = _runner.find_child("PanelPuntoEstable")
	_party.ir_a_interactuar(_runner.find_child("PuntoEstablePrueba"))
	assert_bool(await _esperar(func() -> bool: return panel.abierto())).is_true()
	assert_array(Array(panel.opciones())).is_equal(["Hablar con Irsa", "Hablar con Vaisha"])
	panel.hablar(&"Miembro2")
	assert_bool(await _esperar(func() -> bool: return _caja.abierta())).is_true()
	assert_str(_caja.texto_actual()).is_equal("Irsa: TODO_LORE: Irsa habla en el punto estable.")
	await _avanzar_hasta_opciones()
	_caja.elegir(2)  # Nada
	assert_bool(await _esperar(func() -> bool: return panel.abierto())).is_true()


func test_el_disparador_respeta_la_condicion_y_una_vez() -> void:
	var mapa: Mapa = _runner.find_child("MapaActual").get_child(0)
	var disparador: DisparadorDialogo = (load("res://scenes/world/objetos/disparador_dialogo.tscn") as PackedScene).instantiate()
	disparador.dialogo = "res://tests/utiles/prueba.dialogue"
	disparador.condicion = 'estado.vio_sueno("sueno_placeholder_1")'
	disparador.una_vez = true
	mapa.agregar_interactuable(disparador, Vector2i(8, 9))
	var interacciones: InteraccionesMundo = _runner.find_child("InteraccionesMundo")
	await interacciones.al_interactuar(disparador)
	assert_bool(_caja.abierta()).is_false()  # no se cumple la condición
	GameState.suenos_vistos.append(&"sueno_placeholder_1")
	interacciones.al_interactuar(disparador)
	assert_bool(await _esperar(func() -> bool: return _caja.abierta())).is_true()
	assert_str(_caja.texto_actual()).is_equal("TODO_LORE: diálogo de prueba de los tests.")
	_caja.avanzar()
	assert_bool(await _esperar(func() -> bool: return not _caja.abierta())).is_true()
	await interacciones.al_interactuar(disparador)
	assert_bool(_caja.abierta()).is_false()  # una sola vez

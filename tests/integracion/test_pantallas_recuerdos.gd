extends GdUnitTestSuite
## Pantallas de M4f: el trueque con el Tasador y los recuerdos del Eco con el diario.

const ESCENA: String = "res://tests/escenas/mundo_prueba.tscn"
const FRAMES_MAXIMOS: int = 3000

var _runner: GdUnitSceneRunner
var _party: ControlParty


func before_test() -> void:
	GameState.nueva_partida()
	_runner = scene_runner(ESCENA)
	_party = _runner.find_child("Party")


func after_test() -> void:
	GameState.nueva_partida()


func _esperar(condicion: Callable) -> bool:
	for i in FRAMES_MAXIMOS:
		if condicion.call():
			return true
		await _runner.simulate_frames(1)
	return false


func _recuerdo(nombre: String) -> DefinicionRecuerdo:
	return load("res://data/recuerdos/%s.tres" % nombre)


func test_el_tasador_vende_y_compra_con_credito() -> void:
	GameState.marcas[&"tasador_presentado"] = true  # la presentación se prueba en test_dialogos
	GameState.recuerdos.inventario.agregar_suelto(_recuerdo("destreza_sigilo"))
	GameState.recuerdos.inventario.agregar_suelto(_recuerdo("doliente_2"))
	var pantalla: PantallaTasador = _runner.find_child("PantallaTasador")
	_party.ir_a_interactuar(_runner.find_child("Tasador"))
	assert_bool(await _esperar(func() -> bool: return pantalla.abierta())).is_true()
	assert_bool(_party.bloqueado).is_true()
	# Sin crédito no se compra nada; el fragmento del Doliente no se vende.
	assert_array(Array(pantalla.botones())).contains(["Comprar (50)", "Vender (+15)", "Vender (+25)"])
	var barra_stock: Array = _deshabilitados(pantalla)
	assert_int(barra_stock.size()).is_equal(6)  # 5 del stock + el fragmento
	pantalla.vender(_recuerdo("destreza_sigilo"))
	assert_int(GameState.recuerdos.tasador.credito).is_equal(15)
	assert_str(pantalla.mensaje()).is_equal("Vendiste Entrenado en Sigilo (TODO_LORE) (+15 de crédito)")
	var indice: int = GameState.recuerdos.tasador.stock.find_custom(func(e: Tasador.Entrada) -> bool: return e.recuerdo.id == &"vivencia_1")
	pantalla.comprar(indice)
	assert_int(GameState.recuerdos.tasador.credito).is_equal(5)
	assert_bool(GameState.recuerdos.inventario.sueltos.has(_recuerdo("vivencia_1"))).is_true()
	pantalla.cerrar()
	assert_bool(_party.bloqueado).is_false()
	await _runner.simulate_frames(2)  # libera las filas reemplazadas (queue_free)


func test_recuerdos_integrar_ver_y_soltar_con_confirmacion() -> void:
	var inventario: InventarioRecuerdos = GameState.recuerdos.inventario
	inventario.agregar_suelto(_recuerdo("destreza_medicina"))
	inventario.agregar_suelto(_recuerdo("destreza_medicina_en_batalla"))
	inventario.agregar_suelto(_recuerdo("vivencia_2"))
	var hud: HudExploracion = _runner.find_child("HudExploracion")
	await _runner.simulate_frames(2)
	assert_bool(hud.boton_visible()).is_true()
	hud.recuerdos_pedidos.emit()
	var pantalla: PantallaRecuerdos = _runner.find_child("PantallaRecuerdos")
	assert_bool(pantalla.abierta()).is_true()
	# Medicina en batalla pide Medicina: todavía no se puede integrar.
	pantalla.integrar(_recuerdo("destreza_medicina_en_batalla"))
	assert_str(pantalla.mensaje()).is_equal("requiere estar entrenado en Medicina")
	pantalla.integrar(_recuerdo("destreza_medicina"))
	pantalla.integrar(_recuerdo("destreza_medicina_en_batalla"))
	assert_int(inventario.integrados.size()).is_equal(2)
	pantalla.integrar(_recuerdo("vivencia_2"))
	assert_bool(inventario.vistos.has(_recuerdo("vivencia_2"))).is_true()
	assert_str(pantalla.detalle()).contains("TODO_LORE")
	pantalla.mostrar(PantallaRecuerdos.Pestana.RECUERDOS)
	pantalla.soltar(_recuerdo("destreza_medicina_en_batalla"))
	assert_array(Array(pantalla.botones())).contains(["Confirmar: se pierde para siempre", "No"])
	assert_int(inventario.integrados.size()).is_equal(2)
	pantalla.soltar(_recuerdo("destreza_medicina_en_batalla"), true)
	assert_int(inventario.integrados.size()).is_equal(1)
	pantalla.cerrar()
	assert_bool(_party.bloqueado).is_false()
	await _runner.simulate_frames(2)  # libera las filas reemplazadas (queue_free)


func _deshabilitados(pantalla: PantallaTasador) -> Array:
	var lista: Array = []
	for boton: Node in pantalla.find_children("*", "Button", true, false):
		if (boton as Button).disabled:
			lista.append(boton)
	return lista


func test_la_tecla_r_abre_los_recuerdos_en_exploracion() -> void:
	await _runner.simulate_frames(2)
	_runner.simulate_action_pressed("abrir_recuerdos")
	await _runner.simulate_frames(2)
	var pantalla: PantallaRecuerdos = _runner.find_child("PantallaRecuerdos")
	assert_bool(pantalla.abierta()).is_true()
	assert_bool(_party.bloqueado).is_true()
	pantalla.cerrar()
	await _runner.simulate_frames(2)

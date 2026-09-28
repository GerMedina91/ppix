extends GdUnitTestSuite
## Guardado en el mundo (M4g): un combate cortado vuelve a empezar igual al cargar, la pérdida pendiente del Eco
## se vuelve a preguntar y los cambios irreversibles se guardan enseguida.

const ESCENA: String = "res://tests/escenas/mundo_prueba.tscn"
const FRAMES_MAXIMOS: int = 3000


func before_test() -> void:
	GameState.nueva_partida()
	GameState.reiniciar_dados(11)
	SaveSystem.borrar()


func after_test() -> void:
	SaveSystem.borrar()
	GameState.nueva_partida()


func _esperar(runner: GdUnitSceneRunner, condicion: Callable) -> bool:
	for i in FRAMES_MAXIMOS:
		if condicion.call():
			return true
		await runner.simulate_frames(1)
	return false


func _orden(control: ControladorCombate) -> Array:
	return control.combate().orden.map(func(c: Combatiente) -> String: return String(c.id))


func test_un_combate_cortado_vuelve_a_empezar_igual_al_cargar() -> void:
	var runner: GdUnitSceneRunner = scene_runner(ESCENA)
	(runner.find_child("PosicionamientoPrevio") as PosicionamientoPrevio).omitir = true  # (test_posicionamiento_previo)
	var party: ControlParty = runner.find_child("Party")
	var control: ControladorCombate = runner.find_child("ControladorCombate")
	party.ir_a_celda(Vector2i(19, 5))
	assert_bool(await _esperar(runner, func() -> bool: return GameState.id_mapa_actual == &"mapa_prueba_b" and not party.bloqueado)).is_true()
	party.ir_a_celda(Vector2i(13, 10))
	assert_bool(await _esperar(runner, func() -> bool: return control.en_curso())).is_true()
	var orden: Array = _orden(control)
	var celdas: Array = party.miembros().map(func(m: MiembroParty) -> Vector2i: return m.celda)
	# "Se cierra el juego": se carga la ranura en un mundo nuevo.
	GameState.nueva_partida()
	assert_bool(SaveSystem.cargar()).is_true()
	assert_str(GameState.combate_pendiente).is_equal("encuentro_prueba")
	var otro: GdUnitSceneRunner = scene_runner(ESCENA)
	(otro.find_child("PosicionamientoPrevio") as PosicionamientoPrevio).omitir = true  # (test_posicionamiento_previo)
	var control2: ControladorCombate = otro.find_child("ControladorCombate")
	assert_bool(await _esperar(otro, func() -> bool: return control2.en_curso())).is_true()
	assert_array(_orden(control2)).is_equal(orden)
	var party2: ControlParty = otro.find_child("Party")
	assert_array(party2.miembros().map(func(m: MiembroParty) -> Vector2i: return m.celda)).is_equal(celdas)


func test_la_perdida_pendiente_se_vuelve_a_preguntar_al_cargar() -> void:
	GameState.recuerdos.inventario.integrados.append(load("res://data/recuerdos/destreza_medicina.tres"))
	GameState.id_mapa_actual = &"mapa_prueba_a"
	GameState.ubicacion = {"celdas": {&"Miembro1": Vector2i(3, 5)}, "entrada": &"inicio"}
	GameState.perdida_pendiente = true
	GameState.recien_cargada = true
	var runner: GdUnitSceneRunner = scene_runner(ESCENA)
	(runner.find_child("PosicionamientoPrevio") as PosicionamientoPrevio).omitir = true  # (test_posicionamiento_previo)
	var panel: PanelPerdida = runner.find_child("PanelPerdida")
	assert_bool(await _esperar(runner, func() -> bool: return panel.abierto())).is_true()
	panel.elegir(GameState.recuerdos.inventario.integrados[0])
	await runner.simulate_frames(2)
	assert_bool(GameState.perdida_pendiente).is_false()
	# Quedó guardado enseguida.
	GameState.nueva_partida()
	assert_bool(SaveSystem.cargar()).is_true()
	assert_array(GameState.recuerdos.inventario.integrados).is_empty()
	assert_bool(GameState.perdida_pendiente).is_false()


func test_vender_al_tasador_guarda_enseguida() -> void:
	GameState.recuerdos.inventario.agregar_suelto(load("res://data/recuerdos/destreza_sigilo.tres"))
	var runner: GdUnitSceneRunner = scene_runner(ESCENA)
	(runner.find_child("PosicionamientoPrevio") as PosicionamientoPrevio).omitir = true  # (test_posicionamiento_previo)
	var pantalla: PantallaTasador = runner.find_child("PantallaTasador")
	await runner.simulate_frames(2)
	pantalla.abrir()
	pantalla.vender(load("res://data/recuerdos/destreza_sigilo.tres"))
	pantalla.cerrar()
	await runner.simulate_frames(2)
	GameState.nueva_partida()
	assert_bool(SaveSystem.cargar()).is_true()
	assert_int(GameState.recuerdos.tasador.credito).is_equal(15)
	assert_array(GameState.recuerdos.inventario.sueltos).is_empty()

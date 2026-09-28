extends GdUnitTestSuite
## El slice con el mundo real (M5): la partida nueva empieza en Kardel; en el linde, los humanos vencidos quedan
## inconscientes y se decide qué hacer con ellos; en el corazón, tomar el fragmento 2 cierra el slice.

const ESCENA: String = "res://scenes/world/mundo.tscn"
const FRAMES_MAXIMOS: int = 3000

var _runner: GdUnitSceneRunner
var _party: ControlParty


func after_test() -> void:
	GameState.nueva_partida()


func _arrancar(cargada_en: StringName = &"", celda: Vector2i = Vector2i.ZERO) -> void:
	GameState.nueva_partida()
	GameState.reiniciar_dados(5)
	if cargada_en != &"":
		GameState.id_mapa_actual = cargada_en
		GameState.ubicacion = {"celdas": {&"Miembro1": celda}, "entrada": &""}
		GameState.recien_cargada = true
	_runner = scene_runner(ESCENA)
	(_runner.find_child("PosicionamientoPrevio") as PosicionamientoPrevio).omitir = true
	(_runner.find_child("PantallaFinSlice") as PantallaFinSlice).solo_avisar = true
	_party = _runner.find_child("Party")
	await _runner.simulate_frames(2)


func _esperar(condicion: Callable) -> bool:
	for i in FRAMES_MAXIMOS:
		if condicion.call():
			return true
		await _runner.simulate_frames(1)
	return false


func test_la_partida_nueva_empieza_en_kardel() -> void:
	await _arrancar()
	assert_str(String(GameState.id_mapa_actual)).is_equal("kardel")
	assert_object(_runner.find_child("LumbreFarol")).is_not_null()


func test_los_humanos_del_linde_quedan_inconscientes_y_se_decide() -> void:
	await _arrancar(&"linde_del_monte", Vector2i(8, 7))
	var control: ControladorCombate = _runner.find_child("ControladorCombate")
	_party.ir_a_celda(Vector2i(12, 7))
	assert_bool(await _esperar(func() -> bool: return control.esperando_decision())).is_true()
	var combate: Combate = control.combate()
	for id: StringName in [&"HumanoHoz1", &"HumanoHoz2", &"HumanoArco"]:
		var humano: Combatiente = combate.combatiente(id)
		humano.recibir_danio(humano.pg, false)  # letal: igual quedan inconscientes
		assert_bool(humano.condiciones.muerto).is_false()
	control._encolar(combate.verificar_fin())
	var panel: PanelOpciones = _runner.find_child("PanelOpciones")
	assert_bool(await _esperar(func() -> bool: return panel.abierto())).is_true()
	assert_array(Array(panel.opciones())).contains_exactly(["Extraer", "Perdonar", "Rematar"])


func test_tomar_el_fragmento_2_cierra_el_slice() -> void:
	await _arrancar(&"corazon_del_monte", Vector2i(16, 21))
	var fin: PantallaFinSlice = _runner.find_child("PantallaFinSlice")
	var fragmento: ObjetoRecuerdo = _runner.find_child("FragmentoDoliente2")
	_party.ir_a_interactuar(fragmento)
	assert_bool(await _esperar(func() -> bool: return fin.visible)).is_true()
	assert_bool(GameState.marcas.has(&"fin_del_slice")).is_true()
	assert_bool(_party.bloqueado).is_true()
	await fin.seguir()
	assert_bool(fin.mostrando_fin()).is_true()
	var avisos: Array[int] = [0]
	fin.volver_pedido.connect(func() -> void: avisos[0] += 1)
	fin.volver_al_inicio()
	assert_int(avisos[0]).is_equal(1)

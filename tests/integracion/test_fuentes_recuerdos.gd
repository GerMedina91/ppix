extends GdUnitTestSuite
## Fuentes de recuerdos en el mundo (GDD 4.2): objetos, enemigos inconscientes tras la victoria y el cuerpo de
## un compañero muerto.

const ESCENA: String = "res://scenes/world/mundo.tscn"
const FRAMES_MAXIMOS: int = 3000

var _runner: GdUnitSceneRunner
var _party: ControlParty
var _control: ControladorCombate
var _panel: PanelOpciones


func before_test() -> void:
	GameState.nueva_partida()
	GameState.reiniciar_dados(11)
	_runner = scene_runner(ESCENA)
	_party = _runner.find_child("Party")
	_control = _runner.find_child("ControladorCombate")
	_panel = _runner.find_child("PanelOpciones")


func after_test() -> void:
	GameState.nueva_partida()


func _esperar(condicion: Callable) -> bool:
	for i in FRAMES_MAXIMOS:
		if condicion.call():
			return true
		await _runner.simulate_frames(1)
	return false


func _mapa() -> Mapa:
	return _runner.find_child("MapaActual").get_child(0)


func _ids_sueltos() -> Array:
	return GameState.recuerdos.inventario.sueltos.map(func(r: DefinicionRecuerdo) -> String: return String(r.id))


func _ir_a(id_mapa: StringName, celda: Vector2i) -> void:
	_party.ir_a_celda(celda)
	assert_bool(await _esperar(func() -> bool: return GameState.id_mapa_actual == id_mapa and not _party.bloqueado)).is_true()


## Entra al combate de prueba del mapa B y lo gana con `preparar` (Callable(Combate)) antes de cerrar.
func _ganar_en_el_mapa_b(preparar: Callable) -> void:
	await _ir_a(&"mapa_prueba_b", Vector2i(19, 5))
	_party.ir_a_celda(Vector2i(13, 10))
	assert_bool(await _esperar(func() -> bool: return _control.esperando_decision())).is_true()
	var combate: Combate = _control.combate()
	preparar.call(combate)
	_control._encolar(combate.verificar_fin())


func test_el_objeto_se_toma_y_no_vuelve() -> void:
	var objeto: ObjetoRecuerdo = _runner.find_child("RecuerdoMedicina")
	_party.ir_a_interactuar(objeto)
	assert_bool(await _esperar(func() -> bool: return _ids_sueltos().has("destreza_medicina"))).is_true()
	assert_object(_mapa().interactuable_en(Vector2i(11, 9))).is_null()
	assert_bool(_party.grilla().es_transitable(Vector2i(11, 9))).is_true()
	await _ir_a(&"mapa_prueba_b", Vector2i(19, 5))
	await _ir_a(&"mapa_prueba_a", Vector2i(0, 10))
	assert_object(_mapa().interactuable_en(Vector2i(11, 9))).is_null()
	assert_object(_mapa().interactuable_en(Vector2i(2, 1))).is_not_null()


func test_al_enemigo_inconsciente_se_le_extrae_el_recuerdo() -> void:
	await _ganar_en_el_mapa_b(func(combate: Combate) -> void:
		var distancia: Combatiente = combate.combatiente(&"EnemigoDistancia")
		distancia.recibir_danio(distancia.pg, false, true)
		combate.combatiente(&"EnemigoCuerpoACuerpo").condiciones.muerto = true)
	assert_bool(await _esperar(func() -> bool: return _panel.abierto())).is_true()
	assert_array(Array(_panel.opciones())).contains_exactly(["Extraer", "Perdonar", "Rematar"])
	_panel.elegir(0)
	assert_bool(await _esperar(func() -> bool: return not _party.bloqueado)).is_true()
	assert_array(_ids_sueltos()).contains_exactly(["vivencia_4"])
	assert_int(GameState.recuerdos.destinos[&"mapa_prueba_b/EnemigoDistancia"]).is_equal(EstadoRecuerdos.Destino.EXTRAIDO)
	assert_array(_mapa().encuentros()[0].enemigos().filter(func(e: EnemigoEnMapa) -> bool: return not e.is_queued_for_deletion())).is_empty()


func test_rematar_no_da_recuerdo_y_queda_registrado() -> void:
	await _ganar_en_el_mapa_b(func(combate: Combate) -> void:
		for id: StringName in [&"EnemigoDistancia", &"EnemigoCuerpoACuerpo"]:
			var e: Combatiente = combate.combatiente(id)
			e.recibir_danio(e.pg, false, true))
	for i in 2:
		assert_bool(await _esperar(func() -> bool: return _panel.abierto())).is_true()
		_panel.elegir(2)  # Rematar
		await _runner.simulate_frames(1)
	assert_bool(await _esperar(func() -> bool: return not _party.bloqueado)).is_true()
	assert_array(_ids_sueltos()).is_empty()
	assert_int(GameState.recuerdos.destinos.size()).is_equal(2)
	assert_bool(GameState.recuerdos.destinos.values().all(func(d: int) -> bool: return d == EstadoRecuerdos.Destino.REMATADO)).is_true()


func test_del_cuerpo_de_irsa_se_extraen_sus_recuerdos_una_vez() -> void:
	var celda: Array[Vector2i] = []
	await _ganar_en_el_mapa_b(func(combate: Combate) -> void:
		var irsa: Combatiente = combate.combatiente(&"Miembro2")
		irsa.condiciones.muerto = true
		celda.append(irsa.celda)
		for id: StringName in [&"EnemigoDistancia", &"EnemigoCuerpoACuerpo"]:
			combate.combatiente(id).condiciones.muerto = true)
	assert_bool(await _esperar(func() -> bool: return not _control.en_curso() and not _party.bloqueado)).is_true()
	var cuerpo: CuerpoCompanero = _mapa().interactuable_en(celda[0])
	_party.ir_a_interactuar(cuerpo)
	assert_bool(await _esperar(func() -> bool: return _panel.abierto())).is_true()
	assert_array(Array(_panel.opciones())).contains_exactly(["Extraer", "Dejar"])
	_panel.elegir(0)
	await _runner.simulate_frames(2)
	assert_array(_ids_sueltos()).contains_exactly(["irsa_destreza", "irsa_vivencia", "doliente_3"])
	assert_bool(GameState.mundo.cuerpo_extraido(&"Miembro2")).is_true()
	_party.ir_a_interactuar(cuerpo)
	await _runner.simulate_frames(5)
	assert_bool(_panel.abierto()).is_false()
	assert_str((_runner.find_child("AvisoMundo") as AvisoMundo).texto()).is_equal("Ya no queda nada que extraer")


func test_al_ganar_la_companera_inconsciente_despierta_con_1_pg() -> void:
	await _ganar_en_el_mapa_b(func(combate: Combate) -> void:
		var irsa: Combatiente = combate.combatiente(&"Miembro2")
		irsa.recibir_danio(irsa.pg, false)  # moribundo 1
		for id: StringName in [&"EnemigoDistancia", &"EnemigoCuerpoACuerpo"]:
			combate.combatiente(id).condiciones.muerto = true)
	assert_bool(await _esperar(func() -> bool: return not _control.en_curso() and not _party.bloqueado)).is_true()
	assert_int(GameState.estado_party[&"Miembro2"].pg).is_equal(1)
	assert_int(GameState.estado_party[&"Miembro2"].herido).is_equal(1)
	assert_that((_runner.find_child("Miembro2") as MiembroParty).modulate).is_equal(ActorMapa.MODULACION[ActorMapa.EstadoVisual.NORMAL])
	assert_int(_party.miembros().size()).is_equal(4)

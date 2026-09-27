extends GdUnitTestSuite
## Muerte del Eco en el mundo (GDD 4.3): reaparece junto al último punto estable, el residuo queda donde cayó
## (y se recupera pisándolo) y el jugador elige el integrado que pierde. Los enemigos muertos siguen muertos.

const ESCENA: String = "res://scenes/world/mundo.tscn"
const ESPERA_MS: int = 8000
const FRAMES_MAXIMOS: int = 3000
const CELDA_PUNTO: Vector2i = Vector2i(4, 9)

var _runner: GdUnitSceneRunner
var _party: ControlParty
var _control: ControladorCombate
var _suelto: DefinicionRecuerdo
var _integrado: DefinicionRecuerdo


func before_test() -> void:
	GameState.nueva_partida()
	GameState.reiniciar_dados(11)
	GameState.id_ultimo_punto_estable = &"punto_estable_prueba_a"
	GameState.id_mapa_ultimo_punto_estable = &"mapa_prueba_a"
	_suelto = _recuerdo(&"suelto_prueba", "Suelto de prueba")
	_integrado = _recuerdo(&"integrado_prueba", "Integrado de prueba")
	GameState.recuerdos.inventario.agregar_suelto(_suelto)
	GameState.recuerdos.inventario.integrados.append(_integrado)
	_runner = scene_runner(ESCENA)
	_party = _runner.find_child("Party")
	_control = _runner.find_child("ControladorCombate")


func after_test() -> void:
	GameState.nueva_partida()


func _recuerdo(id: StringName, nombre: String) -> DefinicionRecuerdo:
	var r: DefinicionRecuerdo = DefinicionRecuerdo.new()
	r.id = id
	r.nombre = nombre
	var beneficio: BeneficioHabilidad = BeneficioHabilidad.new()
	beneficio.habilidad = Habilidad.Tipo.SIGILO
	r.beneficio = beneficio
	return r


func _esperar(condicion: Callable) -> bool:
	for i in FRAMES_MAXIMOS:
		if condicion.call():
			return true
		await _runner.simulate_frames(1)
	return false


## Entra al combate del mapa B, mata a un enemigo y al Eco, y espera a que reaparezca (panel de pérdida).
func _morir_en_el_mapa_b() -> Vector2i:
	_party.ir_a_celda(Vector2i(19, 5))
	assert_bool(await _esperar(func() -> bool: return GameState.id_mapa_actual == &"mapa_prueba_b" and not _party.bloqueado)).is_true()
	_party.ir_a_celda(Vector2i(13, 10))
	assert_bool(await _esperar(func() -> bool: return _control.esperando_decision())).is_true()
	var combate: Combate = _control.combate()
	combate.combatiente(&"EnemigoDistancia").condiciones.muerto = true
	var eco: Combatiente = combate.combatiente(&"Miembro1")
	eco.condiciones.muerto = true
	var celda_eco: Vector2i = eco.celda
	_control._encolar(combate.verificar_fin())  # como si lo hubieran matado en esta acción
	var panel: PanelPerdida = _runner.find_child("PanelPerdida")
	assert_bool(await _esperar(func() -> bool: return panel.abierto())).override_failure_message("no se abrió el panel de pérdida").is_true()
	return celda_eco


func test_reaparece_junto_al_punto_estable_y_elige_que_pierde() -> void:
	await _morir_en_el_mapa_b()
	assert_str(GameState.id_mapa_actual).is_equal("mapa_prueba_a")
	var distancia: Vector2i = (_party.celda_lider() - CELDA_PUNTO).abs()
	assert_int(maxi(distancia.x, distancia.y)).is_less_equal(4)
	assert_bool(_party.bloqueado).is_true()
	var panel: PanelPerdida = _runner.find_child("PanelPerdida")
	assert_array(Array(panel.opciones())).contains_exactly(["Integrado de prueba"])
	panel.elegir(_integrado)
	await _runner.simulate_frames(2)
	assert_array(GameState.recuerdos.inventario.integrados).is_empty()
	assert_bool(_party.bloqueado).is_false()
	# El suelto quedó en el residuo, en el mapa B; el Eco se rearmó sin herido.
	assert_bool(GameState.recuerdos.hay_residuo()).is_true()
	assert_array(GameState.recuerdos.inventario.sueltos).is_empty()
	assert_bool(GameState.estado_party.has(&"Miembro1")).is_false()


func test_el_muerto_sigue_muerto_y_el_residuo_se_recupera_pisandolo() -> void:
	var celda_eco: Vector2i = await _morir_en_el_mapa_b()
	(_runner.find_child("PanelPerdida") as PanelPerdida).elegir(_integrado)
	_party.ir_a_celda(Vector2i(19, 5))
	assert_bool(await _esperar(func() -> bool: return GameState.id_mapa_actual == &"mapa_prueba_b" and not _party.bloqueado)).is_true()
	var mapa: Mapa = _runner.find_child("MapaActual").get_child(0)
	var encuentro: Encuentro = mapa.encuentros()[0]
	assert_bool(encuentro.resuelto).is_false()
	assert_array(encuentro.enemigos().map(func(e: EnemigoEnMapa) -> String: return String(e.name))).contains_exactly(["EnemigoCuerpoACuerpo"])
	var gestor: GestorMuerte = _runner.find_child("GestorMuerte")
	assert_bool(gestor.hay_marca()).is_true()
	# Se retira el encuentro para poder caminar hasta el residuo sin volver a pelear.
	encuentro.resuelto = true
	_party.ir_a_celda(celda_eco)
	assert_bool(await _esperar(func() -> bool: return not GameState.recuerdos.hay_residuo())).override_failure_message("no recuperó el residuo").is_true()
	assert_array(GameState.recuerdos.inventario.sueltos).contains_exactly([_suelto])
	assert_bool(gestor.hay_marca()).is_false()

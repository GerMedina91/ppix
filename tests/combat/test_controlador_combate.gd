extends GdUnitTestSuite
## Integración del combate en el mapa de prueba A (encuentro de prueba con dos enemigos).

const ESCENA: String = "res://scenes/world/mundo.tscn"
const ESPERA_MS: int = 8000
const FRAMES_MAXIMOS: int = 20000

var _runner: GdUnitSceneRunner
var _control: ControladorCombate
var _party: ControlParty


func before_test() -> void:
	GameState.reiniciar_dados(11)
	GameState.estado_party.clear()
	_runner = scene_runner(ESCENA)
	_control = _runner.find_child("ControladorCombate")
	_control.config = _config_rapida()
	_party = _runner.find_child("Party")


func _config_rapida() -> ConfigCombate:
	var rapida: ConfigCombate = ConfigCombate.new()
	rapida.segundos_por_celda = 0.001
	rapida.pausa_entre_eventos = 0.001
	rapida.segundos_golpe = 0.001
	rapida.segundos_texto_flotante = 0.01
	return rapida


func _entrar_a_la_zona() -> void:
	_party.ir_a_celda(Vector2i(19, 5))
	assert_bool(await _esperar(func() -> bool: return GameState.id_mapa_actual == &"mapa_prueba_b" and not _party.bloqueado)).is_true()
	_party.ir_a_celda(Vector2i(13, 10))
	await _runner.await_func_on(_control, "en_curso").wait_until(ESPERA_MS).is_true()


func _esperar(condicion: Callable) -> bool:
	for i in FRAMES_MAXIMOS:
		if condicion.call():
			return true
		await _runner.simulate_frames(1)
	return false


func test_entrar_a_la_zona_inicia_el_combate_y_bloquea_la_exploracion() -> void:
	await _entrar_a_la_zona()
	assert_bool(_party.bloqueado).is_true()
	assert_int(_control.combate().participantes.size()).is_equal(6)


func test_en_su_turno_el_jugador_mueve_con_click() -> void:
	await _entrar_a_la_zona()
	assert_bool(await _esperar(func() -> bool: return _control.esperando_decision() or not _control.en_curso())).is_true()
	if not _control.en_curso():
		return
	var actor: Combatiente = _control.combate().turno_actual()
	var destinos: Dictionary = _control.combate().casillas_de_zancada(actor)
	var destino: Vector2i = destinos.keys()[0]
	_control.click_en_celda(destino)
	assert_that(actor.celda).is_equal(destino)
	assert_int(actor.acciones_restantes).is_equal(2)
	assert_bool(await _esperar(func() -> bool: return not _control.animando())).is_true()
	assert_that(_control.actor_de(actor.id).celda).is_equal(destino)


## Invariante: después de animar cada evento, cada ActorMapa está en la casilla de su Combatiente
## y en el centro visual de esa casilla. Devuelve las violaciones encontradas.
func _vigilar_sincronia() -> Array[String]:
	var violaciones: Array[String] = []
	_control.evento_mostrado.connect(func(evento: EventoCombate) -> void:
		var combate: Combate = _control.combate()
		if combate == null:
			return
		var mapa: Mapa = _runner.find_child("MapaActual").get_child(0)
		for c: Combatiente in combate.participantes:
			var actor: ActorMapa = _control.actor_de(c.id)
			if actor.celda != c.celda:
				violaciones.append("%s tras %s: actor en %s, combatiente en %s" % [c.id, evento, actor.celda, c.celda])
			elif actor.global_position.distance_to(mapa.celda_a_posicion(c.celda)) > 0.5:
				violaciones.append("%s tras %s: posición %s fuera del centro de %s" % [c.id, evento, actor.global_position, c.celda]))
	return violaciones


func test_actores_y_combatientes_sincronizados_en_combate_ia_contra_ia() -> void:
	for semilla: int in [11, 12, 13]:
		GameState.reiniciar_dados(semilla)
		GameState.estado_party.clear()
		_runner = scene_runner(ESCENA)
		_control = _runner.find_child("ControladorCombate")
		_control.config = _config_rapida()
		_party = _runner.find_child("Party")
		_control.auto_jugar_party = true
		var violaciones: Array[String] = _vigilar_sincronia()
		await _entrar_a_la_zona()
		assert_bool(await _esperar(func() -> bool: return not _control.en_curso())).override_failure_message("semilla %d: no terminó" % semilla).is_true()
		assert_array(violaciones).override_failure_message("semilla %d: %s" % [semilla, "
".join(violaciones.slice(0, 5))]).is_empty()


func test_combate_completo_vuelve_a_exploracion() -> void:
	_control.auto_jugar_party = true
	await _entrar_a_la_zona()
	assert_bool(await _esperar(func() -> bool: return not _control.en_curso())).override_failure_message("el combate no terminó").is_true()
	await _runner.simulate_frames(5)
	var encuentro: Encuentro = (_runner.find_child("MapaActual").get_child(0) as Mapa).encuentros()[0]
	if encuentro.resuelto:
		# Victoria: la party vuelve a moverse, los enemigos muertos se retiraron y los PG quedaron guardados.
		assert_bool(_party.bloqueado).is_false()
		assert_int(encuentro.enemigos().size()).is_equal(0)
		assert_int(GameState.estado_party.size()).is_equal(4)
	else:
		# Derrota (placeholder hasta M4): la party vuelve a la entrada con los PG completos.
		assert_bool(GameState.estado_party.is_empty()).is_true()


func test_el_hud_aparece_con_el_combate_y_registra_eventos() -> void:
	var hud: HudCombate = _runner.find_child("HudCombate")
	assert_bool(hud.visible).is_false()
	await _entrar_a_la_zona()
	assert_bool(hud.visible).is_true()
	assert_bool(await _esperar(func() -> bool: return _control.esperando_decision() or not _control.en_curso())).is_true()
	assert_array(Array(hud.lineas_registro())).is_not_empty()
	if _control.en_curso():
		var actor: Combatiente = _control.combate().turno_actual()
		assert_str(hud.texto_activo()).starts_with("%s   PG %d/%d   Acciones " % [actor.id, actor.pg, actor.pg_maximos()])
		assert_str(hud.texto_activo()).not_contains("%")


func test_el_overlay_dibuja_rangos_y_vision_durante_el_combate_sin_errores() -> void:
	await _entrar_a_la_zona()
	var overlay: OverlayDepuracion = _runner.find_child("OverlayDepuracion")
	overlay.visible = true
	overlay.set_process(true)
	await _runner.simulate_frames(30)
	assert_object(ControladorCombate.activo(_control.get_tree())).is_same(_control)


func test_f4_restaura_a_la_party_fuera_y_dentro_del_combate() -> void:
	GameState.estado_party[&"Miembro1"] = {"pg": 0, "herido": 2, "muerto": false}
	_runner.simulate_action_pressed(AtajosDepuracion.ACCION_CURAR)
	await _runner.simulate_frames(2)
	assert_bool(GameState.estado_party.is_empty()).is_true()
	await _entrar_a_la_zona()
	for c: Combatiente in _control.combate().participantes:
		if c.bando == Combatiente.Bando.PARTY:
			c.recibir_danio(c.pg, false)
	_runner.simulate_action_pressed(AtajosDepuracion.ACCION_CURAR)
	await _runner.simulate_frames(2)
	for c: Combatiente in _control.combate().participantes:
		if c.bando == Combatiente.Bando.PARTY:
			assert_int(c.pg).is_equal(c.pg_maximos())
			assert_bool(c.condiciones.puede_actuar()).is_true()
			assert_int(c.condiciones.herido).is_equal(0)


func _esperar_turno_de_la_party() -> bool:
	return await _esperar(func() -> bool: return _control.esperando_decision() or not _control.en_curso())


func test_en_el_turno_de_la_party_se_ve_la_ayuda_de_controles() -> void:
	var hud: HudCombate = _runner.find_child("HudCombate")
	await _entrar_a_la_zona()
	assert_bool(await _esperar_turno_de_la_party()).is_true()
	assert_bool(_control.en_curso()).override_failure_message("con la semilla 11 el combate sigue en el primer turno de la party").is_true()
	assert_bool(hud.ayuda_visible()).is_true()
	assert_str(hud.texto_ayuda()).is_equal(HudCombate.AYUDA)
	_control.terminar_turno_jugador()
	await _runner.simulate_frames(1)
	if _control.en_curso() and _control.combate().turno_actual().bando == Combatiente.Bando.ENEMIGOS:
		assert_bool(hud.ayuda_visible()).is_false()


func test_golpe_imposible_muestra_el_motivo_en_el_registro() -> void:
	var hud: HudCombate = _runner.find_child("HudCombate")
	await _entrar_a_la_zona()
	assert_bool(await _esperar_turno_de_la_party()).is_true()
	assert_bool(_control.en_curso()).is_true()
	var actor: Combatiente = _control.combate().turno_actual()
	var enemigo: Combatiente = null
	for c: Combatiente in _control.combate().participantes:
		if not c.es_aliado_de(actor) and not c.condiciones.muerto:
			enemigo = c
	assert_object(enemigo).is_not_null()
	# Sin acciones: el Golpe es imposible y el motivo llega al registro sin gastar nada.
	actor.acciones_restantes = 0
	_control.click_en_celda(enemigo.celda)
	assert_bool(await _esperar(func() -> bool: return not _control.animando())).is_true()
	assert_str(hud.lineas_registro()[-1]).is_equal("%s: Golpe imposible (sin acciones)" % actor.id)


func test_zancada_imposible_muestra_el_motivo_en_el_registro() -> void:
	var hud: HudCombate = _runner.find_child("HudCombate")
	await _entrar_a_la_zona()
	assert_bool(await _esperar_turno_de_la_party()).is_true()
	assert_bool(_control.en_curso()).is_true()
	var actor: Combatiente = _control.combate().turno_actual()
	_control.click_en_celda(Vector2i(0, 0))  # pared del borde del mapa B
	assert_bool(await _esperar(func() -> bool: return not _control.animando())).is_true()
	assert_str(hud.lineas_registro()[-1]).is_equal("%s: Zancada imposible (fuera del alcance de la Zancada)" % actor.id)
	assert_int(actor.acciones_restantes).is_equal(Combatiente.ACCIONES_POR_TURNO)

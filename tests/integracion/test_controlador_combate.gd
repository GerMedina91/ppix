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
	assert_bool(_control.en_curso()).override_failure_message("con la semilla 11 el combate sigue en el primer turno de la party").is_true()
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
	assert_bool(_control.en_curso()).is_true()
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
	# En combate se comprueba en el acto: si se dejan pasar frames, los enemigos ya actúan.
	(_runner.find_child("AtajosDepuracion") as AtajosDepuracion).curar_party()
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


func _casilla_a_zancadas(n: int) -> Vector2i:
	var alcance: Dictionary = _control.prevision_actual().por_casilla
	var candidatas: Array = alcance.keys().filter(func(c: Vector2i) -> bool: return alcance[c] == n)
	candidatas.sort()
	return candidatas[0]


func test_click_lejano_hace_dos_zancadas_seguidas_como_acciones_separadas() -> void:
	var hud: HudCombate = _runner.find_child("HudCombate")
	var violaciones: Array[String] = _vigilar_sincronia()
	await _entrar_a_la_zona()
	assert_bool(await _esperar_turno_de_la_party()).is_true()
	assert_bool(_control.en_curso()).is_true()
	var actor: Combatiente = _control.combate().turno_actual()
	var destino: Vector2i = _casilla_a_zancadas(2)
	assert_int(_control.prevision_actual().costo(destino)).is_equal(2)
	assert_array(_control.prevision_actual().camino(destino)).is_not_empty()
	var registro_antes: int = _control.combate().registro.size()
	_control.click_en_celda(destino)
	assert_bool(await _esperar(func() -> bool: return _control.esperando_decision() or not _control.en_curso())).is_true()
	assert_that(actor.celda).is_equal(destino)
	assert_int(actor.acciones_restantes).is_equal(1)
	var movimientos: Array = _control.combate().registro.slice(registro_antes).filter(
		func(e: EventoCombate) -> bool: return e.tipo == EventoCombate.Tipo.MOVIMIENTO)
	assert_int(movimientos.size()).is_equal(2)
	var lineas: PackedStringArray = hud.lineas_registro()
	assert_str(lineas[-1]).starts_with("%s: Zancada" % actor.id)
	assert_str(lineas[-2]).starts_with("%s: Zancada" % actor.id)
	assert_that(_control.actor_de(actor.id).celda).is_equal(destino)
	assert_array(violaciones).is_empty()


func test_costo_previsto_de_un_golpe_es_una_accion() -> void:
	await _entrar_a_la_zona()
	assert_bool(await _esperar_turno_de_la_party()).is_true()
	assert_bool(_control.en_curso()).is_true()
	var actor: Combatiente = _control.combate().turno_actual()
	# Se fuerza la situación: un enemigo pegado al actor activo (combatiente y actor del mapa juntos).
	var enemigo: Combatiente = null
	for c: Combatiente in _control.combate().participantes:
		if not c.es_aliado_de(actor) and not c.condiciones.muerto:
			enemigo = c
	var mapa: Mapa = _runner.find_child("MapaActual").get_child(0)
	var junto: Vector2i = _casilla_vecina_libre(actor.celda)
	enemigo.celda = junto
	_control.actor_de(enemigo.id).colocar(junto, mapa.celda_a_posicion(junto))
	var arma: DefinicionArma = actor.arma_principal()
	assert_int(Golpe.validar(actor, enemigo, arma, _control.combate().vision())).is_equal(Golpe.Motivo.VALIDO)
	assert_int(_control.prevision_actual().costo(junto)).is_equal(Combate.COSTO_GOLPE)


func test_el_alcance_distingue_una_dos_y_tres_acciones() -> void:
	await _entrar_a_la_zona()
	assert_bool(await _esperar_turno_de_la_party()).is_true()
	var valores: Array = _control.prevision_actual().por_casilla.values()
	for n: int in [1, 2, 3]:
		assert_bool(valores.has(n)).override_failure_message("sin casillas a %d Zancadas" % n).is_true()


## Casilla vecina transitable y sin ningún combatiente.
func _casilla_vecina_libre(celda: Vector2i) -> Vector2i:
	var grilla: GrillaMapa = _control.combate().grilla()
	for d: Vector2i in [Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(0, -1), Vector2i(1, 1), Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1)]:
		var c: Vector2i = celda + d
		if grilla.puede_dar_paso(celda, c) and not _control.combate().participantes.any(func(x: Combatiente) -> bool: return x.celda == c):
			return c
	fail("sin casilla vecina libre")
	return celda


## IA de enemigos para el test: el enemigo cuerpo a cuerpo se aleja con una Zancada al empezar su turno.
func _ia_que_se_aleja(combate: Combate) -> Array[EventoCombate]:
	var actor: Combatiente = combate.turno_actual()
	if actor.id == &"EnemigoCuerpoACuerpo" and actor.acciones_restantes == Combatiente.ACCIONES_POR_TURNO:
		var guerrero: Combatiente = combate.combatiente(&"Miembro1")
		var casillas: Dictionary = combate.casillas_de_zancada(actor)
		var lejos: Vector2i = actor.celda
		for c: Vector2i in casillas:
			if Medicion.pies_entre(c, guerrero.celda) > Medicion.pies_entre(lejos, guerrero.celda):
				lejos = c
		return combate.zancada(lejos)
	return combate.terminar_turno()


func test_aviso_de_golpe_reactivo_pausa_el_combate_y_siempre_dura_la_sesion() -> void:
	var hud: HudCombate = _runner.find_child("HudCombate")
	var violaciones: Array[String] = _vigilar_sincronia()
	_control.ia_enemigos = _ia_que_se_aleja
	await _entrar_a_la_zona()
	# Se fuerza la situación: el enemigo cuerpo a cuerpo, pegado al guerrero (Miembro1).
	var guerrero: Combatiente = _control.combate().combatiente(&"Miembro1")
	var enemigo: Combatiente = _control.combate().combatiente(&"EnemigoCuerpoACuerpo")
	var mapa: Mapa = _runner.find_child("MapaActual").get_child(0)
	assert_bool(await _esperar(func() -> bool: return not _control.animando())).is_true()
	var junto: Vector2i = _casilla_vecina_libre(guerrero.celda)
	enemigo.celda = junto
	_control.actor_de(enemigo.id).colocar(junto, mapa.celda_a_posicion(junto))
	# La party pasa sus turnos hasta que el enemigo se aleja y aparece el aviso.
	var aparecio: bool = await _esperar(func() -> bool:
		if _control.esperando_decision():
			_control.terminar_turno_jugador()
		return _control.esperando_reaccion() or not _control.en_curso())
	assert_bool(aparecio and _control.esperando_reaccion()).override_failure_message("no apareció el aviso").is_true()
	assert_bool(hud.aviso_visible()).is_true()
	assert_bool(_control.esperando_decision()).is_false()
	var celda_en_pausa: Vector2i = enemigo.celda
	await _runner.simulate_frames(10)
	assert_that(enemigo.celda).override_failure_message("el combate siguió durante la pausa").is_equal(celda_en_pausa)
	_control.responder_reaccion(ControladorCombate.Respuesta.SIEMPRE)
	assert_bool(await _esperar(func() -> bool: return not _control.animando())).is_true()
	assert_bool(hud.aviso_visible()).is_false()
	assert_int(guerrero.politica_reacciones).is_equal(Combatiente.PoliticaReaccion.SIEMPRE)
	assert_bool(Array(hud.lineas_registro()).any(func(l: String) -> bool: return l.begins_with("Miembro1 usa Golpe reactivo")) \
		or _control.combate() == null or not guerrero.reaccion_disponible).is_true()
	assert_array(violaciones).is_empty()


## Pasa los turnos de la party hasta que le toque decidir a `id` (false si el combate terminó antes).
func _turno_de(id: StringName) -> bool:
	return await _esperar(func() -> bool:
		if not _control.en_curso():
			return true
		if _control.esperando_decision() and _control.combate().turno_actual().id != id:
			_control.terminar_turno_jugador()
		return _control.esperando_decision() and _control.combate().turno_actual().id == id) and _control.en_curso()


func test_la_bruja_lanza_mal_de_ojo_desde_el_mapa() -> void:
	var hud: HudCombate = _runner.find_child("HudCombate")
	var violaciones: Array[String] = _vigilar_sincronia()
	await _entrar_a_la_zona()
	assert_bool(await _turno_de(&"Miembro4")).override_failure_message("no llegó el turno de la bruja").is_true()
	var bruja: Combatiente = _control.combate().turno_actual()
	# Se fuerza la situación: el enemigo cuerpo a cuerpo, pegado a la bruja (a alcance y con línea de visión).
	var enemigo: Combatiente = _control.combate().combatiente(&"EnemigoCuerpoACuerpo")
	var mapa: Mapa = _runner.find_child("MapaActual").get_child(0)
	var junto: Vector2i = _casilla_vecina_libre(bruja.celda)
	enemigo.celda = junto
	_control.actor_de(enemigo.id).colocar(junto, mapa.celda_a_posicion(junto))
	assert_str(hud.texto_acciones()).starts_with("1 Mal de ojo ◆")
	_runner.simulate_key_pressed(KEY_1)  # por EntradaCombate, como el jugador
	await _runner.simulate_frames(2)
	assert_str(hud.texto_acciones()).starts_with("Mal de ojo: click en el objetivo")
	_control.click_en_celda(junto)
	assert_bool(await _esperar(func() -> bool: return not _control.animando())).is_true()
	assert_bool(Array(hud.lineas_registro()).any(func(l: String) -> bool:
		return l == "Miembro4 lanza Mal de ojo sobre EnemigoCuerpoACuerpo")).is_true()
	assert_int(bruja.acciones_restantes).is_equal(2)
	assert_array(violaciones).is_empty()

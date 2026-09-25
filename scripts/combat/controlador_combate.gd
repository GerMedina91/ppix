class_name ControladorCombate
extends Node2D
## Presentación del combate en el mismo mapa de exploración. Arma el Combate (rules/) a partir del
## Encuentro y la party, pasa sus eventos al AnimadorCombate en orden y traduce la entrada del jugador
## en intenciones. Los resaltados del suelo los dibuja ResaltadosCombate (hijo).
## - Enemigos: IASimple, una decisión por vez (se anima cada una antes de pedir la siguiente, así el
##   estado del Combate y lo que se ve en el mapa avanzan juntos).
## - Party: click en enemigo = Golpe; click en el suelo = Zancada; Shift + click = Paso;
##   acción `terminar_turno` (Espacio); teclas 1-9 = conjuros, Sostener y Arcadas (ModoAccion).

signal combate_iniciado
signal combate_terminado(victoria: bool)
## Se emite al animar cada evento (lo usa el HUD para el registro).
signal evento_mostrado(evento: EventoCombate)
## Se emite cuando no queda nada por animar y le toca decidir al jugador.
signal esperando_jugador
## Se emite cuando una reacción de la party espera respuesta (el combate queda en pausa).
signal pregunta_reaccion(texto: String)
## Se emite al elegir o cancelar un conjuro (el HUD y los resaltados cambian).
signal accion_elegida

## Respuestas al aviso de reacción. SIEMPRE: la usa ahora y en adelante, por el resto de la sesión.
enum Respuesta { SI, NO, SIEMPRE }

const ACCION_TERMINAR_TURNO: StringName = &"terminar_turno"
## Grupo para que herramientas (overlay de depuración) encuentren al controlador.
const GRUPO: StringName = &"controlador_combate"
const _SIN_CURSOR: Vector2i = Vector2i(-9999, -9999)

@export var config: ConfigCombate
## Solo para pruebas y depuración: la IA juega también los turnos de la party (y sus reacciones).
var auto_jugar_party: bool = false
## Decide una acción del enemigo en turno: Callable(Combate) -> Array[EventoCombate]. Inyectable en tests.
var ia_enemigos: Callable = IASimple.jugar_accion
## Miembros con "Siempre" elegido en el aviso de reacción (dura toda la sesión, no se guarda).
var _reacciones_siempre: Dictionary[StringName, bool] = {}

var _combate: Combate
var _encuentro: Encuentro
var _mapa: Mapa
var _party: ControlParty
var _camara: CamaraMundo
var _animador: AnimadorCombate
var _resaltados: ResaltadosCombate
var _actores: Dictionary[StringName, ActorMapa] = {}
var _cola: Array[EventoCombate] = []
var _animando: bool = false
var _celda_cursor: Vector2i = _SIN_CURSOR
## Alcance, caminos y objetivos de la decisión en curso del jugador (null si no hay decisión).
var _prevision: PrevisionTurno
## Tramos pendientes de un movimiento de varias Zancadas (se ejecutan de a una, animando cada una).
var _plan: Array[Array] = []
var _modo: ModoAccion = ModoAccion.new()
## Mitad del tamaño del rombo de una casilla (del TileSet del mapa del combate).
var _medio_rombo: Vector2 = Vector2.ZERO


func _ready() -> void:
	add_to_group(GRUPO)
	_resaltados = ResaltadosCombate.new()
	_resaltados.name = "Resaltados"
	_resaltados.controlador = self
	add_child(_resaltados)


static func activo(arbol: SceneTree) -> ControladorCombate:
	return arbol.get_first_node_in_group(GRUPO) as ControladorCombate


# --- Consultas (HUD, resaltados, overlay, tests) ---

func en_curso() -> bool:
	return _combate != null and _combate.estado == Combate.Estado.EN_CURSO


func combate() -> Combate:
	return _combate


func animando() -> bool:
	return _animando


func actor_de(id: StringName) -> ActorMapa:
	return _actores.get(id)


func celda_cursor() -> Vector2i:
	return _celda_cursor


## Casilla -> cantidad mínima de Zancadas, durante la decisión del jugador.
func alcance_actual() -> Dictionary[Vector2i, int]:
	var prevision: PrevisionTurno = prevision_actual()
	var vacio: Dictionary[Vector2i, int] = {}
	return prevision.por_casilla if prevision != null else vacio


## Costo en acciones de hacer click en `celda` ahora: Zancadas necesarias o el Golpe; 0 si no se puede.
func costo_previsto(celda: Vector2i) -> int:
	var prevision: PrevisionTurno = prevision_actual()
	return prevision.costo(celda) if prevision != null else 0


## Camino completo (todas las Zancadas) hasta `celda`, para la previsualización.
func camino_previsto(celda: Vector2i) -> Array[Vector2i]:
	var prevision: PrevisionTurno = prevision_actual()
	var vacio: Array[Vector2i] = []
	return prevision.camino(celda) if prevision != null else vacio


## Previsión de la decisión en curso: se calcula una vez y se rehace solo si cambió el estado del combate.
func prevision_actual() -> PrevisionTurno:
	if not esperando_decision():
		return null
	if _prevision == null or not _prevision.vigente(_combate):
		_prevision = PrevisionTurno.new(_combate)
	return _prevision


## Conjuros, Sostener y Arcadas del actor (o la instrucción del conjuro elegido) para el HUD.
func texto_acciones() -> String:
	return _modo.texto(_combate, _combate.turno_actual()) if esperando_decision() else ""


func modo_accion() -> ModoAccion:
	return _modo


## Elige la acción `indice` (desde 0) de la lista de texto_acciones(). Sostener y Arcadas se hacen ya.
func elegir_accion(indice: int) -> void:
	if not esperando_decision():
		return
	var inmediata: Callable = _modo.elegir(_combate, _combate.turno_actual(), indice)
	if inmediata.is_valid():
		_encolar(inmediata.call())
	accion_elegida.emit()
	_resaltados.queue_redraw()


func cancelar_accion() -> void:
	_modo.cancelar()
	accion_elegida.emit()
	_resaltados.queue_redraw()


## true si le toca decidir al jugador (turno de un miembro de la party y nada animándose).
func esperando_decision() -> bool:
	return en_curso() and not _animando and _cola.is_empty() and not _combate.hay_reaccion_pendiente() \
		and _combate.turno_actual().bando == Combatiente.Bando.PARTY


## true si el combate está en pausa esperando la respuesta a un aviso de reacción.
func esperando_reaccion() -> bool:
	return en_curso() and not _animando and _cola.is_empty() and _combate.hay_reaccion_pendiente()


## Respuesta del jugador al aviso de reacción.
func responder_reaccion(respuesta: Respuesta) -> void:
	if not esperando_reaccion():
		return
	var reactor: Combatiente = _combate.pregunta_de_reaccion().reactor
	if respuesta == Respuesta.SIEMPRE:
		_reacciones_siempre[reactor.id] = true
		reactor.politica_reacciones = Combatiente.PoliticaReaccion.SIEMPRE
	_encolar(_combate.responder_reaccion(respuesta != Respuesta.NO))


func centro_global(celda: Vector2i) -> Vector2:
	return _mapa.celda_a_posicion(celda)


## Rombo de la casilla en coordenadas globales.
func rombo_global(celda: Vector2i) -> PackedVector2Array:
	var centro: Vector2 = centro_global(celda)
	var medio: Vector2 = _medio_rombo
	return PackedVector2Array([
		centro + Vector2(0, -medio.y), centro + Vector2(medio.x, 0),
		centro + Vector2(0, medio.y), centro + Vector2(-medio.x, 0)])


# --- Inicio e intenciones ---

func iniciar(encuentro: Encuentro, mapa: Mapa, party: ControlParty, camara: CamaraMundo) -> void:
	_encuentro = encuentro
	_mapa = mapa
	_party = party
	_camara = camara
	_medio_rombo = Vector2((mapa.get_node("Suelo") as TileMapLayer).tile_set.tile_size) / 2.0
	_party.entrar_en_combate()
	_animador = AnimadorCombate.new(config, mapa, get_parent(), camara)
	_actores.clear()
	var participantes: Array[Combatiente] = []
	for miembro: MiembroParty in party.miembros():
		var c: Combatiente = Combatiente.desde_personaje(StringName(miembro.name), miembro.definicion_de_reglas(), miembro.celda)
		EstadoPartyCombate.aplicar(c)
		if auto_jugar_party or _reacciones_siempre.has(c.id):
			c.politica_reacciones = Combatiente.PoliticaReaccion.SIEMPRE
		participantes.append(c)
		_actores[c.id] = miembro
	for enemigo: EnemigoEnMapa in encuentro.enemigos():
		var c: Combatiente = Combatiente.desde_criatura(StringName(enemigo.name), enemigo.definicion, enemigo.celda)
		participantes.append(c)
		_actores[c.id] = enemigo
	_combate = Combate.new(participantes, mapa.construir_grilla(), GameState.dados)
	_combate.pausar_tras_reacciones = true
	combate_iniciado.emit()
	_encolar(_combate.iniciar())


## Intención del jugador sobre una casilla (también la usan los tests y el arnés de capturas).
func click_en_celda(celda: Vector2i, es_paso: bool = false) -> void:
	if not esperando_decision():
		return
	if _modo.elegido != null:
		_encolar(_modo.al_click(_combate, _combate.turno_actual(), celda, es_paso).call())
		return
	var objetivo: Combatiente = _combatiente_vivo_en(celda)
	if objetivo != null and not objetivo.es_aliado_de(_combate.turno_actual()):
		_encolar(_combate.golpe(objetivo.id))
	elif es_paso:
		_encolar(_combate.paso(celda))
	else:
		var prevision: PrevisionTurno = prevision_actual()
		_plan.clear()
		if prevision.por_casilla.has(celda):
			_plan = prevision.alcance.tramos(celda)
		if _plan.is_empty():
			_encolar(_combate.zancada(celda))  # imposible: el evento informa el motivo
		else:
			_zancada_del_plan()


func terminar_turno_jugador() -> void:
	if esperando_decision():
		_encolar(_combate.terminar_turno())


## Depuración: restaura por completo a los miembros de la party en el combate en curso.
func restaurar_party_depuracion() -> void:
	for c: Combatiente in _combate.participantes:
		if c.bando == Combatiente.Bando.PARTY:
			c.restaurar_por_completo()
	_resaltados.queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if not en_curso():
		return
	if event is InputEventMouseMotion:
		var celda: Vector2i = _mapa.posicion_a_celda(get_global_mouse_position())
		if celda != _celda_cursor:
			_celda_cursor = celda
			_resaltados.queue_redraw()
	elif event.is_action_pressed("mover_a_click"):
		var es_paso: bool = event is InputEventMouseButton and (event as InputEventMouseButton).shift_pressed
		click_en_celda(_mapa.posicion_a_celda(get_global_mouse_position()), es_paso)
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and not event.echo and _teclas_de_accion(event as InputEventKey):
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_RIGHT:
		cancelar_accion()
	elif event.is_action_pressed(ACCION_TERMINAR_TURNO):
		terminar_turno_jugador()
		get_viewport().set_input_as_handled()


## 1-9: elegir acción; Esc: cancelar. Teclas fijas hasta la barra del HUD (C6).
func _teclas_de_accion(tecla: InputEventKey) -> bool:
	if tecla.keycode >= KEY_1 and tecla.keycode <= KEY_9:
		elegir_accion(tecla.keycode - KEY_1)
		return true
	if tecla.keycode == KEY_ESCAPE and _modo.elegido != null:
		cancelar_accion()
		return true
	return false


# --- Cola de eventos ---

func _encolar(eventos: Array[EventoCombate]) -> void:
	_cola.append_array(eventos)
	if not _animando:
		_procesar_cola()


func _procesar_cola() -> void:
	_animando = true
	_prevision = null
	_modo.cancelar()
	_resaltados.queue_redraw()
	while not _cola.is_empty():
		var evento: EventoCombate = _cola.pop_front()
		await _animador.animar(evento, _actores)
		evento_mostrado.emit(evento)
		if evento.tipo == EventoCombate.Tipo.ACCION_INVALIDA or evento.tipo == EventoCombate.Tipo.FIN_TURNO:
			_plan.clear()
	_animando = false
	if _combate.estado != Combate.Estado.EN_CURSO:
		_terminar()
		return
	if _combate.hay_reaccion_pendiente():
		_resaltados.queue_redraw()
		pregunta_reaccion.emit(_texto_pregunta())
		return
	if _combate.hay_continuacion():
		# La acción interrumpida por una reacción sigue, ya animada la reacción.
		_encolar(_combate.continuar())
		return
	var actor: Combatiente = _combate.turno_actual()
	_camara.objetivo = _actores[actor.id]
	if not _plan.is_empty():
		# Siguiente Zancada de un movimiento de varias acciones (cada una es una acción aparte).
		_zancada_del_plan()
		return
	if actor.bando == Combatiente.Bando.ENEMIGOS or auto_jugar_party:
		_encolar(IASimple.jugar_accion(_combate) if actor.bando == Combatiente.Bando.PARTY else ia_enemigos.call(_combate))
		return
	_prevision = PrevisionTurno.new(_combate)
	_resaltados.queue_redraw()
	esperando_jugador.emit()


## Ejecuta la siguiente Zancada del plan por el mismo recorrido que se previsualizó.
func _zancada_del_plan() -> void:
	var tramo: Array[Vector2i] = []
	tramo.assign(_plan.pop_front())
	_encolar(_combate.zancada(tramo.back(), tramo))


func _texto_pregunta() -> String:
	var pregunta: Dictionary = _combate.pregunta_de_reaccion()
	return "%s: ¿usar %s contra %s?" % [pregunta.reactor.id, (pregunta.capacidad as Capacidad).nombre, pregunta.disparo.actor.id]


# --- Fin del combate ---

func _terminar() -> void:
	var victoria: bool = _combate.estado == Combate.Estado.VICTORIA
	if victoria:
		EstadoPartyCombate.guardar(_party, _combate)
		for enemigo: EnemigoEnMapa in _encuentro.enemigos():
			if _combate.combatiente(StringName(enemigo.name)).condiciones.muerto:
				enemigo.queue_free()
		_encuentro.resuelto = true
	_combate = null
	_plan.clear()
	_resaltados.queue_redraw()
	combate_terminado.emit(victoria)


func _combatiente_vivo_en(celda: Vector2i) -> Combatiente:
	for c: Combatiente in _combate.participantes:
		if c.celda == celda and not c.condiciones.muerto:
			return c
	return null

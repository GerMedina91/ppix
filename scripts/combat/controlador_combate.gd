class_name ControladorCombate
extends Node2D
## Presentación del combate en el mismo mapa de exploración. Arma el Combate (rules/) a partir del
## Encuentro y la party, anima sus eventos en orden y traduce la entrada del jugador en intenciones.
## - Turnos de enemigos: IASimple. Turnos de la party: click en enemigo = Golpe; click en el suelo =
##   Zancada; Shift + click en una casilla vecina = Paso; acción `terminar_turno` (Espacio).
## - Dibuja (debajo de los actores): casilla del actor activo, alcance de la Zancada, camino al cursor
##   y enemigos golpeables.

signal combate_terminado(victoria: bool)
## Se emite cuando no queda nada por animar y le toca decidir al jugador.
signal esperando_jugador

const ACCION_TERMINAR_TURNO: StringName = &"terminar_turno"
const COLOR_ACTIVO: Color = Color(1.0, 0.85, 0.3, 0.5)
const COLOR_ZANCADA: Color = Color(0.3, 0.6, 1.0, 0.18)
const COLOR_CAMINO: Color = Color(0.4, 0.75, 1.0, 0.5)
const COLOR_OBJETIVO: Color = Color(1.0, 0.25, 0.25, 0.45)
const COLOR_DANIO: Color = Color(1.0, 0.4, 0.3)
const COLOR_FALLO: Color = Color(0.8, 0.8, 0.8)
const COLOR_INFO: Color = Color(0.7, 0.85, 1.0)
## Fracción del camino hacia el objetivo que recorre la embestida de un Golpe.
const FRACCION_EMBESTIDA: float = 0.3

@export var config: ConfigCombate
## Solo para pruebas y depuración: la IA juega también los turnos de la party.
var auto_jugar_party: bool = false

var _combate: Combate
var _encuentro: Encuentro
var _mapa: Mapa
var _party: ControlParty
var _camara: CamaraMundo
var _actores: Dictionary[StringName, ActorMapa] = {}
var _cola: Array[EventoCombate] = []
var _animando: bool = false
var _celda_cursor: Vector2i = Vector2i(-9999, -9999)
var _zancada: Dictionary[Vector2i, int] = {}


func _ready() -> void:
	z_as_relative = false
	z_index = -1


func en_curso() -> bool:
	return _combate != null and _combate.estado == Combate.Estado.EN_CURSO


func combate() -> Combate:
	return _combate


func animando() -> bool:
	return _animando


func actor_de(id: StringName) -> ActorMapa:
	return _actores.get(id)


## true si le toca decidir al jugador (turno de un miembro de la party y nada animándose).
func esperando_decision() -> bool:
	return en_curso() and not _animando and _cola.is_empty() and _combate.turno_actual().bando == Combatiente.Bando.PARTY


func iniciar(encuentro: Encuentro, mapa: Mapa, party: ControlParty, camara: CamaraMundo) -> void:
	_encuentro = encuentro
	_mapa = mapa
	_party = party
	_camara = camara
	_party.bloqueado = true
	_actores.clear()
	var participantes: Array[Combatiente] = []
	for miembro: MiembroParty in party.miembros():
		var c: Combatiente = Combatiente.desde_personaje(StringName(miembro.name), miembro.definicion, miembro.celda)
		_aplicar_estado_guardado(c)
		participantes.append(c)
		_actores[c.id] = miembro
	for enemigo: EnemigoEnMapa in encuentro.enemigos():
		var c: Combatiente = Combatiente.desde_criatura(StringName(enemigo.name), enemigo.definicion, enemigo.celda)
		participantes.append(c)
		_actores[c.id] = enemigo
	_combate = Combate.new(participantes, mapa.construir_grilla(), GameState.dados)
	_encolar(_combate.iniciar())


## Intención del jugador sobre una casilla (también la usan los tests y el arnés de capturas).
func click_en_celda(celda: Vector2i, es_paso: bool = false) -> void:
	if not esperando_decision():
		return
	var objetivo: Combatiente = _combatiente_vivo_en(celda)
	if objetivo != null and not objetivo.es_aliado_de(_combate.turno_actual()):
		_encolar(_combate.golpe(objetivo.id))
	elif es_paso:
		_encolar(_combate.paso(celda))
	else:
		_encolar(_combate.zancada(celda))


func terminar_turno_jugador() -> void:
	if esperando_decision():
		_encolar(_combate.terminar_turno())


func _unhandled_input(event: InputEvent) -> void:
	if not en_curso():
		return
	if event is InputEventMouseMotion:
		var celda: Vector2i = _mapa.posicion_a_celda(get_global_mouse_position())
		if celda != _celda_cursor:
			_celda_cursor = celda
			queue_redraw()
	elif event.is_action_pressed("mover_a_click"):
		var es_paso: bool = event is InputEventMouseButton and (event as InputEventMouseButton).shift_pressed
		click_en_celda(_mapa.posicion_a_celda(get_global_mouse_position()), es_paso)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(ACCION_TERMINAR_TURNO):
		terminar_turno_jugador()
		get_viewport().set_input_as_handled()


# --- Cola de eventos y animación ---

func _encolar(eventos: Array[EventoCombate]) -> void:
	_cola.append_array(eventos)
	if not _animando:
		_procesar_cola()


func _procesar_cola() -> void:
	_animando = true
	queue_redraw()
	while not _cola.is_empty():
		await _animar(_cola.pop_front())
	_animando = false
	if _combate.estado != Combate.Estado.EN_CURSO:
		_terminar()
		return
	var actor: Combatiente = _combate.turno_actual()
	_camara.objetivo = _actores[actor.id]
	if actor.bando == Combatiente.Bando.ENEMIGOS or auto_jugar_party:
		_encolar(IASimple.jugar_turno(_combate))
		return
	_zancada = _combate.casillas_de_zancada(actor)
	queue_redraw()
	esperando_jugador.emit()


func _animar(evento: EventoCombate) -> void:
	var actor: ActorMapa = _actores.get(evento.actor)
	match evento.tipo:
		EventoCombate.Tipo.INICIO_TURNO:
			_camara.objetivo = actor
			_zancada.clear()
			queue_redraw()
		EventoCombate.Tipo.MOVIMIENTO:
			await _animar_movimiento(actor, evento.datos.camino)
		EventoCombate.Tipo.GOLPE:
			await _animar_golpe(actor, _actores[evento.datos.objetivo], evento.datos.resultado)
		EventoCombate.Tipo.CAIDO:
			actor.mostrar_estado(ActorMapa.EstadoVisual.CAIDO)
			await _texto(actor, "caído", COLOR_DANIO)
		EventoCombate.Tipo.MUERTE:
			actor.mostrar_estado(ActorMapa.EstadoVisual.MUERTO)
			await _texto(actor, "muerto", COLOR_DANIO)
		EventoCombate.Tipo.RECUPERACION:
			await _texto(actor, "recuperación: moribundo %d" % evento.datos.moribundo, COLOR_INFO)
		EventoCombate.Tipo.ACCION_INVALIDA:
			if actor != null:
				await _texto(actor, "no se puede", COLOR_FALLO)
		_:
			pass


func _animar_movimiento(actor: ActorMapa, camino: Array) -> void:
	for casilla: Vector2i in camino:
		var duracion: float = ControlParty.duracion_de_paso(actor.celda, casilla, config.segundos_por_celda)
		actor.dar_paso(casilla, _mapa.celda_a_posicion(casilla), duracion)
		await actor.paso_terminado


func _animar_golpe(atacante: ActorMapa, objetivo: ActorMapa, resultado: ResultadoGolpe) -> void:
	var origen: Vector2 = atacante.global_position
	var embestida: Vector2 = origen.lerp(objetivo.global_position, FRACCION_EMBESTIDA)
	var tween: Tween = atacante.create_tween()
	tween.tween_property(atacante, "global_position", embestida, config.segundos_golpe / 2.0)
	tween.tween_property(atacante, "global_position", origen, config.segundos_golpe / 2.0)
	await tween.finished
	if resultado.impacto():
		await _texto(objetivo, ("¡%d!" if resultado.critico else "%d") % resultado.danio, COLOR_DANIO)
	else:
		await _texto(objetivo, GradoExito.nombre(resultado.prueba.grado), COLOR_FALLO)


func _texto(actor: ActorMapa, texto: String, color: Color) -> void:
	TextoFlotante.mostrar(get_parent(), actor.global_position, texto, color, config.segundos_texto_flotante)
	await get_tree().create_timer(config.pausa_entre_eventos).timeout


# --- Fin del combate ---

func _terminar() -> void:
	var victoria: bool = _combate.estado == Combate.Estado.VICTORIA
	if victoria:
		_guardar_estado_party()
		for enemigo: EnemigoEnMapa in _encuentro.enemigos():
			var c: Combatiente = _combate.combatiente(StringName(enemigo.name))
			if c.condiciones.muerto:
				enemigo.queue_free()
		_encuentro.resuelto = true
	_zancada.clear()
	queue_redraw()
	_combate = null
	combate_terminado.emit(victoria)


## PG y herido de la party persisten entre combates (GameState). Moribundos al ganar: se estabilizan.
func _guardar_estado_party() -> void:
	for miembro: MiembroParty in _party.miembros():
		var c: Combatiente = _combate.combatiente(StringName(miembro.name))
		c.estabilizar()
		GameState.estado_party[c.id] = {"pg": c.pg, "herido": c.condiciones.herido, "muerto": c.condiciones.muerto}


func _aplicar_estado_guardado(c: Combatiente) -> void:
	var guardado: Dictionary = GameState.estado_party.get(c.id, {})
	if guardado.is_empty():
		return
	c.pg = guardado.pg
	c.condiciones.herido = guardado.herido
	c.condiciones.muerto = guardado.get("muerto", false)
	c.condiciones.inconsciente = c.pg == 0 and not c.condiciones.muerto


func _combatiente_vivo_en(celda: Vector2i) -> Combatiente:
	for c: Combatiente in _combate.participantes:
		if c.celda == celda and not c.condiciones.muerto:
			return c
	return null


# --- Resaltados ---

func _draw() -> void:
	if not en_curso():
		return
	var actor: Combatiente = _combate.turno_actual()
	_rombo(actor.celda, COLOR_ACTIVO)
	if not esperando_decision():
		return
	for casilla: Vector2i in _zancada:
		_rombo(casilla, COLOR_ZANCADA)
	if _zancada.has(_celda_cursor):
		for casilla: Vector2i in _combate.camino_de_zancada(actor, _celda_cursor):
			_rombo(casilla, COLOR_CAMINO)
	var arma: DefinicionArma = actor.arma_principal()
	for c: Combatiente in _combate.participantes:
		if arma != null and Golpe.validar(actor, c, arma, _combate.vision()) == Golpe.Motivo.VALIDO:
			_rombo(c.celda, COLOR_OBJETIVO)


func _rombo(celda: Vector2i, color: Color) -> void:
	var centro: Vector2 = to_local(_mapa.celda_a_posicion(celda))
	var medio: Vector2 = Vector2(_mapa_tamano_tile()) / 2.0
	draw_colored_polygon(PackedVector2Array([
		centro + Vector2(0, -medio.y), centro + Vector2(medio.x, 0),
		centro + Vector2(0, medio.y), centro + Vector2(-medio.x, 0)]), color)


func _mapa_tamano_tile() -> Vector2i:
	return (_mapa.get_node("Suelo") as TileMapLayer).tile_set.tile_size

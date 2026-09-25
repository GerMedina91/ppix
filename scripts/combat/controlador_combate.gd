class_name ControladorCombate
extends Node2D
## Presentación del combate en el mismo mapa de exploración. Arma el Combate (rules/) a partir del
## Encuentro y la party, pasa sus eventos al AnimadorCombate en orden y traduce la entrada del jugador
## en intenciones. Los resaltados del suelo los dibuja ResaltadosCombate (hijo).
## - Enemigos: IASimple, una decisión por vez (se anima cada una antes de pedir la siguiente, así el
##   estado del Combate y lo que se ve en el mapa avanzan juntos).
## - Party: click en enemigo = Golpe; click en el suelo = Zancada; Shift + click = Paso;
##   acción `terminar_turno` (Espacio).

signal combate_iniciado
signal combate_terminado(victoria: bool)
## Se emite al animar cada evento (lo usa el HUD para el registro).
signal evento_mostrado(evento: EventoCombate)
## Se emite cuando no queda nada por animar y le toca decidir al jugador.
signal esperando_jugador

const ACCION_TERMINAR_TURNO: StringName = &"terminar_turno"
## Grupo para que herramientas (overlay de depuración) encuentren al controlador.
const GRUPO: StringName = &"controlador_combate"
const _SIN_CURSOR: Vector2i = Vector2i(-9999, -9999)

@export var config: ConfigCombate
## Solo para pruebas y depuración: la IA juega también los turnos de la party.
var auto_jugar_party: bool = false

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
var _zancada: Dictionary[Vector2i, int] = {}


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


func casillas_de_zancada_actuales() -> Dictionary[Vector2i, int]:
	return _zancada


## true si le toca decidir al jugador (turno de un miembro de la party y nada animándose).
func esperando_decision() -> bool:
	return en_curso() and not _animando and _cola.is_empty() and _combate.turno_actual().bando == Combatiente.Bando.PARTY


func centro_global(celda: Vector2i) -> Vector2:
	return _mapa.celda_a_posicion(celda)


## Rombo de la casilla en coordenadas globales.
func rombo_global(celda: Vector2i) -> PackedVector2Array:
	var centro: Vector2 = centro_global(celda)
	var medio: Vector2 = Vector2((_mapa.get_node("Suelo") as TileMapLayer).tile_set.tile_size) / 2.0
	return PackedVector2Array([
		centro + Vector2(0, -medio.y), centro + Vector2(medio.x, 0),
		centro + Vector2(0, medio.y), centro + Vector2(-medio.x, 0)])


# --- Inicio e intenciones ---

func iniciar(encuentro: Encuentro, mapa: Mapa, party: ControlParty, camara: CamaraMundo) -> void:
	_encuentro = encuentro
	_mapa = mapa
	_party = party
	_camara = camara
	_party.entrar_en_combate()
	_animador = AnimadorCombate.new(config, mapa, get_parent(), camara)
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
	combate_iniciado.emit()
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
	elif event.is_action_pressed(ACCION_TERMINAR_TURNO):
		terminar_turno_jugador()
		get_viewport().set_input_as_handled()


# --- Cola de eventos ---

func _encolar(eventos: Array[EventoCombate]) -> void:
	_cola.append_array(eventos)
	if not _animando:
		_procesar_cola()


func _procesar_cola() -> void:
	_animando = true
	_zancada.clear()
	_resaltados.queue_redraw()
	while not _cola.is_empty():
		var evento: EventoCombate = _cola.pop_front()
		await _animador.animar(evento, _actores)
		evento_mostrado.emit(evento)
	_animando = false
	if _combate.estado != Combate.Estado.EN_CURSO:
		_terminar()
		return
	var actor: Combatiente = _combate.turno_actual()
	_camara.objetivo = _actores[actor.id]
	if actor.bando == Combatiente.Bando.ENEMIGOS or auto_jugar_party:
		_encolar(IASimple.jugar_accion(_combate))
		return
	_zancada = _combate.casillas_de_zancada(actor)
	_resaltados.queue_redraw()
	esperando_jugador.emit()


# --- Fin del combate ---

func _terminar() -> void:
	var victoria: bool = _combate.estado == Combate.Estado.VICTORIA
	if victoria:
		_guardar_estado_party()
		for enemigo: EnemigoEnMapa in _encuentro.enemigos():
			if _combate.combatiente(StringName(enemigo.name)).condiciones.muerto:
				enemigo.queue_free()
		_encuentro.resuelto = true
	_combate = null
	_resaltados.queue_redraw()
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

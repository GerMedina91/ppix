class_name ControlParty
extends Node2D
## Controla a la party en exploración: interpreta la entrada del jugador (click y teclado)
## y mueve al líder por la grilla. Los miembros son hijos de este nodo; el primero es el líder.

## Se emite cada vez que el líder termina un paso.
signal lider_llego_a(celda: Vector2i)

@export var config: ConfigExploracion

## Mientras está en true se ignora la entrada (por ejemplo, durante una transición de mapa).
var bloqueado: bool = false:
	set(valor):
		bloqueado = valor
		if valor:
			_camino.clear()

var _mapa: Mapa
var _grilla: GrillaMapa
var _camino: Array[Vector2i] = []
var _miembros: Array[MiembroParty] = []


func _ready() -> void:
	for hijo: Node in get_children():
		if hijo is MiembroParty:
			_miembros.append(hijo)
	lider().paso_terminado.connect(_al_terminar_paso_lider)


func lider() -> MiembroParty:
	return _miembros[0]


func celda_lider() -> Vector2i:
	return lider().celda


## Ubica a toda la party en `celda` del mapa nuevo.
func entrar_a_mapa(mapa: Mapa, grilla: GrillaMapa, celda: Vector2i) -> void:
	_mapa = mapa
	_grilla = grilla
	_camino.clear()
	for miembro: MiembroParty in _miembros:
		miembro.colocar(celda, mapa.celda_a_posicion(celda))


## Lleva al líder hasta `destino` por el camino más corto. Si no hay camino, no hace nada.
func ir_a_celda(destino: Vector2i) -> void:
	if bloqueado or _grilla == null:
		return
	if destino == celda_lider():
		_camino.clear()
		return
	var camino: Array[Vector2i] = _grilla.camino(celda_lider(), destino)
	if camino.is_empty():
		return
	_camino = camino
	if not lider().esta_moviendose():
		_avanzar()


func _unhandled_input(event: InputEvent) -> void:
	if _mapa != null and event.is_action_pressed("mover_a_click"):
		ir_a_celda(_mapa.posicion_a_celda(get_global_mouse_position()))
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	if not bloqueado and _grilla != null and not lider().esta_moviendose():
		_avanzar()


## Da el próximo paso del líder: el teclado tiene prioridad y cancela el camino del click.
func _avanzar() -> void:
	var direccion: Vector2i = _direccion_teclado()
	if direccion != Vector2i.ZERO:
		_camino.clear()
		var destino: Vector2i = celda_lider() + direccion
		if _grilla.es_transitable(destino):
			_dar_paso_lider(destino)
	elif not _camino.is_empty():
		_dar_paso_lider(_camino.pop_front())


func _dar_paso_lider(destino: Vector2i) -> void:
	lider().dar_paso(destino, _mapa.celda_a_posicion(destino), config.segundos_por_paso)


func _al_terminar_paso_lider(celda: Vector2i) -> void:
	lider_llego_a.emit(celda)
	if not bloqueado:
		_avanzar()


## Dirección del teclado en 4 direcciones; si se aprietan dos ejes, gana el horizontal.
static func _direccion_teclado() -> Vector2i:
	var horizontal: int = roundi(Input.get_axis("mover_izquierda", "mover_derecha"))
	if horizontal != 0:
		return Vector2i(horizontal, 0)
	return Vector2i(0, roundi(Input.get_axis("mover_arriba", "mover_abajo")))

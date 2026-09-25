class_name ControlParty
extends Node2D
## Controla a la party en exploración: interpreta la entrada del jugador (click y teclado)
## y mueve al líder por la grilla. Los miembros son hijos de este nodo; el primero es el líder.
## Los demás lo siguen en fila india: cada seguidor recorre, a su ritmo, las celdas que va
## dejando el de adelante (SeguimientoFila). Cada miembro se mueve por su cuenta,
## así que separar la party a futuro es dejar de aplicar el seguimiento y dar órdenes por miembro.

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
## Un seguimiento por seguidor: _seguimientos[i] es el del miembro i + 1.
var _seguimientos: Array[SeguimientoFila] = []


func _ready() -> void:
	for hijo: Node in get_children():
		if hijo is MiembroParty:
			_miembros.append(hijo)
	lider().paso_terminado.connect(_al_terminar_paso_lider)
	for i in range(1, _miembros.size()):
		_seguimientos.append(SeguimientoFila.new())
		_miembros[i - 1].paso_iniciado.connect(_al_moverse_el_de_adelante.bind(i))
		_miembros[i].paso_terminado.connect(_al_terminar_paso_seguidor.bind(i))


func lider() -> MiembroParty:
	return _miembros[0]


func celda_lider() -> Vector2i:
	return lider().celda


func miembros() -> Array[MiembroParty]:
	return _miembros


## Ubica a la party en el mapa nuevo: el miembro i en celdas[i] (formación en cadena, líder primero).
func entrar_a_mapa(mapa: Mapa, grilla: GrillaMapa, celdas: Array[Vector2i]) -> void:
	_mapa = mapa
	_grilla = grilla
	_camino.clear()
	for seguimiento: SeguimientoFila in _seguimientos:
		seguimiento.limpiar()
	for i in _miembros.size():
		_miembros[i].colocar(celdas[i], mapa.celda_a_posicion(celdas[i]))


## Vuelve a armar la fila en `celdas` (formación en cadena) sin cambiar de mapa (p. ej. tras un combate).
func reagrupar(celdas: Array[Vector2i]) -> void:
	entrar_a_mapa(_mapa, _grilla, celdas)


func grilla() -> GrillaMapa:
	return _grilla


func set_grilla(grilla_nueva: GrillaMapa) -> void:
	_grilla = grilla_nueva


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
	if bloqueado:
		return
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
		if _grilla.puede_dar_paso(celda_lider(), destino):
			_dar_paso_lider(destino)
	elif not _camino.is_empty():
		_dar_paso_lider(_camino.pop_front())


func _dar_paso_lider(destino: Vector2i) -> void:
	_mover(lider(), destino)


func _mover(miembro: MiembroParty, destino: Vector2i) -> void:
	var duracion: float = duracion_de_paso(miembro.celda, destino, config.segundos_por_celda)
	miembro.dar_paso(destino, _mapa.celda_a_posicion(destino), duracion)


## Duración proporcional a la distancia en la grilla: ortogonal = 1 celda, diagonal = √2.
static func duracion_de_paso(desde: Vector2i, hasta: Vector2i, segundos_por_celda: float) -> float:
	return Vector2(hasta - desde).length() * segundos_por_celda


func _al_moverse_el_de_adelante(desde: Vector2i, _hasta: Vector2i, indice_seguidor: int) -> void:
	var seguidor: MiembroParty = _miembros[indice_seguidor]
	_seguimientos[indice_seguidor - 1].registrar_salida(desde, seguidor.celda)
	if not seguidor.esta_moviendose():
		_avanzar_seguidor(indice_seguidor)


func _al_terminar_paso_seguidor(_celda: Vector2i, indice_seguidor: int) -> void:
	_avanzar_seguidor(indice_seguidor)


func _avanzar_seguidor(indice_seguidor: int) -> void:
	var seguimiento: SeguimientoFila = _seguimientos[indice_seguidor - 1]
	if seguimiento.tiene_pendientes():
		_mover(_miembros[indice_seguidor], seguimiento.proxima())


func _al_terminar_paso_lider(celda: Vector2i) -> void:
	lider_llego_a.emit(celda)
	if not bloqueado:
		_avanzar()


## Dirección del teclado en direcciones de pantalla (W arriba, D derecha...), traducida a la grilla.
## Cada tecla sola es un paso diagonal de la grilla; dos teclas juntas dan un paso ortogonal.
func _direccion_teclado() -> Vector2i:
	var pantalla: Vector2 = Vector2(
		roundi(Input.get_axis("mover_izquierda", "mover_derecha")),
		roundi(Input.get_axis("mover_arriba", "mover_abajo")))
	return _mapa.direccion_de_pantalla(pantalla)

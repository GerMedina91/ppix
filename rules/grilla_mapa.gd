class_name GrillaMapa
extends RefCounted
## Grilla lógica de un mapa: qué celdas se pueden pisar y cómo llegar de una a otra.
## Lógica pura (sin nodos). Cada celda es una casilla de 5 pies.
## Pathfinding en 8 direcciones sin cortar esquinas: una diagonal solo es válida
## si las dos celdas ortogonales que la flanquean son transitables.

var _astar: AStarGrid2D = AStarGrid2D.new()


## Crea una grilla que cubre `region`, con todas las celdas no transitables.
func _init(region: Rect2i) -> void:
	_astar.region = region
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	_astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	_astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	_astar.update()
	_astar.fill_solid_region(region, true)


func region() -> Rect2i:
	return _astar.region


func set_transitable(celda: Vector2i, transitable: bool) -> void:
	if not _astar.is_in_boundsv(celda):
		push_error("GrillaMapa: celda fuera de la región %s" % celda)
		return
	_astar.set_point_solid(celda, not transitable)


func es_transitable(celda: Vector2i) -> bool:
	return _astar.is_in_boundsv(celda) and not _astar.is_point_solid(celda)


## true si se puede dar un paso de `desde` a una celda vecina `hasta` (8 direcciones).
## Un paso diagonal no puede cortar esquinas: las dos celdas ortogonales que lo flanquean
## tienen que ser transitables.
func puede_dar_paso(desde: Vector2i, hasta: Vector2i) -> bool:
	var paso: Vector2i = hasta - desde
	if paso == Vector2i.ZERO or absi(paso.x) > 1 or absi(paso.y) > 1:
		return false
	if not es_transitable(hasta):
		return false
	if paso.x != 0 and paso.y != 0:
		return es_transitable(desde + Vector2i(paso.x, 0)) and es_transitable(desde + Vector2i(0, paso.y))
	return true


## Camino de `desde` a `hasta`, sin incluir `desde`. Vacío si no hay camino
## o si alguno de los extremos no es transitable.
func camino(desde: Vector2i, hasta: Vector2i) -> Array[Vector2i]:
	var resultado: Array[Vector2i] = []
	if not es_transitable(desde) or not es_transitable(hasta):
		return resultado
	var puntos: Array[Vector2i] = _astar.get_id_path(desde, hasta)
	for i in range(1, puntos.size()):
		resultado.append(puntos[i])
	return resultado

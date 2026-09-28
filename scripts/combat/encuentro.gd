@tool
class_name Encuentro
extends Node2D
## Encuentro de combate dentro de un mapa: sus enemigos (EnemigoEnMapa) y lo que lo dispara
## (hijos DisparadorEncuentro). Se resuelve una sola vez. En el editor (@tool) dibuja sus zonas sobre el
## suelo y avisa si le falta algo.

## Color de las zonas en el editor (no se ve en el juego).
const COLOR_ZONA_EDITOR: Color = Color(1.0, 0.3, 0.2, 0.35)

@export var id: StringName = &"":
	set(valor):
		id = valor
		update_configuration_warnings()

var resuelto: bool = false


func enemigos() -> Array[EnemigoEnMapa]:
	var lista: Array[EnemigoEnMapa] = []
	for hijo: Node in get_children():
		if hijo is EnemigoEnMapa:
			lista.append(hijo)
	return lista


func disparadores() -> Array[DisparadorEncuentro]:
	var lista: Array[DisparadorEncuentro] = []
	for hijo: Node in get_children():
		if hijo is DisparadorEncuentro:
			lista.append(hijo)
	return lista


## true si no está resuelto y alguno de sus disparadores se activa.
func evaluar(celdas_party: Array[Vector2i]) -> bool:
	if resuelto:
		return false
	return disparadores().any(func(d: DisparadorEncuentro) -> bool: return d.debe_disparar(celdas_party, self))


func _ready() -> void:
	set_process(Engine.is_editor_hint())
	if Engine.is_editor_hint():
		child_entered_tree.connect(func(_n: Node) -> void: update_configuration_warnings())
		child_exiting_tree.connect(func(_n: Node) -> void: update_configuration_warnings())


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()


## En el editor: el contorno de cada casilla de sus zonas.
func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	var suelo: TileMapLayer = ValidacionMapa.suelo_de(self)
	if suelo == null:
		return
	var medio: Vector2 = Vector2(suelo.tile_set.tile_size) / 2.0
	for disparador: Node in get_children():
		var zona: Variant = disparador.get("zona")
		if not zona is Rect2i:
			continue
		for x in range(zona.position.x, zona.end.x):
			for y in range(zona.position.y, zona.end.y):
				var centro: Vector2 = to_local(suelo.to_global(suelo.map_to_local(Vector2i(x, y))))
				draw_colored_polygon(PackedVector2Array([centro + Vector2(0, -medio.y), centro + Vector2(medio.x, 0),
					centro + Vector2(0, medio.y), centro + Vector2(-medio.x, 0)]), COLOR_ZONA_EDITOR)


func _get_configuration_warnings() -> PackedStringArray:
	var avisos: PackedStringArray = ValidacionMapa.avisos_de_id(self, id, "encuentro")
	if enemigos().is_empty():
		avisos.append("No tiene enemigos (hijos EnemigoEnMapa).")
	var zonas: Array[Node] = get_children().filter(func(n: Node) -> bool: return n is DisparadorEncuentro)
	if zonas.is_empty():
		avisos.append("No tiene disparador (un hijo ZonaEncuentro con su rectángulo de casillas).")
	for zona: Node in zonas:
		var rect: Variant = zona.get("zona")
		if rect is Rect2i and (rect as Rect2i).has_area() == false:
			avisos.append("La zona de %s está vacía (tamaño 0)." % zona.name)
	return avisos

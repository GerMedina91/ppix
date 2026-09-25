class_name OclusionParedes
extends RefCounted
## Criterio de oclusión: cuándo una pared tapa a un actor que hay que mantener visible.
##
## Actores a mantener visibles: cualquier nodo del grupo GRUPO_VISIBLES que implemente
## `rect_visible_global() -> Rect2` (el rect de su sprite en pantalla). Su `global_position`
## es su base (punto de y-sort). Hoy: la party; en M3 también enemigos y NPCs.

const GRUPO_VISIBLES: StringName = &"mantener_visible"
const METODO_RECT: StringName = &"rect_visible_global"


## Una pared tapa a un actor si su base está delante (más abajo en pantalla, como decide el y-sort)
## y su silueta se superpone con el rect del actor.
static func tapa(silueta_pared: PackedVector2Array, base_pared: float, rect_actor: Rect2, base_actor: float) -> bool:
	if base_pared <= base_actor:
		return false
	return not Geometry2D.intersect_polygons(silueta_pared, _poligono(rect_actor)).is_empty()


## Silueta de un bloque isométrico: hexágono formado por la tapa (rombo) y las dos caras visibles.
## `centro_base` es el centro del rombo de su celda; `alto` es la altura de la cara en píxeles.
static func silueta_bloque(centro_base: Vector2, tamano_tile: Vector2, alto: float) -> PackedVector2Array:
	var medio: Vector2 = tamano_tile / 2.0
	return PackedVector2Array([
		centro_base + Vector2(0, -medio.y - alto),
		centro_base + Vector2(medio.x, -alto),
		centro_base + Vector2(medio.x, 0),
		centro_base + Vector2(0, medio.y),
		centro_base + Vector2(-medio.x, 0),
		centro_base + Vector2(-medio.x, -alto),
	])


static func _poligono(rect: Rect2) -> PackedVector2Array:
	return PackedVector2Array([rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)])

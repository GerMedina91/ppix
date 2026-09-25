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
## y su dibujo se superpone con el del actor.
static func tapa(rect_pared: Rect2, base_pared: float, rect_actor: Rect2, base_actor: float) -> bool:
	return base_pared > base_actor and rect_pared.intersects(rect_actor)

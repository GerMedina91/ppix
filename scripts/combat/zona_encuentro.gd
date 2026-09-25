class_name ZonaEncuentro
extends DisparadorEncuentro
## Dispara el encuentro cuando algún miembro de la party entra a la zona (rectángulo de casillas).

@export var zona: Rect2i = Rect2i()


func debe_disparar(celdas_party: Array[Vector2i], _encuentro: Encuentro) -> bool:
	return celdas_party.any(func(c: Vector2i) -> bool: return zona.has_point(c))

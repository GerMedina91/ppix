@tool
class_name ZonaEncuentro
extends DisparadorEncuentro
## Dispara el encuentro cuando algún miembro de la party entra a la zona (rectángulo de casillas: posición =
## casilla de arriba a la izquierda en la grilla, tamaño = ancho y alto). El Encuentro la dibuja en el editor.

@export var zona: Rect2i = Rect2i():
	set(valor):
		zona = valor
		if get_parent() != null:
			get_parent().update_configuration_warnings()


func debe_disparar(celdas_party: Array[Vector2i], _encuentro: Encuentro) -> bool:
	return celdas_party.any(func(c: Vector2i) -> bool: return zona.has_point(c))

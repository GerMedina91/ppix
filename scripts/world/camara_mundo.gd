class_name CamaraMundo
extends Camera2D
## Cámara de exploración: sigue a un objetivo y no se sale de los bordes del mapa.
## Sin suavizado, para que el pixel art no tiemble. Si el mapa es más chico que la pantalla
## en algún eje, lo centra en ese eje.

var objetivo: Node2D


## Ajusta los límites al mapa nuevo y salta directo al objetivo.
func ajustar_a_mapa(rect_mapa: Rect2) -> void:
	var limites: Rect2 = limites_para(rect_mapa, get_viewport_rect().size / zoom)
	limit_left = roundi(limites.position.x)
	limit_top = roundi(limites.position.y)
	limit_right = roundi(limites.end.x)
	limit_bottom = roundi(limites.end.y)
	_seguir()
	reset_smoothing()


func _process(_delta: float) -> void:
	_seguir()


func _seguir() -> void:
	if objetivo != null:
		global_position = objetivo.global_position.round()


## Límites de cámara para un mapa: el rect del mapa, agrandado y centrado en los ejes
## donde el mapa es más chico que el área visible.
static func limites_para(rect_mapa: Rect2, tamano_visible: Vector2) -> Rect2:
	var limites: Rect2 = rect_mapa
	for eje: int in [Vector2.AXIS_X, Vector2.AXIS_Y]:
		if rect_mapa.size[eje] < tamano_visible[eje]:
			limites.position[eje] = rect_mapa.get_center()[eje] - tamano_visible[eje] / 2.0
			limites.size[eje] = tamano_visible[eje]
	return limites

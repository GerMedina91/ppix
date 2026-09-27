class_name Interactuable
extends Node2D
## Objeto del mapa con el que la party interactúa por click (M4c): la party camina hasta una casilla vecina
## y el Mundo lo abre según su tipo (PuntoEstable; en M4e, objetos con recuerdos). Ocupa su casilla (no se
## pisa). Solo presentación: el Mapa lo ubica en el centro de la casilla de su posición.

## Placeholder: un bloque más bajo que un personaje, con los pies en el centro del rombo.
const TAMANO_PLACEHOLDER: Vector2 = Vector2(24, 32)

@export var color_placeholder: Color = Color.WHITE

var celda: Vector2i = Vector2i.ZERO


func colocar(celda_nueva: Vector2i, posicion_global: Vector2) -> void:
	celda = celda_nueva
	global_position = posicion_global


func _draw() -> void:
	draw_rect(Rect2(Vector2(-TAMANO_PLACEHOLDER.x / 2.0, -TAMANO_PLACEHOLDER.y), TAMANO_PLACEHOLDER), color_placeholder)

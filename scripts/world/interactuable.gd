@tool
class_name Interactuable
extends Node2D
## Objeto del mapa con el que la party interactúa por click (M4c): la party camina hasta una casilla vecina
## y InteraccionesMundo lo abre según su tipo (PuntoEstable, ObjetoRecuerdo, PuestoTasador, CuerpoCompanero,
## DisparadorDialogo). Ocupa su casilla (no se pisa). Solo presentación: el Mapa lo ubica en el centro de la
## casilla de su posición. En el editor (@tool) se acomoda solo al centro de su casilla y avisa si está mal
## configurado (ValidacionMapa).

## Placeholder: un bloque más bajo que un personaje, con los pies en el centro del rombo.
const TAMANO_PLACEHOLDER: Vector2 = Vector2(24, 32)

@export var color_placeholder: Color = Color.WHITE:
	set(valor):
		color_placeholder = valor
		queue_redraw()

var celda: Vector2i = Vector2i.ZERO


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		set_notify_transform(true)


func _notification(que: int) -> void:
	if que == NOTIFICATION_TRANSFORM_CHANGED and Engine.is_editor_hint():
		ValidacionMapa.centrar(self)
		update_configuration_warnings()


func colocar(celda_nueva: Vector2i, posicion_global: Vector2) -> void:
	celda = celda_nueva
	global_position = posicion_global


func _draw() -> void:
	draw_rect(Rect2(Vector2(-TAMANO_PLACEHOLDER.x / 2.0, -TAMANO_PLACEHOLDER.y), TAMANO_PLACEHOLDER), color_placeholder)


func _get_configuration_warnings() -> PackedStringArray:
	return ValidacionMapa.avisos_de_casilla(self)

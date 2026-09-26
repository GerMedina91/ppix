class_name EntradaCombate
extends Node2D
## Entrada del jugador durante el combate (hijo del ControladorCombate): cursor, click (Shift = Paso),
## terminar turno, teclas 1-9 para conjuros, Sostener y Arcadas, y Esc o click derecho para cancelar.
## Solo traduce eventos de entrada en llamadas al controlador. Teclas fijas hasta la barra del HUD (C6).

const ACCION_TERMINAR_TURNO: StringName = &"terminar_turno"
const ACCION_CLICK: StringName = &"mover_a_click"

var controlador: ControladorCombate


func _unhandled_input(event: InputEvent) -> void:
	if not controlador.en_curso():
		return
	if event is InputEventMouseMotion:
		controlador.mover_cursor(controlador.celda_en(get_global_mouse_position()))
	elif event.is_action_pressed(ACCION_CLICK):
		var es_paso: bool = event is InputEventMouseButton and (event as InputEventMouseButton).shift_pressed
		controlador.click_en_celda(controlador.celda_en(get_global_mouse_position()), es_paso)
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and not event.echo and _tecla_de_accion(event as InputEventKey):
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_RIGHT:
		controlador.cancelar_accion()
	elif event.is_action_pressed(ACCION_TERMINAR_TURNO):
		controlador.terminar_turno_jugador()
		get_viewport().set_input_as_handled()


## 1-9: elegir acción; Esc: cancelar el conjuro elegido.
func _tecla_de_accion(tecla: InputEventKey) -> bool:
	if tecla.keycode >= KEY_1 and tecla.keycode <= KEY_9:
		controlador.elegir_accion(tecla.keycode - KEY_1)
		return true
	if tecla.keycode == KEY_ESCAPE and controlador.modo_accion().elegido != null:
		controlador.cancelar_accion()
		return true
	return false

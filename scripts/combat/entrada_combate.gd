class_name EntradaCombate
extends Node2D
## Entrada del jugador durante el combate (hijo del ControladorCombate), con las acciones del InputMap:
## cursor, `mover_a_click` (Shift = Paso), `terminar_turno`, `accion_1` a `accion_9` (conjuros, Sostener,
## Arcadas y, con un conjuro de costo variable elegido, sus acciones), `cancelar_accion` (Esc o click
## derecho) y `alternar_incluirse` (emanación: incluirse o no). Solo llama al controlador.

const ACCION_TERMINAR_TURNO: StringName = &"terminar_turno"
const ACCION_CLICK: StringName = &"mover_a_click"
const ACCION_CANCELAR: StringName = &"cancelar_accion"
const ACCION_INCLUIRSE: StringName = &"alternar_incluirse"
const ACCIONES_NUMERADAS: int = 9

var controlador: ControladorCombate


func _unhandled_input(event: InputEvent) -> void:
	if not controlador.en_curso():
		return
	if event is InputEventMouseMotion:
		controlador.mover_cursor(controlador.celda_en(get_global_mouse_position()))
		return
	if event is InputEventKey and (event as InputEventKey).echo:
		return
	if event.is_action_pressed(ACCION_CLICK):
		var es_paso: bool = event is InputEventMouseButton and (event as InputEventMouseButton).shift_pressed
		controlador.click_en_celda(controlador.celda_en(get_global_mouse_position()), es_paso)
	elif event.is_action_pressed(ACCION_CANCELAR):
		controlador.cancelar_accion()
	elif event.is_action_pressed(ACCION_INCLUIRSE):
		controlador.alternar_incluirse()
	elif event.is_action_pressed(ACCION_TERMINAR_TURNO):
		controlador.terminar_turno_jugador()
	elif not _accion_numerada(event):
		return
	get_viewport().set_input_as_handled()


func _accion_numerada(event: InputEvent) -> bool:
	for i in ACCIONES_NUMERADAS:
		if event.is_action_pressed(StringName("accion_%d" % (i + 1))):
			controlador.elegir_accion(i)
			return true
	return false

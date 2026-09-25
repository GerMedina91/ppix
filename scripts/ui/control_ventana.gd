class_name ControlVentana
extends Node
## Alterna pantalla completa con F11 (acción `alternar_pantalla_completa`).
## En web, la tecla cuenta como gesto del usuario, que el navegador exige para entrar a pantalla completa.
## Hoy vive en la escena del mundo; cuando haya menú principal, va a la escena raíz.


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("alternar_pantalla_completa"):
		DisplayServer.window_set_mode(modo_siguiente(DisplayServer.window_get_mode()))
		get_viewport().set_input_as_handled()


## Desde pantalla completa (normal o exclusiva) vuelve a ventana; desde cualquier otro modo, pasa a pantalla completa.
static func modo_siguiente(actual: DisplayServer.WindowMode) -> DisplayServer.WindowMode:
	if actual == DisplayServer.WINDOW_MODE_FULLSCREEN or actual == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		return DisplayServer.WINDOW_MODE_WINDOWED
	return DisplayServer.WINDOW_MODE_FULLSCREEN

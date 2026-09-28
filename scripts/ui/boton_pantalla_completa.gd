class_name BotonPantallaCompleta
extends Button
## Alterna pantalla completa (GDD 5: la versión web lo necesita; en escritorio también sirve). En el navegador
## la pantalla completa solo se puede pedir desde una acción del jugador: por eso es un botón.

const TEXTO_ENTRAR: String = "Pantalla completa"
const TEXTO_SALIR: String = "Salir de pantalla completa"


func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	pressed.connect(alternar)
	_actualizar_texto()


func alternar() -> void:
	var completa: bool = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if completa else DisplayServer.WINDOW_MODE_FULLSCREEN)
	_actualizar_texto.call_deferred()


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_SIZE_CHANGED or que == NOTIFICATION_APPLICATION_FOCUS_IN:
		_actualizar_texto()


func _actualizar_texto() -> void:
	text = TEXTO_SALIR if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN else TEXTO_ENTRAR

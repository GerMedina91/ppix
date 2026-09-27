class_name PantallaInicio
extends CanvasLayer
## Pantalla de inicio (M4g, placeholder): Continuar (si hay partida guardada) y Nueva partida (con
## confirmación si pisa la existente: hay una sola ranura). Aspecto del EstiloHud.

const ESCENA_MUNDO: String = "res://scenes/world/mundo.tscn"
const TITULO: String = "TODO_LORE: título del juego"
const CONFIRMACION: String = "Empezar de nuevo borra la partida guardada."

@export var estilo: EstiloHud

var _botones: VBoxContainer
var _mensaje: Label


func _ready() -> void:
	var columna: VBoxContainer = ConstruccionUi.panel_centrado(ConstruccionUi.raiz(self, estilo), 260, 0.5)
	columna.add_child(ConstruccionUi.titulo(TITULO, estilo))
	_botones = VBoxContainer.new()
	columna.add_child(_botones)
	_mensaje = ConstruccionUi.etiqueta("")
	columna.add_child(_mensaje)
	_mostrar_menu()


func botones() -> PackedStringArray:
	return ConstruccionUi.textos_de_botones(_botones)


func continuar() -> void:
	if not SaveSystem.cargar():
		_mensaje.text = "La partida guardada no se pudo cargar."
		return
	get_tree().change_scene_to_file(ESCENA_MUNDO)


## Con partida guardada, primero pide confirmación.
func nueva_partida(confirmado: bool = false) -> void:
	if SaveSystem.hay_partida() and not confirmado:
		ConstruccionUi.vaciar(_botones)
		_botones.add_child(ConstruccionUi.etiqueta(CONFIRMACION))
		_botones.add_child(ConstruccionUi.boton("Sí, empezar de nuevo", nueva_partida.bind(true)))
		_botones.add_child(ConstruccionUi.boton("No", _mostrar_menu))
		return
	SaveSystem.borrar()
	GameState.nueva_partida()
	GameState.reiniciar_dados(int(Time.get_unix_time_from_system()))
	get_tree().change_scene_to_file(ESCENA_MUNDO)


func _mostrar_menu() -> void:
	ConstruccionUi.vaciar(_botones)
	_botones.add_child(ConstruccionUi.boton("Continuar", continuar, "" if SaveSystem.hay_partida() else "no hay partida guardada"))
	_botones.add_child(ConstruccionUi.boton("Nueva partida", nueva_partida.bind(false)))

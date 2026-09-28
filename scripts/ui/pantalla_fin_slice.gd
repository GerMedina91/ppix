class_name PantallaFinSlice
extends CanvasLayer
## Fin del vertical slice (M5, placeholder): al tomar el fragmento 2 del Doliente, la visión (TODO_LORE), un corte a
## negro y "Fin del slice" con "Volver al inicio". Aspecto del EstiloHud. Tapa todo y frena el mouse.

signal volver_pedido

const VISION: String = "TODO_LORE: la visión del fragmento."
const FIN: String = "Fin del slice"
const SEGUNDOS_FUNDIDO: float = 1.5
## Oscuridad del fondo mientras se lee la visión.
const ALFA_VISION: float = 0.6
const ESCENA_INICIO: String = "res://scenes/ui/inicio.tscn"

@export var estilo: EstiloHud
## Para tests: sin fundido y sin cambiar de escena al volver (solo avisa por `volver_pedido`).
@export var solo_avisar: bool = false

var _negro: ColorRect
var _vision: VBoxContainer
var _fin: VBoxContainer


func _ready() -> void:
	layer = 20
	var raiz: Control = ConstruccionUi.raiz(self, estilo)
	raiz.mouse_filter = Control.MOUSE_FILTER_STOP
	_negro = ColorRect.new()
	_negro.color = Color(0, 0, 0, 0)
	_negro.set_anchors_preset(Control.PRESET_FULL_RECT)
	raiz.add_child(_negro)
	_vision = ConstruccionUi.panel_centrado(raiz, 320, 0.5)
	_vision.add_child(ConstruccionUi.etiqueta(VISION))
	_vision.add_child(ConstruccionUi.boton("Seguir", _cortar_a_negro))
	_fin = VBoxContainer.new()
	_fin.set_anchors_preset(Control.PRESET_CENTER)
	_fin.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_fin.grow_vertical = Control.GROW_DIRECTION_BOTH
	_fin.add_child(ConstruccionUi.titulo(FIN, estilo))
	_fin.add_child(ConstruccionUi.boton("Volver al inicio", volver_al_inicio))
	raiz.add_child(_fin)
	visible = false


func mostrar() -> void:
	_negro.color.a = ALFA_VISION
	_vision.get_parent().visible = true
	_fin.visible = false
	visible = true


func mostrando_fin() -> bool:
	return visible and _fin.visible


func _cortar_a_negro() -> void:
	_vision.get_parent().visible = false
	if solo_avisar:
		_negro.color.a = 1.0
	else:
		var tween: Tween = create_tween()
		tween.tween_property(_negro, "color:a", 1.0, SEGUNDOS_FUNDIDO)
		await tween.finished
	_fin.visible = true


func seguir() -> void:
	await _cortar_a_negro()


func volver_al_inicio() -> void:
	volver_pedido.emit()
	if not solo_avisar:
		get_tree().change_scene_to_file(ESCENA_INICIO)

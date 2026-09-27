class_name PanelPerdida
extends CanvasLayer
## Elegir el recuerdo integrado que se pierde al rearmarse el Eco (GDD 4.3; funcional, placeholder). Un botón
## por integrado; no se puede cerrar sin elegir. Aspecto del EstiloHud.

signal elegido(recuerdo: DefinicionRecuerdo)

const TITULO: String = "El Eco se rearma"
const EXPLICACION: String = "Pierde uno de sus recuerdos integrados. Elegí cuál:"

@export var estilo: EstiloHud

var _botones: VBoxContainer


func _ready() -> void:
	layer = 6
	var estilo_efectivo: EstiloHud = estilo if estilo != null else EstiloHud.por_defecto()
	var raiz: Control = Control.new()
	raiz.theme = estilo_efectivo.tema()
	raiz.set_anchors_preset(Control.PRESET_FULL_RECT)
	raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(raiz)
	var panel: PanelContainer = PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.4
	panel.anchor_bottom = 0.4
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	var columna: VBoxContainer = VBoxContainer.new()
	var titulo: Label = Label.new()
	titulo.text = TITULO
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_color_override("font_color", estilo_efectivo.color_activo)
	var texto: Label = Label.new()
	texto.text = EXPLICACION
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_botones = VBoxContainer.new()
	for hijo: Control in [titulo, texto, _botones]:
		columna.add_child(hijo)
	panel.add_child(columna)
	raiz.add_child(panel)
	visible = false


func abierto() -> bool:
	return visible


## Nombres de las opciones (para tests y capturas).
func opciones() -> PackedStringArray:
	var nombres: PackedStringArray = PackedStringArray()
	for boton: Node in _botones.get_children():
		nombres.append((boton as Button).text)
	return nombres


func abrir(integrados: Array[DefinicionRecuerdo]) -> void:
	for hijo: Node in _botones.get_children():
		_botones.remove_child(hijo)
		hijo.queue_free()
	for recuerdo: DefinicionRecuerdo in integrados:
		var boton: Button = Button.new()
		boton.text = recuerdo.nombre
		boton.focus_mode = Control.FOCUS_NONE
		boton.pressed.connect(elegir.bind(recuerdo))
		_botones.add_child(boton)
	visible = true


func elegir(recuerdo: DefinicionRecuerdo) -> void:
	visible = false
	elegido.emit(recuerdo)

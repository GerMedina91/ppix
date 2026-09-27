class_name PanelOpciones
extends CanvasLayer
## Panel genérico de elección (funcional, placeholder): título, texto y un botón por opción. Lo usan las
## fuentes de recuerdos (enemigo inconsciente, cuerpo de un compañero). Aspecto del EstiloHud.

signal elegida(indice: int)

@export var estilo: EstiloHud

var _titulo: Label
var _texto: Label
var _botones: HBoxContainer


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
	_titulo = Label.new()
	_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_titulo.add_theme_color_override("font_color", estilo_efectivo.color_activo)
	_texto = Label.new()
	_texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_botones = HBoxContainer.new()
	_botones.alignment = BoxContainer.ALIGNMENT_CENTER
	for hijo: Control in [_titulo, _texto, _botones]:
		columna.add_child(hijo)
	panel.add_child(columna)
	raiz.add_child(panel)
	visible = false


func abierto() -> bool:
	return visible


func opciones() -> PackedStringArray:
	var textos: PackedStringArray = PackedStringArray()
	for boton: Node in _botones.get_children():
		textos.append((boton as Button).text)
	return textos


## Muestra el panel; la respuesta llega por `elegida` (índice de la opción).
func abrir(titulo: String, texto: String, textos_opciones: PackedStringArray) -> void:
	_titulo.text = titulo
	_texto.text = texto
	_texto.visible = not texto.is_empty()
	for hijo: Node in _botones.get_children():
		_botones.remove_child(hijo)
		hijo.queue_free()
	for i in textos_opciones.size():
		var boton: Button = Button.new()
		boton.text = textos_opciones[i]
		boton.focus_mode = Control.FOCUS_NONE
		boton.pressed.connect(elegir.bind(i))
		_botones.add_child(boton)
	visible = true


func elegir(indice: int) -> void:
	visible = false
	elegida.emit(indice)

class_name AvisoMundo
extends CanvasLayer
## Aviso breve en exploración (placeholder), abajo al centro: "El Eco recupera 2 recuerdos". Se va solo.

@export var estilo: EstiloHud
@export var segundos: float = 3.0

var _panel: PanelContainer
var _texto: Label
var _tween: Tween


func _ready() -> void:
	layer = 6
	var estilo_efectivo: EstiloHud = estilo if estilo != null else EstiloHud.por_defecto()
	var raiz: Control = Control.new()
	raiz.theme = estilo_efectivo.tema()
	raiz.set_anchors_preset(Control.PRESET_FULL_RECT)
	raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(raiz)
	_panel = PanelContainer.new()
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.anchor_left = 0.5
	_panel.anchor_right = 0.5
	_panel.anchor_top = 0.85
	_panel.anchor_bottom = 0.85
	_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	_texto = Label.new()
	_panel.add_child(_texto)
	raiz.add_child(_panel)
	_panel.visible = false


func texto() -> String:
	return _texto.text if _panel.visible else ""


func mostrar(mensaje: String) -> void:
	_texto.text = mensaje
	_panel.visible = true
	_panel.modulate.a = 1.0
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_interval(segundos)
	_tween.tween_property(_panel, "modulate:a", 0.0, 0.3)
	_tween.tween_callback(func() -> void: _panel.visible = false)

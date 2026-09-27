class_name HudExploracion
extends CanvasLayer
## HUD de exploración (placeholder): botón para abrir los recuerdos del Eco, también con la acción
## `abrir_recuerdos` (R). Solo en exploración con la party libre (integrar es solo fuera de combate).

signal recuerdos_pedidos

@export var estilo: EstiloHud
@export var party: ControlParty

var _boton: Button


func _ready() -> void:
	var raiz: Control = ConstruccionUi.raiz(self, estilo)
	_boton = ConstruccionUi.boton("Recuerdos (R)", func() -> void: recuerdos_pedidos.emit())
	_boton.anchor_left = 1.0
	_boton.anchor_right = 1.0
	_boton.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	var margen: int = (estilo if estilo != null else EstiloHud.por_defecto()).margen
	_boton.offset_left = -margen
	_boton.offset_right = -margen
	_boton.offset_top = margen
	raiz.add_child(_boton)


func _process(_delta: float) -> void:
	_boton.visible = party.modo() == ControlParty.Modo.EXPLORACION and not party.bloqueado


func _unhandled_input(event: InputEvent) -> void:
	if _boton.visible and event.is_action_pressed(&"abrir_recuerdos"):
		recuerdos_pedidos.emit()
		get_viewport().set_input_as_handled()


func boton_visible() -> bool:
	return _boton.visible

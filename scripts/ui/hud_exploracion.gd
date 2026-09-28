class_name HudExploracion
extends CanvasLayer
## HUD de exploración (placeholder): pantalla completa y el botón para abrir los recuerdos del Eco, también con la acción
## `abrir_recuerdos` (R). Solo en exploración con la party libre (integrar es solo fuera de combate).

signal recuerdos_pedidos

@export var estilo: EstiloHud
@export var party: ControlParty

var _boton: Button
var _fila: HBoxContainer


func _ready() -> void:
	var raiz: Control = ConstruccionUi.raiz(self, estilo)
	_boton = ConstruccionUi.boton("Recuerdos (R)", func() -> void: recuerdos_pedidos.emit())
	# Arriba a la derecha: pantalla completa y recuerdos.
	var fila: HBoxContainer = HBoxContainer.new()
	fila.anchor_left = 1.0
	fila.anchor_right = 1.0
	fila.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	var margen: int = (estilo if estilo != null else EstiloHud.por_defecto()).margen
	fila.offset_left = -margen
	fila.offset_right = -margen
	fila.offset_top = margen
	fila.add_child(BotonPantallaCompleta.new())
	fila.add_child(_boton)
	_fila = fila
	raiz.add_child(fila)


func _process(_delta: float) -> void:
	_fila.visible = party.modo() == ControlParty.Modo.EXPLORACION and not party.bloqueado


func _unhandled_input(event: InputEvent) -> void:
	if _fila.visible and event.is_action_pressed(&"abrir_recuerdos"):
		recuerdos_pedidos.emit()
		get_viewport().set_input_as_handled()


func boton_visible() -> bool:
	return _fila.visible

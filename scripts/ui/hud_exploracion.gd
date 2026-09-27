class_name HudExploracion
extends CanvasLayer
## HUD de exploración (placeholder): botón para abrir los recuerdos del Eco. Solo se ve en exploración con la
## party libre (integrar es solo fuera de combate). [propuesta] Un atajo de teclado cuando se sume al InputMap.

signal recuerdos_pedidos

@export var estilo: EstiloHud
@export var party: ControlParty

var _boton: Button


func _ready() -> void:
	var raiz: Control = ConstruccionUi.raiz(self, estilo)
	_boton = ConstruccionUi.boton("Recuerdos", func() -> void: recuerdos_pedidos.emit())
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


func boton_visible() -> bool:
	return _boton.visible

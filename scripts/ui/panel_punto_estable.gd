class_name PanelPuntoEstable
extends CanvasLayer
## Panel de un punto estable (M4c, funcional y placeholder): Descansar o Seguir; al descansar, el sueño (si
## hay). Solo presenta y avisa; el descanso lo aplica el Mundo. Aspecto del EstiloHud. Esc o click derecho (`cancelar_accion`) cierra.

signal descanso_pedido(punto: PuntoEstable)
signal cerrado
## "Hablar con…" un compañero vivo (id del miembro).
signal hablar_pedido(id_miembro: StringName)

## En el mundo los puntos estables se llaman Lumbres (docs/GLOSARIO.md); en código, PuntoEstable.
const TITULO: String = "Lumbre"
const EXPLICACION: String = "Descansar en la Lumbre recupera PG, espacios de conjuro y puntos de foco, y quita herido.\nAl morir, el Eco reaparece en la última Lumbre donde descansó."
const DESCANSADO: String = "La party descansó."

@export var estilo: EstiloHud

var _punto: PuntoEstable
var _texto: Label
var _descansar: Button
var _hablar: VBoxContainer


func _ready() -> void:
	layer = 6
	_construir()
	visible = false


func abierto() -> bool:
	return visible


## `companeros`: [{"id": StringName, "nombre": String}] de los compañeros vivos, para "Hablar con…".
func abrir(punto: PuntoEstable, companeros: Array[Dictionary] = []) -> void:
	_punto = punto
	_texto.text = EXPLICACION
	_descansar.visible = true
	ConstruccionUi.vaciar(_hablar)
	for companero: Dictionary in companeros:
		_hablar.add_child(ConstruccionUi.boton("Hablar con %s" % companero.nombre, hablar.bind(companero.id)))
	visible = true


func punto() -> PuntoEstable:
	return _punto


func hablar(id_miembro: StringName) -> void:
	hablar_pedido.emit(id_miembro)


func opciones() -> PackedStringArray:
	return ConstruccionUi.textos_de_botones(_hablar)


## Tras descansar: lo confirma (con el sueño, si hubo) y deja solo Seguir.
func mostrar_descansado(sueno: DefinicionSueno = null) -> void:
	_texto.text = DESCANSADO if sueno == null else "%s\n\n%s" % [DESCANSADO, sueno.texto]
	_descansar.visible = false


func descansar() -> void:
	descanso_pedido.emit(_punto)


func cerrar() -> void:
	if not visible:
		return
	visible = false
	_punto = null
	cerrado.emit()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed(&"cancelar_accion"):
		cerrar()
		get_viewport().set_input_as_handled()


func _construir() -> void:
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
	_texto = Label.new()
	_texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var botones: HBoxContainer = HBoxContainer.new()
	botones.alignment = BoxContainer.ALIGNMENT_CENTER
	_descansar = _boton("Descansar", descansar)
	botones.add_child(_descansar)
	botones.add_child(_boton("Seguir", cerrar))
	_hablar = VBoxContainer.new()
	for hijo: Control in [titulo, _texto, botones, _hablar]:
		columna.add_child(hijo)
	panel.add_child(columna)
	raiz.add_child(panel)


func _boton(texto: String, al_apretar: Callable) -> Button:
	var boton: Button = Button.new()
	boton.text = texto
	boton.focus_mode = Control.FOCUS_NONE
	boton.pressed.connect(al_apretar)
	return boton

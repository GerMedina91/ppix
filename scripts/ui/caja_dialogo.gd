class_name CajaDialogo
extends CanvasLayer
## Caja de diálogo propia (M5-prep b; funcional, placeholder) sobre Dialogue Manager: nombre de quien habla,
## texto, lugar para el retrato (96-128 px, vacío por ahora) y las respuestas. Las que no cumplen su
## condición se ven en gris, con el motivo como tooltip si la respuesta trae la etiqueta `[#motivo=...]`.
## Se avanza con click en la caja o con `ui_accept` (Enter). Aspecto del EstiloHud.

signal _avanzar
signal _respondida(siguiente: String)

const TAMANO_RETRATO: Vector2 = Vector2(96, 96)

@export var estilo: EstiloHud

var _panel: PanelContainer
var _retrato: Control
var _nombre: Label
var _texto: Label
var _respuestas: VBoxContainer
var _pista: Label
var _linea: DialogueLine


func _ready() -> void:
	layer = 7
	var raiz: Control = ConstruccionUi.raiz(self, estilo)
	var estilo_efectivo: EstiloHud = estilo if estilo != null else EstiloHud.por_defecto()
	_panel = PanelContainer.new()
	_panel.anchor_left = 0.5
	_panel.anchor_right = 0.5
	_panel.anchor_top = 1.0
	_panel.anchor_bottom = 1.0
	_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_panel.offset_bottom = -estilo_efectivo.margen
	_panel.custom_minimum_size = Vector2(620, 0)
	_panel.gui_input.connect(_al_click)
	var fila: HBoxContainer = HBoxContainer.new()
	_retrato = Control.new()
	_retrato.custom_minimum_size = TAMANO_RETRATO
	_retrato.visible = false  # sin retratos todavía
	fila.add_child(_retrato)
	var columna: VBoxContainer = VBoxContainer.new()
	columna.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_nombre = ConstruccionUi.etiqueta("", estilo_efectivo.color_activo)
	_texto = ConstruccionUi.etiqueta("")
	_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_respuestas = VBoxContainer.new()
	_pista = ConstruccionUi.etiqueta("(click o Enter para seguir)", estilo_efectivo.color_ayuda)
	for hijo: Control in [_nombre, _texto, _respuestas, _pista]:
		columna.add_child(hijo)
	fila.add_child(columna)
	_panel.add_child(fila)
	raiz.add_child(_panel)
	visible = false


func abierta() -> bool:
	return visible


## Muestra el diálogo desde `cue` hasta que termina (se puede esperar con await).
func mostrar(recurso: DialogueResource, cue: String, contexto: ContextoDialogo) -> void:
	var estados: Array = [{"estado": contexto}]
	visible = true
	_linea = await DialogueManager.get_next_dialogue_line(recurso, cue, estados)
	while _linea != null:
		_pintar(_linea)
		var siguiente: String = _linea.next_id
		if _linea.responses.is_empty():
			await _avanzar
		else:
			siguiente = await _respondida
		_linea = await DialogueManager.get_next_dialogue_line(recurso, siguiente, estados)
	visible = false


func avanzar() -> void:
	if visible and _linea != null and _linea.responses.is_empty():
		_avanzar.emit()


## Elige la respuesta `indice` (si está permitida).
func elegir(indice: int) -> void:
	if not visible or _linea == null or indice < 0 or indice >= _linea.responses.size():
		return
	var respuesta: DialogueResponse = _linea.responses[indice]
	if respuesta.is_allowed:
		_respondida.emit(respuesta.next_id)


func texto_actual() -> String:
	return "%s: %s" % [_nombre.text, _texto.text] if not _nombre.text.is_empty() else _texto.text


func opciones() -> PackedStringArray:
	return ConstruccionUi.textos_de_botones(_respuestas)


func _pintar(linea: DialogueLine) -> void:
	_nombre.text = linea.character
	_nombre.visible = not linea.character.is_empty()
	_texto.text = linea.text
	ConstruccionUi.vaciar(_respuestas)
	for i in linea.responses.size():
		var respuesta: DialogueResponse = linea.responses[i]
		var motivo: String = ""
		if not respuesta.is_allowed:
			motivo = respuesta.get_tag_value("motivo") if respuesta.has_tag("motivo") else "no disponible"
		_respuestas.add_child(ConstruccionUi.boton(respuesta.text, elegir.bind(i), motivo))
	_pista.visible = linea.responses.is_empty()


func _al_click(evento: InputEvent) -> void:
	if evento is InputEventMouseButton and (evento as InputEventMouseButton).pressed \
			and (evento as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		avanzar()


func _unhandled_input(evento: InputEvent) -> void:
	if visible and evento.is_action_pressed(&"ui_accept"):
		avanzar()
		get_viewport().set_input_as_handled()

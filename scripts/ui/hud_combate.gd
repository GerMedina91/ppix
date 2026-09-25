class_name HudCombate
extends CanvasLayer
## HUD mínimo del combate (fuente de Godot como placeholder): orden de iniciativa, actor activo
## (PG, acciones, condiciones), registro de tiradas con desglose y ayuda de controles.
## Solo muestra: escucha al ControladorCombate.

const TAMANO_FUENTE: int = 10
const LINEAS_REGISTRO: int = 6
const MARGEN: int = 6
const ANCHO_REGISTRO: int = 520
const COLOR_PARTY: Color = Color(0.75, 0.9, 1.0)
const COLOR_ENEMIGO: Color = Color(1.0, 0.7, 0.7)
const COLOR_ACTIVO: Color = Color(1.0, 0.85, 0.3)
const COLOR_MUERTO: Color = Color(0.45, 0.45, 0.45)
const COLOR_FONDO: Color = Color(0.0, 0.0, 0.0, 0.55)
const PIP_LLENO: String = "◆"
const PIP_VACIO: String = "◇"
## Ayuda de controles (placeholder), visible durante el turno de la party.
const AYUDA: String = "Click en el suelo: Zancada (1 acción) · Click en un enemigo: Golpe\nShift+click: Paso · Espacio: terminar turno"

@export var controlador: ControladorCombate

var _orden: HBoxContainer
var _activo: Label
var _registro: Label
var _ayuda: Label
var _lineas: PackedStringArray = PackedStringArray()
var _aviso: PanelContainer
var _texto_aviso: Label


func _ready() -> void:
	_construir()
	visible = false
	controlador.evento_mostrado.connect(_al_mostrar_evento)
	controlador.esperando_jugador.connect(_actualizar)
	controlador.combate_iniciado.connect(_al_iniciar)
	controlador.combate_terminado.connect(func(_victoria: bool) -> void: visible = false)
	controlador.pregunta_reaccion.connect(_mostrar_aviso)


func lineas_registro() -> PackedStringArray:
	return _lineas


func texto_activo() -> String:
	return _activo.text


func ayuda_visible() -> bool:
	return _ayuda.visible and visible


func texto_ayuda() -> String:
	return _ayuda.text


func aviso_visible() -> bool:
	return _aviso.visible


## Aviso de reacción: el combate queda en pausa hasta que el jugador responda.
func _mostrar_aviso(texto: String) -> void:
	_texto_aviso.text = texto
	_aviso.visible = true


func _responder(respuesta: ControladorCombate.Respuesta) -> void:
	controlador.responder_reaccion(respuesta)
	_actualizar()


func _al_iniciar() -> void:
	_lineas.clear()
	visible = true
	_actualizar()


func _al_mostrar_evento(evento: EventoCombate) -> void:
	var linea: String = FormatoRegistro.texto(evento, controlador.combate())
	if not linea.is_empty():
		_lineas.append(linea)
		while _lineas.size() > LINEAS_REGISTRO:
			_lineas.remove_at(0)
		_registro.text = "\n".join(_lineas)
	_actualizar()


func _actualizar() -> void:
	var combate: Combate = controlador.combate()
	if combate == null:
		return
	for hijo: Node in _orden.get_children():
		hijo.queue_free()
	var actual: Combatiente = combate.turno_actual()
	for c: Combatiente in combate.orden:
		var etiqueta: Label = _etiqueta(String(c.id))
		var color: Color = COLOR_PARTY if c.bando == Combatiente.Bando.PARTY else COLOR_ENEMIGO
		if c.condiciones.muerto:
			color = COLOR_MUERTO
		if c == actual:
			etiqueta.text = "[%s]" % etiqueta.text
			color = COLOR_ACTIVO
		etiqueta.add_theme_color_override("font_color", color)
		_orden.add_child(etiqueta)
	if actual != null:
		_activo.text = "%s   PG %d/%d   Acciones %s%s%s" % [
			actual.id, actual.pg, actual.pg_maximos(),
			PIP_LLENO.repeat(actual.acciones_restantes), PIP_VACIO.repeat(Combatiente.ACCIONES_POR_TURNO - actual.acciones_restantes),
			_condiciones(actual)]
	_ayuda.visible = controlador.esperando_decision()
	_aviso.visible = controlador.esperando_reaccion()


static func _condiciones(c: Combatiente) -> String:
	var partes: PackedStringArray = PackedStringArray()
	if c.condiciones.moribundo > 0:
		partes.append("moribundo %d" % c.condiciones.moribundo)
	if c.condiciones.herido > 0:
		partes.append("herido %d" % c.condiciones.herido)
	if c.condiciones.inconsciente:
		partes.append("inconsciente")
	return "" if partes.is_empty() else "   (%s)" % ", ".join(partes)


func _construir() -> void:
	var arriba: PanelContainer = _panel()
	arriba.position = Vector2(MARGEN, MARGEN)
	_orden = HBoxContainer.new()
	_orden.add_theme_constant_override("separation", 8)
	arriba.add_child(_orden)
	var abajo_izq: PanelContainer = _panel()
	_anclar_abajo(abajo_izq, 0.0)
	var columna: VBoxContainer = VBoxContainer.new()
	_activo = _etiqueta("")
	_ayuda = _etiqueta(AYUDA)
	_ayuda.add_theme_color_override("font_color", COLOR_MUERTO.lightened(0.4))
	columna.add_child(_activo)
	columna.add_child(_ayuda)
	abajo_izq.add_child(columna)
	var abajo_der: PanelContainer = _panel()
	_anclar_abajo(abajo_der, 1.0)
	_registro = _etiqueta("")
	_registro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_registro.custom_minimum_size = Vector2(ANCHO_REGISTRO, 0)
	abajo_der.add_child(_registro)
	for panel: Control in [arriba, abajo_izq, abajo_der]:
		add_child(panel)
	_construir_aviso()


func _construir_aviso() -> void:
	_aviso = _panel()
	_aviso.mouse_filter = Control.MOUSE_FILTER_STOP
	_aviso.anchor_left = 0.5
	_aviso.anchor_right = 0.5
	_aviso.anchor_top = 0.35
	_aviso.anchor_bottom = 0.35
	_aviso.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_aviso.grow_vertical = Control.GROW_DIRECTION_BOTH
	var columna: VBoxContainer = VBoxContainer.new()
	_texto_aviso = _etiqueta("")
	_texto_aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	columna.add_child(_texto_aviso)
	var botones: HBoxContainer = HBoxContainer.new()
	botones.alignment = BoxContainer.ALIGNMENT_CENTER
	for par: Array in [["Sí", ControladorCombate.Respuesta.SI], ["No", ControladorCombate.Respuesta.NO], ["Siempre", ControladorCombate.Respuesta.SIEMPRE]]:
		var boton: Button = Button.new()
		boton.text = par[0]
		boton.add_theme_font_size_override("font_size", TAMANO_FUENTE)
		boton.pressed.connect(_responder.bind(par[1]))
		botones.add_child(boton)
	columna.add_child(botones)
	_aviso.add_child(columna)
	_aviso.visible = false
	add_child(_aviso)


## Ancla el panel al borde inferior (a la izquierda con x = 0, a la derecha con x = 1): crece hacia arriba
## y hacia adentro, así el contenido nunca queda fuera de la pantalla.
func _anclar_abajo(panel: Control, x: float) -> void:
	panel.anchor_left = x
	panel.anchor_right = x
	panel.anchor_top = 1.0
	panel.anchor_bottom = 1.0
	panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN if x > 0.5 else Control.GROW_DIRECTION_END
	panel.offset_bottom = -MARGEN
	panel.offset_top = -MARGEN
	if x > 0.5:
		panel.offset_right = -MARGEN
		panel.offset_left = -MARGEN
	else:
		panel.offset_left = MARGEN
		panel.offset_right = MARGEN


func _panel() -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	var estilo: StyleBoxFlat = StyleBoxFlat.new()
	estilo.bg_color = COLOR_FONDO
	estilo.content_margin_left = 4
	estilo.content_margin_right = 4
	estilo.content_margin_top = 2
	estilo.content_margin_bottom = 2
	panel.add_theme_stylebox_override("panel", estilo)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return panel


func _etiqueta(texto: String) -> Label:
	var etiqueta: Label = Label.new()
	etiqueta.text = texto
	etiqueta.add_theme_font_size_override("font_size", TAMANO_FUENTE)
	etiqueta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return etiqueta

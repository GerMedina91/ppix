class_name HudCombate
extends CanvasLayer
## HUD del combate (funcional, placeholder): orden de iniciativa, actor activo (PG, acciones, condiciones),
## registro de tiradas con desglose, ayuda de controles, barra de acciones (BarraAcciones) y aviso de reacción.
## Todo el aspecto sale del EstiloHud de la config (Theme en un Control raíz). Solo muestra: escucha al
## ControladorCombate.

const LINEAS_REGISTRO: int = 6
const PIP_LLENO: String = "◆"
const PIP_VACIO: String = "◇"
## Ayuda de controles (placeholder), visible durante el turno de la party.
const AYUDA: String = "Click en el suelo: Zancada (1 acción) · Click en un enemigo: Golpe · Shift+click: Paso\n1-9 o botones: conjuros y acciones · Esc o click derecho: cancelar · Espacio: terminar turno"

@export var controlador: ControladorCombate

var _raiz: Control
var _orden: HBoxContainer
var _activo: Label
var _registro: Label
var _ayuda: Label
var _barra: BarraAcciones
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
	controlador.accion_elegida.connect(_actualizar)


func lineas_registro() -> PackedStringArray:
	return _lineas


func texto_activo() -> String:
	return _activo.text


func ayuda_visible() -> bool:
	return _ayuda.visible and visible


func texto_ayuda() -> String:
	return _ayuda.text


## Texto de las acciones (lista numerada o instrucción del conjuro elegido), si la barra está visible.
func texto_acciones() -> String:
	return controlador.texto_acciones() if _barra.visible else ""


func barra() -> BarraAcciones:
	return _barra


func aviso_visible() -> bool:
	return _aviso.visible


func _estilo() -> EstiloHud:
	return controlador.estilo()


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
	var estilo: EstiloHud = _estilo()
	for hijo: Node in _orden.get_children():
		hijo.queue_free()
	var actual: Combatiente = combate.turno_actual()
	for c: Combatiente in combate.orden:
		var etiqueta: Label = _etiqueta(String(c.id))
		var color: Color = estilo.color_party if c.bando == Combatiente.Bando.PARTY else estilo.color_enemigo
		if c.condiciones.muerto:
			color = estilo.color_muerto
		if c == actual:
			etiqueta.text = "[%s]" % etiqueta.text
			color = estilo.color_activo
		etiqueta.add_theme_color_override("font_color", color)
		_orden.add_child(etiqueta)
	if actual != null:
		var condiciones: String = FormatoRegistro.condiciones_de(actual)
		_activo.text = "%s   PG %d/%d   Acciones %s%s%s" % [
			actual.id, actual.pg, actual.pg_maximos(),
			PIP_LLENO.repeat(actual.acciones_restantes), PIP_VACIO.repeat(Combatiente.ACCIONES_POR_TURNO - actual.acciones_restantes),
			"" if condiciones.is_empty() else "   (%s)" % condiciones]
	_ayuda.visible = controlador.esperando_decision()
	_barra.actualizar()
	_aviso.visible = controlador.esperando_reaccion()


func _construir() -> void:
	var estilo: EstiloHud = _estilo()
	_raiz = Control.new()
	_raiz.name = "Raiz"
	_raiz.theme = estilo.tema()
	_raiz.set_anchors_preset(Control.PRESET_FULL_RECT)
	_raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_raiz)
	var arriba: PanelContainer = _panel()
	arriba.position = Vector2(estilo.margen, estilo.margen)
	_orden = HBoxContainer.new()
	_orden.add_theme_constant_override("separation", 8)
	arriba.add_child(_orden)
	var abajo_izq: PanelContainer = _panel()
	_anclar_abajo(abajo_izq, 0.0)
	var columna: VBoxContainer = VBoxContainer.new()
	_activo = _etiqueta("")
	_barra = BarraAcciones.new()
	_barra.controlador = controlador
	_ayuda = _etiqueta(AYUDA)
	_ayuda.add_theme_color_override("font_color", estilo.color_ayuda)
	columna.add_child(_activo)
	columna.add_child(_barra)
	columna.add_child(_ayuda)
	abajo_izq.add_child(columna)
	var abajo_der: PanelContainer = _panel()
	_anclar_abajo(abajo_der, 1.0)
	_registro = _etiqueta("")
	_registro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_registro.custom_minimum_size = Vector2(estilo.ancho_registro, 0)
	abajo_der.add_child(_registro)
	for panel: Control in [arriba, abajo_izq, abajo_der]:
		_raiz.add_child(panel)
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
		boton.focus_mode = Control.FOCUS_NONE
		boton.pressed.connect(_responder.bind(par[1]))
		botones.add_child(boton)
	columna.add_child(botones)
	_aviso.add_child(columna)
	_aviso.visible = false
	_raiz.add_child(_aviso)


## Ancla el panel al borde inferior (a la izquierda con x = 0, a la derecha con x = 1): crece hacia arriba
## y hacia adentro, así el contenido nunca queda fuera de la pantalla.
func _anclar_abajo(panel: Control, x: float) -> void:
	var margen: int = _estilo().margen
	panel.anchor_left = x
	panel.anchor_right = x
	panel.anchor_top = 1.0
	panel.anchor_bottom = 1.0
	panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN if x > 0.5 else Control.GROW_DIRECTION_END
	panel.offset_bottom = -margen
	panel.offset_top = -margen
	panel.offset_left = -margen if x > 0.5 else margen
	panel.offset_right = panel.offset_left


func _panel() -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return panel


func _etiqueta(texto: String) -> Label:
	var etiqueta: Label = Label.new()
	etiqueta.text = texto
	etiqueta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return etiqueta

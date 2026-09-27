class_name BarraAcciones
extends HBoxContainer
## Barra de acciones del HUD (funcional, placeholder): botones con las opciones del actor (conjuros,
## Sostener, Arcadas) y su atajo; con un conjuro elegido, su instrucción y, según el caso, el selector de
## costo (acciones de Curar) o el interruptor para incluirse en la emanación; siempre, Cancelar.
## Los botones no toman el foco (Espacio sigue terminando el turno) y frenan el click (no llega al mapa).
## Solo llama al controlador; el aspecto sale del Theme del HUD.

var controlador: ControladorCombate
var _instruccion: Label


func _ready() -> void:
	add_theme_constant_override("separation", 4)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## Rehace la barra con el estado actual (la llama el HUD cuando algo cambia).
func actualizar() -> void:
	for hijo: Node in get_children():
		remove_child(hijo)
		hijo.queue_free()
	visible = controlador.esperando_decision()
	if not visible:
		return
	var combate: Combate = controlador.combate()
	var actor: Combatiente = combate.turno_actual()
	var modo: ModoAccion = controlador.modo_accion()
	if modo.elegido == null:
		var opciones: Array[Dictionary] = ModoAccion.opciones(combate, actor)
		for i in opciones.size():
			_boton("%d %s" % [i + 1, opciones[i].texto], controlador.elegir_accion.bind(i))
		return
	_instruccion = Label.new()
	_instruccion.text = "%s:" % modo.elegido.nombre
	_instruccion.add_theme_color_override("font_color", controlador.estilo().color_conjuro)
	add_child(_instruccion)
	if modo.pide_acciones():
		for forma: Dictionary in modo.formas(actor):
			_boton(forma.texto, controlador.elegir_accion.bind(forma.acciones - 1))
	elif modo.es_area():
		var incluirse: CheckButton = CheckButton.new()
		incluirse.text = "Incluirme (E)"
		incluirse.button_pressed = not modo.excluirse
		incluirse.focus_mode = Control.FOCUS_NONE
		incluirse.toggled.connect(func(_activo: bool) -> void: controlador.alternar_incluirse())
		add_child(incluirse)
		_instruccion.text += " click en tu casilla para lanzarlo"
	else:
		_instruccion.text += " click en tu casilla o donde moverte (Shift: Paso)" \
			if modo.elegido.objetivo == DefinicionConjuro.Objetivo.UNO_MISMO else " click en el objetivo"
	_boton("Cancelar (Esc)", controlador.cancelar_accion)


func _boton(texto: String, al_pulsar: Callable) -> Button:
	var boton: Button = Button.new()
	boton.text = texto
	boton.focus_mode = Control.FOCUS_NONE
	boton.mouse_filter = Control.MOUSE_FILTER_STOP
	boton.pressed.connect(al_pulsar)
	add_child(boton)
	return boton


## Textos de la barra, en orden (para tests y el arnés de capturas).
func textos() -> PackedStringArray:
	var lista: PackedStringArray = PackedStringArray()
	for hijo: Node in get_children():
		if hijo is Button:
			lista.append((hijo as Button).text)
		elif hijo is Label:
			lista.append((hijo as Label).text)
	return lista

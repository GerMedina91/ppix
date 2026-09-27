class_name ConstruccionUi
extends RefCounted
## Piezas comunes de las pantallas de UI (placeholder): raíz con el Theme del EstiloHud, panel centrado,
## título, botones sin foco y filas de lista. Sin estado.


## Control raíz de pantalla completa con el tema, hijo de `capa`. No frena el mouse (los paneles sí).
static func raiz(capa: CanvasLayer, estilo: EstiloHud) -> Control:
	var control: Control = Control.new()
	control.theme = _estilo(estilo).tema()
	control.set_anchors_preset(Control.PRESET_FULL_RECT)
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa.add_child(control)
	return control


## Panel centrado (en `alto_relativo` de la pantalla) con una columna adentro; devuelve la columna.
static func panel_centrado(raiz_ui: Control, ancho_minimo: int = 0, alto_relativo: float = 0.4) -> VBoxContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = alto_relativo
	panel.anchor_bottom = alto_relativo
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	panel.custom_minimum_size = Vector2(ancho_minimo, 0)
	var columna: VBoxContainer = VBoxContainer.new()
	panel.add_child(columna)
	raiz_ui.add_child(panel)
	return columna


static func titulo(texto: String, estilo: EstiloHud) -> Label:
	var etiqueta: Label = Label.new()
	etiqueta.text = texto
	etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta.add_theme_color_override("font_color", _estilo(estilo).color_activo)
	return etiqueta


static func etiqueta(texto: String, color: Color = Color.WHITE) -> Label:
	var resultado: Label = Label.new()
	resultado.text = texto
	if color != Color.WHITE:
		resultado.add_theme_color_override("font_color", color)
	return resultado


## Botón sin foco. Con `motivo`, deshabilitado y con el motivo como tooltip.
static func boton(texto: String, al_apretar: Callable, motivo: String = "") -> Button:
	var resultado: Button = Button.new()
	resultado.text = texto
	resultado.focus_mode = Control.FOCUS_NONE
	resultado.pressed.connect(al_apretar)
	if motivo != "":
		resultado.disabled = true
		resultado.tooltip_text = motivo
	return resultado


## Fila de una lista: texto que se estira y los controles a la derecha.
static func fila(texto: String, controles: Array[Control]) -> HBoxContainer:
	var resultado: HBoxContainer = HBoxContainer.new()
	var descripcion: Label = etiqueta(texto)
	descripcion.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	resultado.add_child(descripcion)
	for control: Control in controles:
		resultado.add_child(control)
	return resultado


static func vaciar(contenedor: Node) -> void:
	for hijo: Node in contenedor.get_children():
		contenedor.remove_child(hijo)
		hijo.queue_free()


## Textos de los botones de `contenedor` (recursivo), para tests y capturas.
static func textos_de_botones(contenedor: Node) -> PackedStringArray:
	var textos: PackedStringArray = PackedStringArray()
	for hijo: Node in contenedor.get_children():
		if hijo is Button:
			textos.append((hijo as Button).text)
		textos.append_array(textos_de_botones(hijo))
	return textos


static func _estilo(estilo: EstiloHud) -> EstiloHud:
	return estilo if estilo != null else EstiloHud.por_defecto()

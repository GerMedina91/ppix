class_name PantallaCreditos
extends CanvasLayer
## Créditos (placeholder, desde la pantalla de inicio): aviso ORC, Godot con su licencia y sus componentes de
## terceros (los informa el propio motor) y Dialogue Manager (docs/creditos.md). Esc o "Volver" cierra.

signal cerrada

const AVISO_ORC: String = "res://data/creditos/orc_aviso.txt"
const LICENCIA_DIALOGUE_MANAGER: String = "res://data/creditos/dialogue_manager_licencia.txt"
const ALTO_TEXTO: int = 380

@export var estilo: EstiloHud

var _texto: Label


func _ready() -> void:
	layer = 8
	var raiz: Control = ConstruccionUi.raiz(self, estilo)
	var fondo: ColorRect = ColorRect.new()
	fondo.color = Color.BLACK
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	raiz.add_child(fondo)
	var columna: VBoxContainer = ConstruccionUi.panel_centrado(raiz, 700, 0.5)
	columna.add_child(ConstruccionUi.titulo("Créditos", estilo))
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, ALTO_TEXTO)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_texto = ConstruccionUi.etiqueta("")
	_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_texto.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_texto)
	columna.add_child(scroll)
	columna.add_child(ConstruccionUi.boton("Volver (Esc)", cerrar))
	_texto.text = texto()
	visible = false


func abrir() -> void:
	visible = true


func cerrar() -> void:
	if visible:
		visible = false
		cerrada.emit()


## Todo el texto de los créditos (también para tests).
static func texto() -> String:
	var partes: PackedStringArray = PackedStringArray()
	partes.append("TODO_LORE: créditos del juego.")
	partes.append("— Licencia ORC —\n" + _leer(AVISO_ORC))
	partes.append("— Motor: Godot Engine —\n" + Engine.get_license_text())
	partes.append("— Componentes de terceros de Godot —\n" + _componentes_de_godot())
	partes.append("— Dialogue Manager (Nathan Hoad) —\n" + _leer(LICENCIA_DIALOGUE_MANAGER))
	return "\n\n".join(partes)


## Cada componente con su copyright y licencia, y después el texto de cada licencia.
static func _componentes_de_godot() -> String:
	var lineas: PackedStringArray = PackedStringArray()
	for componente: Dictionary in Engine.get_copyright_info():
		for parte: Dictionary in componente.parts:
			lineas.append("%s: %s (%s)" % [componente.name, ", ".join(parte.copyright), parte.license])
	var licencias: Dictionary = Engine.get_license_info()
	for nombre: String in licencias:
		lineas.append("\n%s:\n%s" % [nombre, licencias[nombre]])
	return "\n".join(lineas)


static func _leer(ruta: String) -> String:
	return FileAccess.get_file_as_string(ruta).strip_edges() if FileAccess.file_exists(ruta) else "(falta %s)" % ruta


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed(&"cancelar_accion"):
		cerrar()
		get_viewport().set_input_as_handled()

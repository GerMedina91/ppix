class_name TextoFlotante
extends Node2D
## Texto que sube y se desvanece sobre un actor (daño, "falla", etc.). Fuente de Godot como placeholder.

const TAMANO_FUENTE: int = 12
const DESPLAZAMIENTO: Vector2 = Vector2(0, -24)
## Altura sobre los pies del actor donde aparece.
const ALTURA_INICIAL: float = 64.0


static func mostrar(padre: Node, posicion_global: Vector2, texto: String, color: Color, segundos: float) -> TextoFlotante:
	var flotante: TextoFlotante = TextoFlotante.new()
	var etiqueta: Label = Label.new()
	etiqueta.text = texto
	etiqueta.add_theme_font_size_override("font_size", TAMANO_FUENTE)
	etiqueta.add_theme_color_override("font_color", color)
	etiqueta.add_theme_color_override("font_outline_color", Color.BLACK)
	etiqueta.add_theme_constant_override("outline_size", 3)
	etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta.position = Vector2(-40, 0)
	etiqueta.size = Vector2(80, 16)
	flotante.add_child(etiqueta)
	flotante.z_as_relative = false
	flotante.z_index = RenderingServer.CANVAS_ITEM_Z_MAX - 1
	padre.add_child(flotante)
	flotante.global_position = posicion_global - Vector2(0, ALTURA_INICIAL)
	var tween: Tween = flotante.create_tween()
	tween.set_parallel(true)
	tween.tween_property(flotante, "position", flotante.position + DESPLAZAMIENTO, segundos)
	tween.tween_property(flotante, "modulate:a", 0.0, segundos)
	tween.chain().tween_callback(flotante.queue_free)
	return flotante

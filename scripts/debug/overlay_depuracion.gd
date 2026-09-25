class_name OverlayDepuracion
extends Node2D
## Overlay de depuración (F3, acción `alternar_depuracion`). Solo existe en builds de debug.
## Dibuja en coordenadas del mundo, por encima de todo, las capas registradas (CapaDepuracion).

const ACCION: StringName = &"alternar_depuracion"

var _capas: Array[CapaDepuracion] = []


func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()
		return
	z_as_relative = false
	z_index = RenderingServer.CANVAS_ITEM_Z_MAX
	visible = false
	set_process(false)
	registrar(CapaDepuracionOclusion.new())


func registrar(capa: CapaDepuracion) -> void:
	_capas.append(capa)


func capas() -> Array[CapaDepuracion]:
	return _capas


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(ACCION):
		visible = not visible
		set_process(visible)
		queue_redraw()
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	for capa: CapaDepuracion in _capas:
		if capa.activa:
			capa.dibujar(self)


# Ayudas de dibujo en coordenadas globales, para las capas.

func poligono_global(puntos: PackedVector2Array, borde: Color, relleno: Color = Color.TRANSPARENT) -> void:
	var local: PackedVector2Array = PackedVector2Array()
	for punto: Vector2 in puntos:
		local.append(to_local(punto))
	if relleno.a > 0.0:
		draw_colored_polygon(local, relleno)
	local.append(local[0])
	draw_polyline(local, borde, 1.0)


func rect_global(rect: Rect2, borde: Color) -> void:
	draw_rect(Rect2(to_local(rect.position), rect.size), borde, false, 1.0)


func cruz_global(centro: Vector2, tamano: float, color: Color) -> void:
	var c: Vector2 = to_local(centro)
	draw_line(c - Vector2(tamano, 0), c + Vector2(tamano, 0), color, 1.0)
	draw_line(c - Vector2(0, tamano), c + Vector2(0, tamano), color, 1.0)

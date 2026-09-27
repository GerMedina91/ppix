class_name MarcaResiduo
extends Node2D
## Marca del residuo del Eco en el suelo (placeholder: rombo de contorno). No ocupa la casilla: se recupera
## pisándola con el Eco (GestorMuerte).

const COLOR: Color = Color(0.85, 0.75, 1.0, 0.9)
const MEDIO: Vector2 = Vector2(20, 10)

var celda: Vector2i = Vector2i.ZERO


func colocar(celda_nueva: Vector2i, posicion_global: Vector2) -> void:
	celda = celda_nueva
	global_position = posicion_global
	z_index = -1  # sobre el suelo, debajo de los actores


func _draw() -> void:
	var puntos: PackedVector2Array = PackedVector2Array([Vector2(0, -MEDIO.y), Vector2(MEDIO.x, 0), Vector2(0, MEDIO.y),
		Vector2(-MEDIO.x, 0), Vector2(0, -MEDIO.y)])
	draw_polyline(puntos, COLOR, 2.0)

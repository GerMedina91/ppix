class_name Mapa
extends Node2D
## Mapa de exploración (y, más adelante, de combate).
## Traduce entre celdas de la grilla y posiciones globales, y ubica entradas y salidas.

@onready var _suelo: TileMapLayer = $Suelo
@onready var _entradas: Node = $Entradas
@onready var _salidas: Node = $Salidas


func celda_a_posicion(celda: Vector2i) -> Vector2:
	return _suelo.to_global(_suelo.map_to_local(celda))


func posicion_a_celda(posicion_global: Vector2) -> Vector2i:
	return _suelo.local_to_map(_suelo.to_local(posicion_global))


## Rectángulo del mapa en píxeles globales (para los límites de la cámara).
func rect_global() -> Rect2:
	var celdas: Rect2i = _suelo.get_used_rect()
	var tamano_tile: Vector2 = Vector2(_suelo.tile_set.tile_size)
	var origen: Vector2 = _suelo.to_global(Vector2(celdas.position) * tamano_tile)
	return Rect2(origen, Vector2(celdas.size) * tamano_tile)


func celda_de_entrada(id_entrada: StringName) -> Vector2i:
	for entrada: EntradaMapa in _entradas.get_children():
		if entrada.id == id_entrada:
			return posicion_a_celda(entrada.global_position)
	push_error("Mapa %s: no existe la entrada '%s'" % [name, id_entrada])
	return Vector2i.ZERO


## Devuelve la salida ubicada en `celda`, o null si no hay ninguna.
func salida_en(celda: Vector2i) -> SalidaMapa:
	for salida: SalidaMapa in _salidas.get_children():
		if posicion_a_celda(salida.global_position) == celda:
			return salida
	return null

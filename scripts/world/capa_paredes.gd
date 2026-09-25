class_name CapaParedes
extends TileMapLayer
## Capa de paredes del mapa. Las paredes con el dato `se_transparenta` se vuelven semitransparentes
## mientras tapan a algún actor del grupo OclusionParedes.GRUPO_VISIBLES. Cambio instantáneo.

const DATO_SE_TRANSPARENTA: String = "se_transparenta"

## Opacidad de una pared mientras tapa a un actor (1.0 = sin transparencia). La fija el Mundo desde la config.
var alfa_transparente: float = 1.0

## Paredes que se pueden transparentar: celda -> rect dibujado (global).
var _candidatas: Dictionary[Vector2i, Rect2] = {}
var _tapando: Dictionary[Vector2i, bool] = {}


func _ready() -> void:
	for celda: Vector2i in get_used_cells():
		var datos: TileData = get_cell_tile_data(celda)
		if datos.get_custom_data(DATO_SE_TRANSPARENTA):
			_candidatas[celda] = _rect_dibujado(celda, datos)


func _process(_delta: float) -> void:
	var nuevas: Dictionary[Vector2i, bool] = _calcular_tapando()
	if nuevas != _tapando:
		_tapando = nuevas
		notify_runtime_tile_data_update()


## Celdas de pared que hoy están semitransparentes.
func celdas_transparentes() -> Array[Vector2i]:
	return _tapando.keys()


func _calcular_tapando() -> Dictionary[Vector2i, bool]:
	var resultado: Dictionary[Vector2i, bool] = {}
	for actor: Node in get_tree().get_nodes_in_group(OclusionParedes.GRUPO_VISIBLES):
		if not actor.has_method(OclusionParedes.METODO_RECT):
			continue
		var rect_actor: Rect2 = actor.call(OclusionParedes.METODO_RECT)
		var base_actor: float = (actor as Node2D).global_position.y
		for celda: Vector2i in _candidatas:
			var base_pared: float = to_global(map_to_local(celda)).y
			if OclusionParedes.tapa(_candidatas[celda], base_pared, rect_actor, base_actor):
				resultado[celda] = true
	return resultado


## Rect global de lo que dibuja el tile (textura completa, con su texture_origin).
func _rect_dibujado(celda: Vector2i, datos: TileData) -> Rect2:
	var fuente: TileSetAtlasSource = tile_set.get_source(get_cell_source_id(celda)) as TileSetAtlasSource
	var tamano: Vector2 = Vector2(fuente.get_tile_texture_region(get_cell_atlas_coords(celda)).size)
	var esquina_local: Vector2 = map_to_local(celda) - tamano / 2.0 - Vector2(datos.texture_origin)
	return Rect2(to_global(esquina_local), tamano)


func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	return _tapando.has(coords)


func _tile_data_runtime_update(_coords: Vector2i, tile_data: TileData) -> void:
	tile_data.modulate.a = alfa_transparente

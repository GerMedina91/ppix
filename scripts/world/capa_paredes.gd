class_name CapaParedes
extends TileMapLayer
## Capa de paredes del mapa. Las paredes con el dato `se_transparenta` se vuelven semitransparentes
## mientras tapan a algún actor del grupo OclusionParedes.GRUPO_VISIBLES. Cambio instantáneo.

## Grupo para que herramientas (p. ej. el overlay de depuración) encuentren las capas de paredes.
const GRUPO: StringName = &"capas_paredes"
const DATO_SE_TRANSPARENTA: String = "se_transparenta"

## Opacidad de una pared mientras tapa a un actor (1.0 = sin transparencia). La fija el Mundo desde la config.
var alfa_transparente: float = 1.0

## Paredes que se pueden transparentar: celda -> silueta global.
var _candidatas: Dictionary[Vector2i, PackedVector2Array] = {}
var _tapando: Dictionary[Vector2i, bool] = {}


func _ready() -> void:
	add_to_group(GRUPO)
	for celda: Vector2i in get_used_cells():
		var datos: TileData = get_cell_tile_data(celda)
		if datos.get_custom_data(DATO_SE_TRANSPARENTA):
			_candidatas[celda] = _silueta(celda)


func _process(_delta: float) -> void:
	var nuevas: Dictionary[Vector2i, bool] = _calcular_tapando()
	if nuevas != _tapando:
		_aplicar(nuevas)


## Celdas de pared que hoy están semitransparentes.
func celdas_transparentes() -> Array[Vector2i]:
	return _tapando.keys()


## Siluetas globales de las paredes que se pueden transparentar (para depuración).
func siluetas_candidatas() -> Dictionary[Vector2i, PackedVector2Array]:
	return _candidatas


func _calcular_tapando() -> Dictionary[Vector2i, bool]:
	var resultado: Dictionary[Vector2i, bool] = {}
	for actor: Node in get_tree().get_nodes_in_group(OclusionParedes.GRUPO_VISIBLES):
		if not actor.has_method(OclusionParedes.METODO_RECT):
			continue
		var rect_actor: Rect2 = actor.call(OclusionParedes.METODO_RECT)
		var base_actor: float = (actor as Node2D).global_position.y
		for celda: Vector2i in _candidatas:
			if OclusionParedes.tapa(_candidatas[celda], to_global(map_to_local(celda)).y, rect_actor, base_actor):
				resultado[celda] = true
	return resultado


func _aplicar(nuevas: Dictionary[Vector2i, bool]) -> void:
	var salientes: Array[Vector2i] = []
	for celda: Vector2i in _tapando:
		if not nuevas.has(celda):
			salientes.append(celda)
	_tapando = nuevas
	notify_runtime_tile_data_update()
	# En Godot 4.7.2, una celda que deja de tener runtime update no se redibuja y queda con el alfa
	# anterior. Borrarla y volver a ponerla fuerza el redibujado.
	for celda: Vector2i in salientes:
		var fuente: int = get_cell_source_id(celda)
		var atlas: Vector2i = get_cell_atlas_coords(celda)
		var alternativa: int = get_cell_alternative_tile(celda)
		erase_cell(celda)
		set_cell(celda, fuente, atlas, alternativa)


## Silueta global del bloque de la celda: la altura sale de cuánto sobresale la textura sobre el rombo.
func _silueta(celda: Vector2i) -> PackedVector2Array:
	var fuente: TileSetAtlasSource = tile_set.get_source(get_cell_source_id(celda)) as TileSetAtlasSource
	var alto_textura: int = fuente.get_tile_texture_region(get_cell_atlas_coords(celda)).size.y
	var alto: float = alto_textura - tile_set.tile_size.y
	var local: PackedVector2Array = OclusionParedes.silueta_bloque(map_to_local(celda), Vector2(tile_set.tile_size), alto)
	var global: PackedVector2Array = PackedVector2Array()
	for punto: Vector2 in local:
		global.append(to_global(punto))
	return global


func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	return _tapando.has(coords)


func _tile_data_runtime_update(_coords: Vector2i, tile_data: TileData) -> void:
	tile_data.modulate.a = alfa_transparente

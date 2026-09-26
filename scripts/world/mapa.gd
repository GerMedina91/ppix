class_name Mapa
extends Node2D
## Mapa de exploración (y, más adelante, de combate), en proyección isométrica.
## La lógica es una grilla cuadrada: este nodo traduce entre celdas y posiciones de pantalla,
## ubica entradas y salidas, y arma la GrillaMapa a partir de las capas de tiles.
##
## Capas: `Suelo` (debajo de todo, sin y-sort) y `Paredes` (con y-sort, junto con la party).
## Las paredes van en capa propia para poder hacerlas transparentes cuando la party
## pasa detrás (previsto, no implementado).

## Nombre de la capa de datos del TileSet que indica si un tile de suelo se puede pisar.
const DATO_TRANSITABLE: String = "transitable"

const VECINAS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1), Vector2i(-1, 1),
	Vector2i(-1, 0), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
]

@onready var _suelo: TileMapLayer = $Suelo
@onready var _paredes: CapaParedes = $Paredes
@onready var _entradas: Node = $Entradas
@onready var _salidas: Node = $Salidas
## Opcional: nodo con los Encuentros del mapa.
@onready var _encuentros: Node = get_node_or_null("Encuentros")


func _ready() -> void:
	# Los enemigos de los encuentros se ubican en la casilla de su posición.
	for encuentro: Encuentro in encuentros():
		for enemigo: EnemigoEnMapa in encuentro.enemigos():
			var casilla: Vector2i = posicion_a_celda(enemigo.global_position)
			enemigo.colocar(casilla, celda_a_posicion(casilla))


func encuentros() -> Array[Encuentro]:
	var lista: Array[Encuentro] = []
	if _encuentros != null:
		for hijo: Node in _encuentros.get_children():
			if hijo is Encuentro:
				lista.append(hijo)
	return lista


## Construye la grilla lógica: una celda es transitable si su suelo tiene `transitable = true`
## y no hay pared encima.
func construir_grilla() -> GrillaMapa:
	var grilla: GrillaMapa = GrillaMapa.new(_region())
	for celda: Vector2i in _suelo.get_used_cells():
		var datos: TileData = _suelo.get_cell_tile_data(celda)
		var hay_pared: bool = _paredes.get_cell_source_id(celda) != -1
		grilla.set_transitable(celda, datos.get_custom_data(DATO_TRANSITABLE) and not hay_pared)
	return grilla


## Centro del rombo de la celda, en coordenadas globales.
func celda_a_posicion(celda: Vector2i) -> Vector2:
	return _suelo.to_global(_suelo.map_to_local(celda))


## Rombo de la celda (sus 4 vértices), en coordenadas globales.
func rombo_global(celda: Vector2i) -> PackedVector2Array:
	var centro: Vector2 = celda_a_posicion(celda)
	var medio: Vector2 = Vector2(_suelo.tile_set.tile_size) / 2.0
	return PackedVector2Array([
		centro + Vector2(0, -medio.y), centro + Vector2(medio.x, 0),
		centro + Vector2(0, medio.y), centro + Vector2(-medio.x, 0)])


func posicion_a_celda(posicion_global: Vector2) -> Vector2i:
	return _suelo.local_to_map(_suelo.to_local(posicion_global))


## Traduce una dirección de pantalla (p. ej. (1, -1) = arriba a la derecha) al paso de grilla
## cuya proyección apunta más cerca. Devuelve ZERO si la dirección es nula.
func direccion_de_pantalla(pantalla: Vector2) -> Vector2i:
	if pantalla.is_zero_approx():
		return Vector2i.ZERO
	var objetivo: Vector2 = pantalla.normalized()
	var origen: Vector2 = _suelo.map_to_local(Vector2i.ZERO)
	var mejor: Vector2i = Vector2i.ZERO
	var mejor_parecido: float = -INF
	for vecina: Vector2i in VECINAS:
		var parecido: float = (_suelo.map_to_local(vecina) - origen).normalized().dot(objetivo)
		if parecido > mejor_parecido:
			mejor_parecido = parecido
			mejor = vecina
	return mejor


## Rectángulo de pantalla que envuelve el mapa proyectado, incluida la altura de las paredes
## (para los límites de la cámara).
func rect_global() -> Rect2:
	var region: Rect2i = _region()
	var medio_tile: Vector2 = Vector2(_suelo.tile_set.tile_size) / 2.0
	var esquinas: Array[Vector2i] = [
		region.position, Vector2i(region.end.x - 1, region.position.y),
		Vector2i(region.position.x, region.end.y - 1), region.end - Vector2i.ONE,
	]
	var rect: Rect2 = Rect2(celda_a_posicion(esquinas[0]), Vector2.ZERO)
	for esquina: Vector2i in esquinas:
		var centro: Vector2 = celda_a_posicion(esquina)
		rect = rect.expand(centro - medio_tile).expand(centro + medio_tile)
	rect.position.y -= _alto_maximo_sobre_el_suelo()
	rect.size.y += _alto_maximo_sobre_el_suelo()
	return rect


## Opacidad que usan las paredes mientras tapan a un actor visible.
func configurar_transparencia(alfa: float) -> void:
	_paredes.alfa_transparente = alfa


func celda_de_entrada(id_entrada: StringName) -> Vector2i:
	var entrada: EntradaMapa = _entrada(id_entrada)
	if entrada == null:
		push_error("Mapa %s: no existe la entrada '%s'" % [name, id_entrada])
		return Vector2i.ZERO
	return posicion_a_celda(entrada.global_position)


func _entrada(id_entrada: StringName) -> EntradaMapa:
	for entrada: EntradaMapa in _entradas.get_children():
		if entrada.id == id_entrada:
			return entrada
	return null


## Casillas de formación para `cantidad` miembros al entrar por `id_entrada` (líder primero).
## Usa la formación de la entrada si la tiene; si no, la calcula. Si faltan casillas, repite la última.
func celdas_de_formacion(id_entrada: StringName, cantidad: int, grilla: GrillaMapa) -> Array[Vector2i]:
	var celdas: Array[Vector2i] = []
	var entrada: EntradaMapa = _entrada(id_entrada)
	if entrada != null and not entrada.formacion.is_empty():
		celdas.assign(entrada.formacion)
	else:
		var salidas: Array[Vector2i] = []
		for salida: SalidaMapa in _salidas.get_children():
			salidas.append(posicion_a_celda(salida.global_position))
		celdas = Formacion.cadena(grilla, celda_de_entrada(id_entrada), cantidad, salidas)
	while celdas.size() < cantidad:
		celdas.append(celdas.back())
	return celdas.slice(0, cantidad)


## Devuelve la salida ubicada en `celda`, o null si no hay ninguna.
func salida_en(celda: Vector2i) -> SalidaMapa:
	for salida: SalidaMapa in _salidas.get_children():
		if posicion_a_celda(salida.global_position) == celda:
			return salida
	return null


func _region() -> Rect2i:
	return _suelo.get_used_rect().merge(_paredes.get_used_rect())


## Cuánto sobresale hacia arriba el tile más alto del TileSet (p. ej. la cara de una pared).
func _alto_maximo_sobre_el_suelo() -> float:
	var tile_set: TileSet = _paredes.tile_set
	var alto: int = 0
	for i in tile_set.get_source_count():
		var fuente: TileSetAtlasSource = tile_set.get_source(tile_set.get_source_id(i)) as TileSetAtlasSource
		if fuente != null:
			alto = maxi(alto, fuente.texture_region_size.y - tile_set.tile_size.y)
	return alto

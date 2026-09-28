class_name ValidacionMapa
extends RefCounted
## Comprobaciones de un mapa armado en el editor (M5-prep a). Las usan los avisos de configuración de cada
## nodo (triángulo amarillo en el árbol de escena) y el test de los mapas del catálogo, así las reglas están
## en un solo lugar. Trabaja con los nodos tal cual (en el editor solo corren los scripts @tool): busca la
## capa `Suelo` subiendo por los padres, y de los Resources lee propiedades (sin @tool son placeholders en el
## editor). Sin estado.

const CATALOGO_MAPAS: String = "res://data/mapas/catalogo_mapas.tres"
const CATALOGO_RECUERDOS: String = "res://data/recuerdos/catalogo_recuerdos.tres"
const DATO_TRANSITABLE: String = "transitable"
## Nombres que puede usar la condición de un disparador de diálogo (ver DisparadorDialogo).
const NOMBRES_CONDICION: PackedStringArray = ["estado"]


## Capa de suelo del mapa que contiene a `nodo` (null si no está dentro de un mapa).
static func suelo_de(nodo: Node) -> TileMapLayer:
	var actual: Node = nodo.get_parent()
	while actual != null:
		var suelo: Node = actual.get_node_or_null("Suelo")
		if suelo is TileMapLayer:
			return suelo
		actual = actual.get_parent()
	return null


## Raíz del mapa (el padre de `Suelo`) o null.
static func mapa_de(nodo: Node) -> Node:
	var suelo: TileMapLayer = suelo_de(nodo)
	return suelo.get_parent() if suelo != null else null


static func celda_de(nodo: Node2D) -> Vector2i:
	var suelo: TileMapLayer = suelo_de(nodo)
	return suelo.local_to_map(suelo.to_local(nodo.global_position)) if suelo != null else Vector2i.ZERO


## Lleva el nodo al centro del rombo de su casilla (en el editor, al soltarlo).
static func centrar(nodo: Node2D) -> void:
	var suelo: TileMapLayer = suelo_de(nodo)
	if suelo == null:
		return
	var centro: Vector2 = suelo.to_global(suelo.map_to_local(celda_de(nodo)))
	if not nodo.global_position.is_equal_approx(centro):
		nodo.global_position = centro


## true si la casilla tiene suelo pisable y ninguna pared encima.
static func es_pisable(nodo: Node, celda: Vector2i) -> bool:
	var suelo: TileMapLayer = suelo_de(nodo)
	if suelo == null:
		return false
	var datos: TileData = suelo.get_cell_tile_data(celda)
	if datos == null or not datos.get_custom_data(DATO_TRANSITABLE):
		return false
	var paredes: TileMapLayer = suelo.get_parent().get_node_or_null("Paredes") as TileMapLayer
	return paredes == null or paredes.get_cell_source_id(celda) == -1


## Avisos comunes de algo que ocupa una casilla: estar dentro de un mapa y sobre una casilla pisable.
static func avisos_de_casilla(nodo: Node2D) -> PackedStringArray:
	var avisos: PackedStringArray = PackedStringArray()
	if suelo_de(nodo) == null:
		avisos.append("Tiene que estar dentro de un mapa (con una capa Suelo).")
	elif not es_pisable(nodo, celda_de(nodo)):
		avisos.append("Está en la casilla %s, que no se puede pisar (sin suelo o con pared)." % celda_de(nodo))
	return avisos


## Aviso si `id` está vacío o lo usa otro nodo del mismo script en el mapa.
static func avisos_de_id(nodo: Node, id: StringName, que: String) -> PackedStringArray:
	if id == &"":
		return PackedStringArray(["Falta el id del %s." % que])
	var mapa: Node = mapa_de(nodo)
	if mapa == null:
		return PackedStringArray()
	for otro: Node in mapa.find_children("*", "", true, false):
		if otro != nodo and otro.get_script() == nodo.get_script() and otro.get("id") == id:
			return PackedStringArray(["El id '%s' está repetido en este mapa." % id])
	return PackedStringArray()


static func mapa_existe(id_mapa: StringName) -> bool:
	return _ruta_de_mapa(id_mapa) != ""


## Ids de las entradas del mapa `id_mapa` (vacío si no existe).
static func entradas_de(id_mapa: StringName) -> PackedStringArray:
	var ids: PackedStringArray = PackedStringArray()
	var ruta: String = _ruta_de_mapa(id_mapa)
	if ruta == "" or not ResourceLoader.exists(ruta):
		return ids
	var estado: SceneState = (load(ruta) as PackedScene).get_state()
	for i in estado.get_node_count():
		if String(estado.get_node_path(i, true)).get_file() == "Entradas":
			for j in estado.get_node_property_count(i):
				if estado.get_node_property_name(i, j) == &"id":
					ids.append(String(estado.get_node_property_value(i, j)))
	return ids


static func recuerdo_catalogado(recuerdo: DefinicionRecuerdo) -> bool:
	if not ResourceLoader.exists(CATALOGO_RECUERDOS):
		return false
	for otro: Resource in load(CATALOGO_RECUERDOS).get("recuerdos"):
		if otro.get("id") == recuerdo.get("id"):
			return true
	return false


## "" si la condición es una expresión válida (o está vacía); si no, el error.
static func error_de_condicion(condicion: String) -> String:
	if condicion.strip_edges().is_empty():
		return ""
	var expresion: Expression = Expression.new()
	if expresion.parse(condicion, NOMBRES_CONDICION) != OK:
		return expresion.get_error_text()
	return ""


## Todos los avisos de los nodos de un mapa ya instanciado (para el test del catálogo): "Nodo: aviso".
static func avisos_del_mapa(mapa: Node) -> PackedStringArray:
	var avisos: PackedStringArray = PackedStringArray()
	for nodo: Node in mapa.find_children("*", "", true, false):
		if nodo.has_method(&"_get_configuration_warnings"):
			for aviso: String in nodo.call(&"_get_configuration_warnings"):
				avisos.append("%s: %s" % [mapa.get_path_to(nodo), aviso])
	return avisos


## Escena del mapa `id_mapa` según el catálogo ("" si no está). Lee las propiedades en vez de llamar métodos:
## en el editor los Resources sin @tool son placeholders.
static func _ruta_de_mapa(id_mapa: StringName) -> String:
	if not ResourceLoader.exists(CATALOGO_MAPAS):
		return ""
	for definicion: Resource in load(CATALOGO_MAPAS).get("mapas"):
		if definicion.get("id") == id_mapa:
			return definicion.get("ruta_escena")
	return ""

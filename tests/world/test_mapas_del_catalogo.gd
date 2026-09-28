extends GdUnitTestSuite
## Los mapas del catálogo están bien armados (M5-prep a): los mismos avisos que muestra el editor
## (ValidacionMapa) tienen que estar vacíos. Y un mapa roto a propósito da cada aviso.

const CATALOGO: String = "res://data/mapas/catalogo_mapas.tres"
const PLANTILLA: String = "res://scenes/world/mapas/plantilla_mapa.tscn"
const OBJETOS: String = "res://scenes/world/objetos/%s.tscn"


func test_los_mapas_del_catalogo_no_tienen_avisos() -> void:
	var catalogo: CatalogoMapas = load(CATALOGO)
	var ids: Dictionary = {}
	for definicion: DefinicionMapa in catalogo.mapas:
		assert_bool(ids.has(definicion.id)).override_failure_message("id de mapa repetido: %s" % definicion.id).is_false()
		ids[definicion.id] = true
		assert_bool(ResourceLoader.exists(definicion.ruta_escena)).override_failure_message(definicion.ruta_escena).is_true()
		var mapa: Node = auto_free((load(definicion.ruta_escena) as PackedScene).instantiate())
		add_child(mapa)
		assert_array(Array(ValidacionMapa.avisos_del_mapa(mapa))).override_failure_message(
			"%s: %s" % [definicion.id, "\n".join(ValidacionMapa.avisos_del_mapa(mapa))]).is_empty()
		remove_child(mapa)


func _objeto(nombre: String, celda: Vector2i, suelo: TileMapLayer, padre: Node) -> Node2D:
	var nodo: Node2D = (load(OBJETOS % nombre) as PackedScene).instantiate()
	padre.add_child(nodo)
	nodo.global_position = suelo.to_global(suelo.map_to_local(celda))
	return nodo


func test_un_mapa_roto_da_cada_aviso() -> void:
	var mapa: Node2D = auto_free((load(PLANTILLA) as PackedScene).instantiate())
	add_child(mapa)
	var suelo: TileMapLayer = mapa.get_node("Suelo")
	for x in 6:
		for y in 4:
			suelo.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
	(mapa.get_node("Paredes") as TileMapLayer).set_cell(Vector2i(4, 1), 1, Vector2i(0, 0))
	var interactuables: Node = mapa.get_node("Interactuables")
	var punto_a: PuntoEstable = _objeto("punto_estable", Vector2i(1, 1), suelo, interactuables)
	punto_a.id = &"repetido"
	var punto_b: PuntoEstable = _objeto("punto_estable", Vector2i(2, 1), suelo, interactuables)
	punto_b.id = &"repetido"
	_objeto("objeto_recuerdo", Vector2i(4, 1), suelo, interactuables)  # sobre la pared y sin recuerdo
	var dialogo: DisparadorDialogo = _objeto("disparador_dialogo", Vector2i(1, 2), suelo, interactuables)
	dialogo.dialogo = "res://dialogue/no_existe.dialogue"
	dialogo.condicion = "estado.algo(("
	var bien: DisparadorDialogo = _objeto("disparador_dialogo", Vector2i(2, 2), suelo, interactuables)
	bien.dialogo = "res://tests/utiles/prueba.dialogue"
	bien.condicion = "estado.companero_vivo(\"Miembro2\") and not estado.vio_sueno(\"sueno_placeholder_1\")"
	var salida: SalidaMapa = _objeto("salida", Vector2i(0, 3), suelo, mapa.get_node("Salidas"))
	salida.id_mapa_destino = &"mapa_prueba_a"
	salida.id_entrada_destino = &"no_existe"
	_objeto("encuentro", Vector2i(0, 0), suelo, mapa.get_node("Encuentros"))
	var avisos: String = "\n".join(ValidacionMapa.avisos_del_mapa(mapa))
	for esperado: String in ["El id 'repetido' está repetido", "que no se puede pisar", "Falta el recuerdo",
			"No existe el archivo de diálogo", "La condición no es una expresión válida", "no tiene la entrada 'no_existe'",
			"No tiene enemigos"]:
		assert_str(avisos).override_failure_message("falta el aviso '%s' en:\n%s" % [esperado, avisos]).contains(esperado)
	assert_array(Array(bien._get_configuration_warnings())).is_empty()  # el bien configurado no avisa nada
	remove_child(mapa)

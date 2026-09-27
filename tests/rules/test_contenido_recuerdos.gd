extends GdUnitTestSuite
## Contenido placeholder de recuerdos (M4e): datos válidos, ids únicos y todo lo que se usa está en el catálogo
## (lo necesita el guardado para resolver ids).

const CATALOGO: String = "res://data/recuerdos/catalogo_recuerdos.tres"


func _catalogo() -> CatalogoRecuerdos:
	return load(CATALOGO)


func test_los_recuerdos_son_validos_y_con_ids_unicos() -> void:
	var ids: Dictionary = {}
	for r: DefinicionRecuerdo in _catalogo().recuerdos:
		assert_array(Array(r.errores_de_datos())).override_failure_message(String(r.id)).is_empty()
		assert_bool(ids.has(r.id)).override_failure_message("id repetido %s" % r.id).is_false()
		ids[r.id] = true


func test_el_stock_del_tasador_y_los_enemigos_usan_recuerdos_del_catalogo() -> void:
	var catalogo: CatalogoRecuerdos = _catalogo()
	var config: ConfigRecuerdos = load("res://data/config/config_recuerdos.tres")
	for r: DefinicionRecuerdo in config.stock_inicial_tasador:
		assert_object(catalogo.buscar(r.id)).is_not_null()
	for ruta: String in ["enemigo_prueba_cuerpo_a_cuerpo", "enemigo_prueba_distancia"]:
		var criatura: DefinicionCriatura = load("res://data/criaturas/%s.tres" % ruta)
		assert_object(catalogo.buscar(criatura.recuerdo.id)).is_not_null()


func test_valores_segun_el_gdd() -> void:
	for r: DefinicionRecuerdo in _catalogo().recuerdos:
		match r.tipo:
			DefinicionRecuerdo.Tipo.DESTREZA:
				assert_int(r.valor).is_between(20, 40)
			DefinicionRecuerdo.Tipo.VIVENCIA:
				assert_int(r.valor).is_equal(10)
			DefinicionRecuerdo.Tipo.DOLIENTE:
				assert_int(r.valor).is_equal(50)

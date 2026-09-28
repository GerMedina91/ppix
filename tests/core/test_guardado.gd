extends GdUnitTestSuite
## Guardado a disco (M4g): ida y vuelta del estado completo (incluido el RNG), escritura atómica y versión.

const CATALOGO: String = "res://data/recuerdos/catalogo_recuerdos.tres"


func before_test() -> void:
	GameState.nueva_partida()
	SaveSystem.borrar()


func after_test() -> void:
	SaveSystem.borrar()
	GameState.nueva_partida()


func _recuerdo(id: String) -> DefinicionRecuerdo:
	return load("res://data/recuerdos/%s.tres" % id)


## Un estado con de todo: party con conjuros e inmunidades, recuerdos, Tasador, residuo, destinos, mundo,
## sueños, pendientes y un RNG ya usado.
func _llenar_estado() -> void:
	GameState.reiniciar_dados(987654321)
	for i in 7:
		GameState.dados.d20()
	GameState.id_mapa_actual = &"mapa_prueba_b"
	GameState.ubicacion = {"celdas": {&"Miembro1": Vector2i(3, 4), &"Miembro2": Vector2i(2, 4)}, "entrada": &"desde_a"}
	GameState.combate_pendiente = &"encuentro_prueba"
	GameState.perdida_pendiente = true
	GameState.id_ultimo_punto_estable = &"punto_estable_prueba_a"
	GameState.id_mapa_ultimo_punto_estable = &"mapa_prueba_a"
	var usados: Array[bool] = [true, false]
	var inmunes: Array[StringName] = [&"Miembro1"]
	GameState.estado_party[&"Miembro3"] = {"pg": 7, "herido": 1, "muerto": false, "conjuros": {"usados": usados, "foco": 0},
		"inmune_medicina": inmunes}
	GameState.estado_party[&"Miembro2"] = {"pg": 0, "herido": 1, "muerto": true}
	var inventario: InventarioRecuerdos = GameState.recuerdos.inventario
	inventario.agregar_suelto(_recuerdo("destreza_sigilo"))
	inventario.integrados.append(_recuerdo("destreza_medicina"))
	inventario.vistos.append(_recuerdo("vivencia_2"))
	GameState.recuerdos.tasador.credito = 15
	GameState.recuerdos.tasador.agregar_al_stock(_recuerdo("vivencia_3"), 50)
	GameState.recuerdos.residuo = {"mapa": &"mapa_prueba_b", "celda": Vector2i(12, 10), "recuerdos": [_recuerdo("vivencia_4")] as Array[DefinicionRecuerdo]}
	GameState.recuerdos.registrar_destino(&"mapa_prueba_b/EnemigoDistancia", EstadoRecuerdos.Destino.EXTRAIDO)
	GameState.mundo.resolver_encuentro(&"mapa_prueba_b", &"encuentro_prueba")
	GameState.mundo.retirar_enemigo(&"mapa_prueba_b", &"EnemigoCuerpoACuerpo")
	GameState.mundo.dejar_cuerpo(&"Miembro2", &"mapa_prueba_b", Vector2i(12, 9), true)
	GameState.mundo.tomar_objeto(&"mapa_prueba_a", &"RecuerdoMedicina")
	GameState.suenos_vistos.append(&"sueno_placeholder_1")
	GameState.marcas[&"tasador_presentado"] = true


func test_ida_y_vuelta_del_estado_completo_con_el_rng() -> void:
	_llenar_estado()
	assert_bool(SaveSystem.guardar()).is_true()
	var antes: String = JSON.stringify(GameState.a_diccionario())
	var tiradas_sin_guardar: Array[int] = GameState.dados.tirar_varios(5, 20)
	GameState.nueva_partida()
	GameState.reiniciar_dados(1)
	assert_bool(SaveSystem.cargar()).is_true()
	assert_str(JSON.stringify(GameState.a_diccionario())).is_equal(antes)
	assert_array(GameState.dados.tirar_varios(5, 20)).is_equal(tiradas_sin_guardar)
	# Los tipos vuelven bien (no como float ni String).
	assert_int(typeof(GameState.estado_party[&"Miembro3"].pg)).is_equal(TYPE_INT)
	assert_that(GameState.ubicacion.celdas[&"Miembro1"]).is_equal(Vector2i(3, 4))
	assert_object(GameState.recuerdos.inventario.integrados[0]).is_same(_recuerdo("destreza_medicina"))


func test_la_escritura_es_atomica_y_sin_temporal_al_terminar() -> void:
	assert_bool(SaveSystem.guardar()).is_true()
	assert_bool(FileAccess.file_exists(SaveSystem.ruta)).is_true()
	assert_bool(FileAccess.file_exists(SaveSystem.ruta + SaveSystem.SUFIJO_TEMPORAL)).is_false()
	# Guardar encima de una partida existente también funciona.
	GameState.id_ultimo_punto_estable = &"otro"
	assert_bool(SaveSystem.guardar()).is_true()
	GameState.id_ultimo_punto_estable = &""
	assert_bool(SaveSystem.cargar()).is_true()
	assert_str(GameState.id_ultimo_punto_estable).is_equal("otro")


func test_un_cierre_antes_del_renombrado_usa_el_temporal_completo() -> void:
	_llenar_estado()
	var texto: String = JSON.stringify(GameState.a_diccionario())
	var archivo: FileAccess = FileAccess.open(SaveSystem.ruta + SaveSystem.SUFIJO_TEMPORAL, FileAccess.WRITE)
	archivo.store_string(texto)
	archivo.close()
	GameState.nueva_partida()
	assert_bool(SaveSystem.hay_partida()).is_true()
	assert_bool(SaveSystem.cargar()).is_true()
	assert_str(GameState.combate_pendiente).is_equal("encuentro_prueba")


func test_un_guardado_danado_o_de_una_version_futura_no_se_carga() -> void:
	var archivo: FileAccess = FileAccess.open(SaveSystem.ruta, FileAccess.WRITE)
	archivo.store_string("{\"version\": 1, \"mapa\": ")
	archivo.close()
	assert_bool(SaveSystem.cargar()).is_false()
	assert_object(SaveSystem.migrar({"version": GameState.VERSION_GUARDADO + 1})).is_null()
	assert_object(SaveSystem.migrar({"version": GameState.VERSION_GUARDADO})).is_not_null()
	assert_bool(SaveSystem.hay_partida()).is_false()

extends GdUnitTestSuite
## Lo que un diálogo puede consultar y cambiar (`estado`), y las condiciones de los disparadores.


func before_test() -> void:
	GameState.nueva_partida()


func after_test() -> void:
	GameState.nueva_partida()


func test_consultas_sobre_el_estado_de_la_partida() -> void:
	var estado: ContextoDialogo = ContextoDialogo.new()
	GameState.recuerdos.inventario.integrados.append(load("res://data/recuerdos/destreza_sigilo.tres"))
	GameState.recuerdos.registrar_destino(&"mapa_prueba_b/EnemigoDistancia", EstadoRecuerdos.Destino.PERDONADO)
	GameState.estado_party[&"Miembro3"] = {"pg": 0, "herido": 1, "muerto": true}
	assert_bool(estado.tiene_integrado("destreza_sigilo")).is_true()
	assert_bool(estado.tiene_integrado("destreza_medicina")).is_false()
	assert_str(estado.destino("mapa_prueba_b/EnemigoDistancia")).is_equal("perdonado")
	assert_str(estado.destino("mapa_prueba_b/Otro")).is_empty()
	assert_bool(estado.companero_vivo("Miembro2")).is_true()
	assert_bool(estado.companero_vivo("Miembro3")).is_false()


func test_marcar_cambia_el_estado_una_vez() -> void:
	var estado: ContextoDialogo = ContextoDialogo.new()
	estado.marcar("algo")
	assert_bool(estado.hubo_cambios).is_true()
	assert_bool(GameState.marcas.has(&"algo")).is_true()
	var otro: ContextoDialogo = ContextoDialogo.new()
	otro.marcar("algo")
	assert_bool(otro.hubo_cambios).is_false()


func test_condiciones_de_los_disparadores() -> void:
	var estado: ContextoDialogo = ContextoDialogo.new()
	assert_bool(estado.cumple("")).is_true()
	assert_bool(estado.cumple('estado.companero_vivo("Miembro2") and not estado.vio_sueno("sueno_placeholder_1")')).is_true()
	GameState.suenos_vistos.append(&"sueno_placeholder_1")
	assert_bool(estado.cumple('not estado.vio_sueno("sueno_placeholder_1")')).is_false()


func test_los_dialogos_del_juego_tienen_sus_cues() -> void:
	var tasador: DialogueResource = load("res://dialogue/tasador.dialogue")
	assert_array(Array(tasador.get_cues())).contains(["presentacion", "charla"])
	var companeros: DialogueResource = load("res://dialogue/companeros.dialogue")
	assert_array(Array(companeros.get_cues())).contains(["irsa", "orven", "vaisha"])

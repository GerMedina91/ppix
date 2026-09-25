extends GdUnitTestSuite
## Integración de la transparencia de paredes en el mapa de prueba A.

const ESCENA: String = "res://scenes/world/mundo.tscn"
const ESPERA_MS: int = 8000

## Actor de prueba ajeno a la party, para verificar que la detección es genérica.
class ActorDePrueba extends Node2D:
	func rect_visible_global() -> Rect2:
		return Rect2(global_position + Vector2(-16, -56), Vector2(32, 56))

var _runner: GdUnitSceneRunner
var _party: ControlParty
var _mapa: Mapa
var _paredes: CapaParedes


func before_test() -> void:
	_runner = scene_runner(ESCENA)
	_party = _runner.find_child("Party")
	_mapa = _runner.find_child("MapaActual").get_child(0)
	_paredes = _mapa.get_node("Paredes")


func _llevar_party_a(celda: Vector2i) -> void:
	_party.ir_a_celda(celda)
	await _runner.await_func_on(_party, "celda_lider").wait_until(ESPERA_MS).is_equal(celda)
	for miembro: Node in _party.get_children():
		await _runner.await_func_on(miembro, "esta_moviendose").wait_until(ESPERA_MS).is_false()
	await _runner.simulate_frames(3)


func _se_transparenta(celda: Vector2i) -> bool:
	return _paredes.get_cell_tile_data(celda).get_custom_data(CapaParedes.DATO_SE_TRANSPARENTA)


func test_detras_de_un_muro_la_pared_de_adelante_se_vuelve_transparente() -> void:
	await _llevar_party_a(Vector2i(6, 2))
	var transparentes: Array[Vector2i] = _paredes.celdas_transparentes()
	assert_array(transparentes).contains([Vector2i(6, 3)])
	assert_array(transparentes).not_contains([Vector2i(6, 0), Vector2i(0, 2)])  # paredes del fondo
	for celda in transparentes:
		assert_bool(_se_transparenta(celda)).override_failure_message("%s no es transparentable" % celda).is_true()


func test_en_campo_abierto_no_hay_paredes_transparentes() -> void:
	await _llevar_party_a(Vector2i(6, 2))
	await _llevar_party_a(Vector2i(12, 8))
	assert_array(_paredes.celdas_transparentes()).is_empty()


func test_funciona_con_cualquier_actor_del_grupo() -> void:
	await _llevar_party_a(Vector2i(12, 8))
	var actor: ActorDePrueba = auto_free(ActorDePrueba.new())
	actor.add_to_group(OclusionParedes.GRUPO_VISIBLES)
	_runner.scene().add_child(actor)
	actor.global_position = _mapa.celda_a_posicion(Vector2i(13, 3))  # justo detrás del muro vertical (13,4)
	await _runner.simulate_frames(3)
	assert_array(_paredes.celdas_transparentes()).contains([Vector2i(13, 4)])


func test_actor_al_lado_de_una_pared_no_la_transparenta() -> void:
	await _llevar_party_a(Vector2i(12, 8))
	var actor: ActorDePrueba = auto_free(ActorDePrueba.new())
	actor.add_to_group(OclusionParedes.GRUPO_VISIBLES)
	_runner.scene().add_child(actor)
	# Al costado del muro vertical (13,4..6): celda (14,3), a la misma altura de pantalla que (13,4).
	actor.global_position = _mapa.celda_a_posicion(Vector2i(14, 3))
	await _runner.simulate_frames(3)
	assert_array(_paredes.celdas_transparentes()).not_contains([Vector2i(13, 4)])
	# Entre celdas, rozando solo la esquina vacía de la textura de (13,4).
	actor.global_position = _mapa.celda_a_posicion(Vector2i(13, 4)) + Vector2(36, -78)
	await _runner.simulate_frames(3)
	assert_array(_paredes.celdas_transparentes()).not_contains([Vector2i(13, 4)])


func test_al_alejarse_las_paredes_quedan_intactas() -> void:
	# El arreglo del redibujado borra y vuelve a poner celdas: no tiene que perder paredes.
	var antes: Dictionary = {}
	for celda: Vector2i in _paredes.get_used_cells():
		antes[celda] = _paredes.get_cell_source_id(celda)
	await _llevar_party_a(Vector2i(6, 2))
	await _llevar_party_a(Vector2i(15, 9))
	assert_array(_paredes.celdas_transparentes()).is_empty()
	var despues: Dictionary = {}
	for celda: Vector2i in _paredes.get_used_cells():
		despues[celda] = _paredes.get_cell_source_id(celda)
	assert_dict(despues).is_equal(antes)
	assert_bool(_mapa.construir_grilla().es_transitable(Vector2i(6, 3))).is_false()

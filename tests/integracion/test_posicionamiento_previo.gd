extends GdUnitTestSuite
## Posicionamiento previo en el mundo: al dispararse el encuentro, antes de la iniciativa, se reubica a los
## miembros (hasta 10 pies) y el combate empieza con esas casillas.

const ESCENA: String = "res://tests/escenas/mundo_prueba.tscn"
const FRAMES_MAXIMOS: int = 3000

var _runner: GdUnitSceneRunner
var _party: ControlParty
var _control: ControladorCombate
var _fase: PosicionamientoPrevio


func before_test() -> void:
	GameState.nueva_partida()
	GameState.reiniciar_dados(11)
	SaveSystem.borrar()
	_runner = scene_runner(ESCENA)
	_party = _runner.find_child("Party")
	_control = _runner.find_child("ControladorCombate")
	_fase = _runner.find_child("PosicionamientoPrevio")


func after_test() -> void:
	SaveSystem.borrar()
	GameState.nueva_partida()


func _esperar(condicion: Callable) -> bool:
	for i in FRAMES_MAXIMOS:
		if condicion.call():
			return true
		await _runner.simulate_frames(1)
	return false


func _hasta_la_fase() -> void:
	_party.ir_a_celda(Vector2i(19, 5))
	assert_bool(await _esperar(func() -> bool: return GameState.id_mapa_actual == &"mapa_prueba_b" and not _party.bloqueado)).is_true()
	_party.ir_a_celda(Vector2i(13, 10))
	assert_bool(await _esperar(func() -> bool: return _fase.activo())).override_failure_message("no empezó el posicionamiento").is_true()


func test_antes_de_la_iniciativa_se_reubica_y_el_combate_usa_esas_casillas() -> void:
	await _hasta_la_fase()
	assert_bool(_control.en_curso()).is_false()
	assert_str(GameState.combate_pendiente).is_equal("encuentro_prueba")  # ya guardado: si se cierra, se vuelve a posicionar
	var irsa: MiembroParty = _runner.find_child("Miembro2")
	_fase.click_en(irsa.celda)
	assert_object(_fase.elegido()).is_same(irsa)
	var destino: Vector2i = _fase.posibles().filter(func(c: Vector2i) -> bool: return c != irsa.celda)[0]
	_fase.click_en(destino)
	assert_that(irsa.celda).is_equal(destino)
	_fase.terminar()
	assert_bool(await _esperar(func() -> bool: return _control.en_curso())).is_true()
	assert_that(_control.combate().combatiente(&"Miembro2").celda).is_equal(destino)


func test_las_casillas_estan_a_10_pies_y_lejos_de_los_enemigos() -> void:
	await _hasta_la_fase()
	var eco: MiembroParty = _runner.find_child("Miembro1")
	var origen: Vector2i = eco.celda
	_fase.click_en(origen)
	var enemigos: Array = (_runner.find_child("EncuentroPrueba") as Encuentro).enemigos().map(func(e: EnemigoEnMapa) -> Vector2i: return e.celda)
	for celda: Vector2i in _fase.posibles():
		assert_int(Medicion.pies_entre(origen, celda)).is_less_equal(10)
		for e: Vector2i in enemigos:
			assert_bool(absi(e.x - celda.x) <= 1 and absi(e.y - celda.y) <= 1).is_false()
	_fase.terminar()

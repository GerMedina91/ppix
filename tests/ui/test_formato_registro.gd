extends GdUnitTestSuite

const DadosFijos: GDScript = preload("res://tests/utiles/dados_fijos.gd")
const CAC: String = "res://data/personajes/party_prueba_cuerpo_a_cuerpo.tres"
const ENEMIGO: String = "res://data/criaturas/enemigo_prueba_cuerpo_a_cuerpo.tres"


func _duelo(dados: Array) -> Combate:
	var grilla: GrillaMapa = GrillaMapa.new(Rect2i(0, 0, 10, 10))
	for x in 10:
		for y in 10:
			grilla.set_transitable(Vector2i(x, y), true)
	var participantes: Array[Combatiente] = [
		Combatiente.desde_personaje(&"pj", load(CAC), Vector2i(2, 2)),
		Combatiente.desde_criatura(&"e", load(ENEMIGO), Vector2i(3, 2))]
	var combate: Combate = Combate.new(participantes, grilla, DadosFijos.new(dados))
	combate.iniciar()
	return combate


func test_golpe_con_desglose_y_danio() -> void:
	var combate: Combate = _duelo([15, 5, 10, 5])
	var evento: EventoCombate = combate.golpe(&"e")[0]
	assert_str(FormatoRegistro.texto(evento, combate)).is_equal(
		"pj → e: 10 (+4 Fuerza, +3 competencia (entrenado)) = 17 contra CA 16: éxito, 9 de daño")


func test_golpe_fallado_sin_danio() -> void:
	var combate: Combate = _duelo([15, 5, 2])
	var evento: EventoCombate = combate.golpe(&"e")[0]
	assert_str(FormatoRegistro.texto(evento, combate)).ends_with("contra CA 16: fallo")


func test_movimiento_con_pies() -> void:
	var combate: Combate = _duelo([15, 5])
	var evento: EventoCombate = combate.zancada(Vector2i(2, 5))[0]
	assert_str(FormatoRegistro.texto(evento, combate)).is_equal("pj: Zancada (15 pies)")


func test_iniciativa_y_ronda() -> void:
	var combate: Combate = _duelo([15, 5])
	var textos: Array = combate.registro.map(func(e: EventoCombate) -> String: return FormatoRegistro.texto(e, combate))
	assert_array(textos).contains(["pj: iniciativa 19", "e: iniciativa 11", "— Ronda 1 —"])


func test_eventos_sin_texto() -> void:
	var combate: Combate = _duelo([15, 5])
	var inicio: EventoCombate = EventoCombate.new(EventoCombate.Tipo.INICIO_TURNO, &"pj")
	assert_str(FormatoRegistro.texto(inicio, combate)).is_empty()

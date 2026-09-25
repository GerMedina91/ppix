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


func test_condiciones_en_el_registro() -> void:
	var combate: Combate = _duelo([15, 5])
	var cambio: EventoCombate = EventoCombate.new(EventoCombate.Tipo.CONDICION, &"pj",
		{"condicion": Condiciones.Tipo.ASUSTADO, "valor": 1, "anterior": 2})
	var fin: EventoCombate = EventoCombate.new(EventoCombate.Tipo.CONDICION, &"pj",
		{"condicion": Condiciones.Tipo.HUYENDO, "valor": 0, "anterior": 1})
	var perdidas: EventoCombate = EventoCombate.new(EventoCombate.Tipo.ACCIONES_PERDIDAS, &"e",
		{"cantidad": 2, "condicion": Condiciones.Tipo.ATURDIDO})
	assert_str(FormatoRegistro.texto(cambio, combate)).is_equal("pj: asustado 1")
	assert_str(FormatoRegistro.texto(fin, combate)).is_equal("pj ya no está huyendo")
	assert_str(FormatoRegistro.texto(perdidas, combate)).is_equal("e pierde 2 acciones por aturdido")


func test_arcadas_en_el_registro() -> void:
	# Fortaleza +5: 12 + 5 = 17 contra CD 15, éxito.
	var combate: Combate = _duelo([15, 5, 12])
	combate.turno_actual().condiciones.aplicar(EfectoCondicion.new(Condiciones.Tipo.INDISPUESTO, 2, 15))
	var evento: EventoCombate = combate.arcadas()[0]
	assert_str(FormatoRegistro.texto(evento, combate)).is_equal("pj: Arcadas, Fortaleza 17 contra CD 15: éxito (indispuesto 1)")

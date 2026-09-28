extends GdUnitTestSuite
## Resistencias (Player Core p. 408): después de la debilidad, hasta 0. Versátil (Player Core p. 283): el tipo que más
## daño hace. Criaturas que quedan inconscientes a 0 PG (Player Core p. 410; decisión del director para los humanos).
## Guerrero: espadón +9 (1d12+4, cortante, versátil perforante). Esqueleto (Skeleton Guard, Monster Core p. 312):
## CA 16, 4 PG, resistencia 5 a cortante, perforante, fuego, frío y electricidad.

const DadosFijos: GDScript = preload("res://tests/utiles/dados_fijos.gd")
const GUERRERO: String = "res://data/builds/guerrero.tres"
const ESQUELETO: String = "res://data/criaturas/esqueleto_guardia.tres"
const PEREGRINO: String = "res://data/criaturas/deudo_peregrino.tres"


func _grilla() -> GrillaMapa:
	var grilla: GrillaMapa = GrillaMapa.new(Rect2i(0, 0, 12, 6))
	for x in 12:
		for y in 6:
			grilla.set_transitable(Vector2i(x, y), true)
	return grilla


## El guerrero en (2,2) empieza (15 contra 1) contra la criatura en (3,2).
func _combate(criatura: DefinicionCriatura, dados: Array, build: String = GUERRERO) -> Combate:
	var participantes: Array[Combatiente] = [Combatiente.desde_personaje(&"pj", ArmadorPersonaje.armar(load(build)), Vector2i(2, 2)),
		Combatiente.desde_criatura(&"c", criatura, Vector2i(3, 2))]
	var combate: Combate = Combate.new(participantes, _grilla(), DadosFijos.new([15, 1] + dados))
	combate.iniciar()
	assert_str(combate.turno_actual().id).is_equal("pj")
	return combate


func _criatura(rasgo: RasgoCriatura.Tipo = RasgoCriatura.Tipo.HUMANOIDE) -> DefinicionCriatura:
	var criatura: DefinicionCriatura = DefinicionCriatura.new()
	criatura.rasgo = rasgo
	criatura.ca = 10
	criatura.pg = 20
	criatura.fortaleza = 6
	criatura.armas.append(load("res://data/armas/arma_zombi_puno.tres"))
	return criatura


func test_la_resistencia_resta_del_danio() -> void:
	# 10 + 9 = 19 contra CA 16: 1d12 = 3 + 4 = 7, -5 de resistencia a cortante.
	var combate: Combate = _combate(load(ESQUELETO), [10, 3])
	var eventos: Array[EventoCombate] = combate.golpe(&"c")
	assert_int(combate.combatiente(&"c").pg).is_equal(2)
	assert_str(FormatoRegistro.texto(eventos[0], combate)).ends_with("2 de daño (-5 resistencia)")


func test_la_resistencia_puede_dejar_el_danio_en_cero() -> void:
	# 1d12 = 1 + 4 = 5, -5: acierta pero no hace daño.
	var combate: Combate = _combate(load(ESQUELETO), [10, 1])
	var eventos: Array[EventoCombate] = combate.golpe(&"c")
	assert_int(combate.combatiente(&"c").pg).is_equal(4)
	assert_str(FormatoRegistro.texto(eventos[0], combate)).ends_with("0 de daño (-5 resistencia)")


func test_primero_la_debilidad_despues_la_resistencia() -> void:
	var criatura: DefinicionCriatura = _criatura()
	criatura.debilidades[DefinicionArma.TipoDanio.CORTANTE] = 5
	criatura.resistencias[DefinicionArma.TipoDanio.CORTANTE] = 3
	var ajuste: Dictionary = AjusteDanio.aplicar(FuenteCriatura.new(criatura), DefinicionArma.TipoDanio.CORTANTE, 2)
	assert_int(ajuste.danio).is_equal(4)
	assert_int(ajuste.debilidad).is_equal(5)
	assert_int(ajuste.resistencia).is_equal(3)


func test_el_arma_versatil_usa_el_tipo_que_mas_danio_hace() -> void:
	var espadon: DefinicionArma = load("res://data/armas/espadon.tres")
	var criatura: DefinicionCriatura = _criatura()
	assert_int(AjusteDanio.tipo_de_golpe(espadon, FuenteCriatura.new(criatura))).is_equal(DefinicionArma.TipoDanio.CORTANTE)
	criatura.resistencias[DefinicionArma.TipoDanio.CORTANTE] = 5
	assert_int(AjusteDanio.tipo_de_golpe(espadon, FuenteCriatura.new(criatura))).is_equal(DefinicionArma.TipoDanio.PERFORANTE)
	# Contra el esqueleto resiste los dos por igual: queda el principal.
	assert_int(AjusteDanio.tipo_de_golpe(espadon, FuenteCriatura.new(load(ESQUELETO)))).is_equal(DefinicionArma.TipoDanio.CORTANTE)


func test_el_golpe_versatil_esquiva_la_resistencia() -> void:
	# CA 10: 10 + 9 = 19; 1d12 = 3 + 4 = 7 perforante, sin la resistencia 5 a cortante.
	var criatura: DefinicionCriatura = _criatura()
	criatura.resistencias[DefinicionArma.TipoDanio.CORTANTE] = 5
	var combate: Combate = _combate(criatura, [10, 3])
	combate.golpe(&"c")
	assert_int(combate.combatiente(&"c").pg).is_equal(13)


func test_la_resistencia_se_aplica_al_danio_de_conjuro() -> void:
	# Curar (2 acciones, a distancia) contra un muerto viviente con resistencia 4 a vitalidad: 1d8 = 6, Fortaleza
	# 2 + 6 = 8 contra CD 17: fallo, 6 completo - 4.
	var criatura: DefinicionCriatura = _criatura(RasgoCriatura.Tipo.MUERTO_VIVIENTE)
	criatura.resistencias[DefinicionArma.TipoDanio.VITALIDAD] = 4
	var combate: Combate = _combate(criatura, [6, 2], "res://data/builds/clerigo.tres")
	combate.lanzar_conjuro(load("res://data/conjuros/curar.tres"), &"c", AccionesConjuro.SIN_CELDA, [], false, 2)
	assert_int(combate.combatiente(&"c").pg).is_equal(18)


func test_el_humano_queda_inconsciente_a_cero_y_otro_golpe_lo_mata() -> void:
	# Peregrino: CA 15, 15 PG. Crítico: 20 + 9; 1d12 = 12 + 4 = 16 × 2 = 32. Después, 10 + 4 (-5 por ataque múltiple).
	var combate: Combate = _combate(load(PEREGRINO), [20, 12, 15, 5])
	combate.golpe(&"c")
	var peregrino: Combatiente = combate.combatiente(&"c")
	assert_int(peregrino.pg).is_equal(0)
	assert_bool(peregrino.condiciones.inconsciente).is_true()
	assert_bool(peregrino.condiciones.muerto).is_false()
	assert_int(peregrino.condiciones.moribundo).is_equal(0)


func test_el_humano_inconsciente_cuenta_como_vencido() -> void:
	var combate: Combate = _combate(load(PEREGRINO), [20, 12])
	combate.golpe(&"c")
	assert_int(combate.estado).is_equal(Combate.Estado.VICTORIA)
	var resultado: ResultadoCombate = ResultadoCombate.desde(combate)
	assert_array(resultado.enemigos_inconscientes).contains([&"c"])


func test_golpear_al_inconsciente_lo_mata() -> void:
	var criatura: DefinicionCriatura = _criatura()
	criatura.inconsciente_a_cero = true
	var c: Combatiente = Combatiente.desde_criatura(&"c", criatura, Vector2i.ZERO)
	c.recibir_danio(20, false)
	assert_bool(c.condiciones.inconsciente).is_true()
	c.recibir_danio(1, false)
	assert_bool(c.condiciones.muerto).is_true()


func test_el_muerto_viviente_no_queda_inconsciente() -> void:
	var criatura: DefinicionCriatura = _criatura(RasgoCriatura.Tipo.MUERTO_VIVIENTE)
	criatura.inconsciente_a_cero = true
	var c: Combatiente = Combatiente.desde_criatura(&"c", criatura, Vector2i.ZERO)
	c.recibir_danio(20, false)
	assert_bool(c.condiciones.muerto).is_true()

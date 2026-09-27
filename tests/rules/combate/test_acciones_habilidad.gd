extends GdUnitTestSuite
## Medicina en batalla (Player Core p. 253) y Recordar conocimiento acotado (p. 231; GM Core p. 52 y 54).
## Eco (guerrero) con los recuerdos de Medicina: Medicina +5 (Sab +2, entrenado +3). Sociedad +0 (sin
## entrenar, Int 0). Enemigo de prueba: nivel 1 (CD 15), Fortaleza +8, Reflejos +5, Voluntad +5.

const DadosFijos: GDScript = preload("res://tests/utiles/dados_fijos.gd")
const GUERRERO: String = "res://data/builds/guerrero.tres"
const BRUJA: String = "res://data/builds/bruja.tres"
const ENEMIGO: String = "res://data/criaturas/enemigo_prueba_cuerpo_a_cuerpo.tres"
const E: Dictionary = {"ESPECIAL": EventoCombate.Tipo.ACCION_ESPECIAL, "RESULTADO": EventoCombate.Tipo.RESULTADO_ESPECIAL,
	"INVALIDA": EventoCombate.Tipo.ACCION_INVALIDA}


func _grilla() -> GrillaMapa:
	var grilla: GrillaMapa = GrillaMapa.new(Rect2i(0, 0, 16, 8))
	for x in 16:
		for y in 8:
			grilla.set_transitable(Vector2i(x, y), true)
	return grilla


func _eco_con_medicina() -> DefinicionPersonaje:
	var medicina: DefinicionRecuerdo = DefinicionRecuerdo.new()
	medicina.id = &"m"
	var b1: BeneficioHabilidad = BeneficioHabilidad.new()
	b1.habilidad = Habilidad.Tipo.MEDICINA
	medicina.beneficio = b1
	var batalla: DefinicionRecuerdo = DefinicionRecuerdo.new()
	batalla.id = &"b"
	var b2: BeneficioDote = BeneficioDote.new()
	b2.dote = load("res://data/capacidades/medicina_en_batalla.tres")
	batalla.beneficio = b2
	var recuerdos: Array[DefinicionRecuerdo] = [medicina, batalla]
	return ArmadorPersonaje.armar(load(GUERRERO), recuerdos)


## Eco en (2,2) (empieza), bruja aliada en `celda_aliada`, enemigo en `celda_enemigo`.
func _combate(dados: Array, celda_aliada: Vector2i = Vector2i(3, 2), enemigo: DefinicionCriatura = null,
		celda_enemigo: Vector2i = Vector2i(8, 2)) -> Combate:
	var participantes: Array[Combatiente] = [Combatiente.desde_personaje(&"eco", _eco_con_medicina(), Vector2i(2, 2)),
		Combatiente.desde_personaje(&"aliada", ArmadorPersonaje.armar(load(BRUJA)), celda_aliada),
		Combatiente.desde_criatura(&"e", enemigo if enemigo != null else load(ENEMIGO), celda_enemigo)]
	var combate: Combate = Combate.new(participantes, _grilla(), DadosFijos.new([15, 1, 5] + dados))
	combate.iniciar()
	assert_str(combate.turno_actual().id).is_equal("eco")
	return combate


func _tipos(eventos: Array[EventoCombate]) -> Array:
	return eventos.map(func(e: EventoCombate) -> EventoCombate.Tipo: return e.tipo)


# --- Medicina en batalla ---

func test_medicina_en_batalla_segun_la_prueba() -> void:
	# +5 contra CD 15: 12 = 17 éxito (2d8: 3 + 4); 20 = crítico (4d8: 1 + 2 + 3 + 4); 1 natural = fallo crítico (1d8: 5 de daño).
	for caso: Array in [[[12, 3, 4], 7, 0], [[20, 1, 2, 3, 4], 10, 0], [[1, 5], 0, 5]]:
		var combate: Combate = _combate(caso[0])
		var aliada: Combatiente = combate.combatiente(&"aliada")
		aliada.pg = 5
		var eventos: Array[EventoCombate] = combate.habilidades.medicina_en_batalla(&"aliada")
		assert_array(_tipos(eventos).slice(0, 2)).is_equal([E.ESPECIAL, E.RESULTADO])  # (con 5 de daño, además cae)
		assert_int(eventos[1].datos.curacion).override_failure_message(str(caso[0])).is_equal(caso[1])
		assert_int(eventos[1].datos.danio).is_equal(caso[2])
		assert_int(combate.turno_actual().acciones_restantes).is_equal(2)


func test_el_mismo_sanador_no_repite_sobre_el_mismo_objetivo() -> void:
	var combate: Combate = _combate([12, 3, 4])
	combate.combatiente(&"aliada").pg = 5
	combate.habilidades.medicina_en_batalla(&"aliada")
	var eventos: Array[EventoCombate] = combate.habilidades.medicina_en_batalla(&"aliada")
	assert_str(eventos[0].datos.motivo).is_equal("ya lo atendió (inmune hasta descansar)")


func test_tiene_que_estar_al_lado_y_herido() -> void:
	var lejos: Combate = _combate([], Vector2i(5, 2))
	lejos.combatiente(&"aliada").pg = 5
	assert_str(lejos.habilidades.medicina_en_batalla(&"aliada")[0].datos.motivo).is_equal("tiene que estar al lado")
	var sano: Combate = _combate([])
	assert_str(sano.habilidades.medicina_en_batalla(&"aliada")[0].datos.motivo).is_equal("no está herido")


func test_sin_la_dote_no_se_puede() -> void:
	var participantes: Array[Combatiente] = [Combatiente.desde_personaje(&"g", ArmadorPersonaje.armar(load(GUERRERO)), Vector2i(2, 2)),
		Combatiente.desde_criatura(&"e", load(ENEMIGO), Vector2i(3, 2))]
	var combate: Combate = Combate.new(participantes, _grilla(), DadosFijos.new([15, 5]))
	combate.iniciar()
	combate.turno_actual().pg -= 5
	assert_str(combate.habilidades.medicina_en_batalla(&"g")[0].datos.motivo).is_equal("no tiene esa dote")


# --- Recordar conocimiento ---

func test_recordar_con_exito_revela_la_salvacion_mas_debil() -> void:
	# Humanoide: Sociedad +0; 15 contra CD 15, éxito. Reflejos y Voluntad +5 empatan: Reflejos.
	var combate: Combate = _combate([15])
	var eventos: Array[EventoCombate] = combate.habilidades.recordar_conocimiento(&"e")
	var e: Combatiente = combate.combatiente(&"e")
	assert_int(e.conocimiento.salvacion_debil).is_equal(Estadisticas.Salvacion.REFLEJOS)
	assert_str(FormatoRegistro.texto(eventos[0], combate)).is_equal("eco recuerda algo sobre e (Sociedad)")
	assert_str(FichaCombatiente.ficha(e)).ends_with("Salvación más débil: Reflejos (según eco)")


func test_con_fallo_critico_recuerda_algo_falso_y_con_fallo_nada() -> void:
	var critico: Combate = _combate([1])
	critico.habilidades.recordar_conocimiento(&"e")
	assert_int(critico.combatiente(&"e").conocimiento.salvacion_debil).is_equal(Estadisticas.Salvacion.FORTALEZA)
	var fallo: Combate = _combate([10])
	var eventos: Array[EventoCombate] = fallo.habilidades.recordar_conocimiento(&"e")
	assert_dict(fallo.combatiente(&"e").conocimiento).is_empty()
	assert_str(FormatoRegistro.texto(eventos[0], fallo)).is_equal("eco no recuerda nada sobre e")


func test_la_habilidad_depende_del_rasgo_de_la_criatura() -> void:
	var muerto: DefinicionCriatura = (load(ENEMIGO) as DefinicionCriatura).duplicate()
	muerto.rasgo = RasgoCriatura.Tipo.MUERTO_VIVIENTE
	var combate: Combate = _combate([15], Vector2i(3, 2), muerto)
	var eventos: Array[EventoCombate] = combate.habilidades.recordar_conocimiento(&"e")
	assert_int(eventos[0].datos.habilidad).is_equal(Habilidad.Tipo.RELIGION)


func test_cd_por_nivel_y_rareza() -> void:
	assert_int(RasgoCriatura.cd_recordar(1, RasgoCriatura.Rareza.COMUN)).is_equal(15)
	assert_int(RasgoCriatura.cd_recordar(3, RasgoCriatura.Rareza.POCO_COMUN)).is_equal(20)
	assert_int(RasgoCriatura.cd_recordar(-1, RasgoCriatura.Rareza.RARO)).is_equal(19)


func test_no_se_usa_sobre_aliados() -> void:
	var combate: Combate = _combate([])
	assert_array(_tipos(combate.habilidades.recordar_conocimiento(&"aliada"))).is_equal([E.INVALIDA])

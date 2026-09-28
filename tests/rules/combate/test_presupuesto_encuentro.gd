extends GdUnitTestSuite
## Presupuesto de XP (GM Core p. 75-76) y las criaturas del slice (docs/verificacion/m5_criaturas.md).

const CRIATURAS: String = "res://data/criaturas/%s.tres"


func _criaturas(ids: Array[String]) -> Array[DefinicionCriatura]:
	var lista: Array[DefinicionCriatura] = []
	for id: String in ids:
		lista.append(load(CRIATURAS % id))
	return lista


func test_xp_por_nivel_para_party_de_nivel_1() -> void:
	var esperado: Dictionary = {-3: 10, -2: 15, -1: 20, 0: 30, 1: 40, 2: 60, 3: 80, 4: 120, 5: 160}
	for nivel: int in esperado:
		assert_int(PresupuestoEncuentro.xp_de(nivel, 1)).is_equal(esperado[nivel])
	assert_int(PresupuestoEncuentro.xp_de(-4, 1)).is_equal(0)


func test_amenaza_por_xp() -> void:
	assert_int(PresupuestoEncuentro.amenaza(40)).is_equal(PresupuestoEncuentro.Amenaza.TRIVIAL)
	assert_int(PresupuestoEncuentro.amenaza(60)).is_equal(PresupuestoEncuentro.Amenaza.BAJA)
	assert_int(PresupuestoEncuentro.amenaza(80)).is_equal(PresupuestoEncuentro.Amenaza.MODERADA)
	assert_int(PresupuestoEncuentro.amenaza(120)).is_equal(PresupuestoEncuentro.Amenaza.SEVERA)
	assert_int(PresupuestoEncuentro.amenaza(160)).is_equal(PresupuestoEncuentro.Amenaza.EXTREMA)


func test_encuentros_del_slice() -> void:
	# Combate 1: moderado; combate 2: moderado; combate 3: severo (decisión del director).
	assert_int(PresupuestoEncuentro.xp_total(_criaturas(["deudo_peregrino", "deudo_peregrino", "deudo_devoto"]), 1)).is_equal(80)
	assert_int(PresupuestoEncuentro.xp_total(_criaturas(["muerto_viviente_prueba", "muerto_viviente_prueba",
		"esqueleto_guardia", "esqueleto_guardia_arquero"]), 1)).is_equal(80)
	assert_int(PresupuestoEncuentro.xp_total(_criaturas(["deudo_lider", "eco_fallido"]), 1)).is_equal(120)


func test_las_criaturas_del_slice_no_tienen_errores_de_datos() -> void:
	for id: String in ["deudo_peregrino", "deudo_devoto", "deudo_lider", "eco_fallido", "esqueleto_guardia", "esqueleto_guardia_arquero"]:
		var criatura: DefinicionCriatura = load(CRIATURAS % id)
		assert_array(criatura.errores_de_datos()).is_empty()


func test_los_humanos_quedan_inconscientes_y_los_demas_no() -> void:
	for id: String in ["deudo_peregrino", "deudo_devoto", "deudo_lider"]:
		assert_bool((load(CRIATURAS % id) as DefinicionCriatura).inconsciente_a_cero).is_true()
	for id: String in ["eco_fallido", "esqueleto_guardia", "muerto_viviente_prueba"]:
		assert_bool((load(CRIATURAS % id) as DefinicionCriatura).inconsciente_a_cero).is_false()


func test_esqueleto_segun_el_monster_core() -> void:
	var esqueleto: DefinicionCriatura = load(CRIATURAS % "esqueleto_guardia")
	assert_int(esqueleto.nivel).is_equal(-1)
	assert_int(esqueleto.ca).is_equal(16)
	assert_int(esqueleto.pg).is_equal(4)
	assert_bool(esqueleto.inmune_mental).is_true()
	for tipo: DefinicionArma.TipoDanio in [DefinicionArma.TipoDanio.CORTANTE, DefinicionArma.TipoDanio.PERFORANTE,
			DefinicionArma.TipoDanio.FUEGO, DefinicionArma.TipoDanio.FRIO, DefinicionArma.TipoDanio.ELECTRICIDAD]:
		assert_int(esqueleto.resistencias.get(tipo, 0)).is_equal(5)
	assert_int(esqueleto.resistencias.get(DefinicionArma.TipoDanio.CONTUNDENTE, 0)).is_equal(0)

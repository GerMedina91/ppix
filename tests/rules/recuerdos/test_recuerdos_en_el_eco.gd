extends GdUnitTestSuite
## Los recuerdos integrados se suman al Eco al armarlo; Duro de matar sube el umbral de muerte a moribundo 5.

const GUERRERO: String = "res://data/builds/guerrero.tres"
const DURO: String = "res://data/capacidades/duro_de_matar.tres"


func _recuerdo_de(beneficio: BeneficioRecuerdo) -> DefinicionRecuerdo:
	var r: DefinicionRecuerdo = DefinicionRecuerdo.new()
	r.id = &"prueba"
	r.beneficio = beneficio
	return r


func test_armar_con_recuerdos_suma_sus_beneficios() -> void:
	var medicina: BeneficioHabilidad = BeneficioHabilidad.new()
	medicina.habilidad = Habilidad.Tipo.MEDICINA
	var duro: BeneficioDote = BeneficioDote.new()
	duro.dote = load(DURO)
	var recuerdos: Array[DefinicionRecuerdo] = [_recuerdo_de(medicina), _recuerdo_de(duro)]
	var sin: DefinicionPersonaje = ArmadorPersonaje.armar(load(GUERRERO))
	var con: DefinicionPersonaje = ArmadorPersonaje.armar(load(GUERRERO), recuerdos)
	assert_bool(sin.habilidades.has(Habilidad.Tipo.MEDICINA)).is_false()
	assert_int(con.habilidades[Habilidad.Tipo.MEDICINA]).is_equal(Competencia.Rango.ENTRENADO)
	assert_bool(con.capacidades.has(load(DURO))).is_true()
	assert_int(con.capacidades.size()).is_equal(sin.capacidades.size() + 1)


func test_con_duro_de_matar_se_muere_con_moribundo_5() -> void:
	var duro: BeneficioDote = BeneficioDote.new()
	duro.dote = load(DURO)
	var recuerdos: Array[DefinicionRecuerdo] = [_recuerdo_de(duro)]
	var eco: Combatiente = Combatiente.desde_personaje(&"eco", ArmadorPersonaje.armar(load(GUERRERO), recuerdos), Vector2i.ZERO)
	var otro: Combatiente = Combatiente.desde_personaje(&"otro", ArmadorPersonaje.armar(load(GUERRERO)), Vector2i.ZERO)
	assert_int(eco.umbral_de_muerte()).is_equal(5)
	assert_int(otro.umbral_de_muerte()).is_equal(4)
	for c: Combatiente in [eco, otro]:
		c.recibir_danio(c.pg, true)  # crítico: moribundo 2
		c.recibir_danio(1, true)     # moribundo 4
	assert_bool(otro.condiciones.muerto).is_true()
	assert_bool(eco.condiciones.muerto).is_false()
	eco.recibir_danio(1, false)      # moribundo 5
	assert_bool(eco.condiciones.muerto).is_true()

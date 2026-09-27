extends GdUnitTestSuite
## Ficha del combatiente bajo el cursor: condiciones de cualquiera; PG solo de la party.

const CAC: String = "res://data/personajes/party_prueba_cuerpo_a_cuerpo.tres"
const ENEMIGO: String = "res://data/criaturas/enemigo_prueba_cuerpo_a_cuerpo.tres"


func test_la_ficha_de_un_enemigo_muestra_condiciones_sin_pg() -> void:
	var e: Combatiente = Combatiente.desde_criatura(&"e", load(ENEMIGO), Vector2i.ZERO)
	assert_str(FichaCombatiente.ficha(e)).is_equal("e\nsin condiciones")
	e.condiciones.aplicar(EfectoCondicion.new(Condiciones.Tipo.ASUSTADO, 2))
	e.condiciones.aplicar(EfectoCondicion.new(Condiciones.Tipo.DEBILITADO, 1))
	assert_str(FichaCombatiente.ficha(e)).is_equal("e\nasustado 2, debilitado 1")


func test_la_ficha_de_la_party_muestra_pg() -> void:
	var pj: Combatiente = Combatiente.desde_personaje(&"pj", load(CAC), Vector2i.ZERO)
	pj.pg -= 3
	assert_str(FichaCombatiente.ficha(pj)).is_equal("pj\nPG %d/%d\nsin condiciones" % [pj.pg, pj.pg_maximos()])

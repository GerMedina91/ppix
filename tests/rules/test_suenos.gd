extends GdUnitTestSuite
## Sueños al descansar: llegan en orden y cada uno una sola vez.

const CATALOGO: String = "res://data/suenos/catalogo_suenos.tres"


func test_el_proximo_es_el_primero_sin_ver() -> void:
	var catalogo: CatalogoSuenos = load(CATALOGO)
	var vistos: Array[StringName] = []
	assert_str(catalogo.proximo(vistos).id).is_equal("sueno_placeholder_1")
	vistos.append(&"sueno_placeholder_1")
	assert_str(catalogo.proximo(vistos).id).is_equal("sueno_placeholder_2")
	vistos.append(&"sueno_placeholder_2")
	assert_object(catalogo.proximo(vistos)).is_null()

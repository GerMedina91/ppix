extends GdUnitTestSuite
## Descanso en un punto estable: recupera todo menos a los muertos.


func test_recupera_a_los_vivos_y_deja_a_los_muertos() -> void:
	var estado: Dictionary[StringName, Dictionary] = {
		&"herido": {"pg": 3, "herido": 2, "muerto": false, "conjuros": {"espacios": [0]}, "inmune_medicina": [&"eco"]},
		&"caido": {"pg": 0, "herido": 1},
		&"muerto": {"pg": 0, "herido": 1, "muerto": true},
	}
	Descanso.descansar(estado)
	assert_array(estado.keys()).contains_exactly([&"muerto"])
	assert_bool(estado[&"muerto"].muerto).is_true()


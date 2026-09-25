extends GdUnitTestSuite
## Moribundo, herido e inconsciente (reglas completas para personajes) y muerte de criaturas a 0 PG.

const DadosFijos: GDScript = preload("res://tests/utiles/dados_fijos.gd")
const CAC: String = "res://data/personajes/party_prueba_cuerpo_a_cuerpo.tres"
const ENEMIGO: String = "res://data/criaturas/enemigo_prueba_cuerpo_a_cuerpo.tres"


func _personaje() -> Combatiente:
	return Combatiente.desde_personaje(&"pj", load(CAC), Vector2i.ZERO)


func test_personaje_a_0_pg_queda_moribundo_1_e_inconsciente() -> void:
	var c: Combatiente = _personaje()
	c.recibir_danio(c.pg, false)
	assert_int(c.pg).is_equal(0)
	assert_int(c.condiciones.moribundo).is_equal(1)
	assert_bool(c.condiciones.inconsciente).is_true()
	assert_bool(c.condiciones.muerto).is_false()


func test_caer_por_critico_da_moribundo_2() -> void:
	var c: Combatiente = _personaje()
	c.recibir_danio(c.pg + 10, true)
	assert_int(c.condiciones.moribundo).is_equal(2)


func test_herido_se_suma_al_caer() -> void:
	var c: Combatiente = _personaje()
	c.condiciones.herido = 1
	c.recibir_danio(c.pg, false)
	assert_int(c.condiciones.moribundo).is_equal(2)


func test_danio_estando_moribundo_sube_1_o_2_con_critico() -> void:
	var c: Combatiente = _personaje()
	c.recibir_danio(c.pg, false)
	c.recibir_danio(3, false)
	assert_int(c.condiciones.moribundo).is_equal(2)
	c.recibir_danio(3, true)
	assert_int(c.condiciones.moribundo).is_equal(4)
	assert_bool(c.condiciones.muerto).is_true()


func test_recuperacion_segun_grado(tirada: int, moribundo_inicial: int, moribundo_final: int, test_parameters := [
		[20, 1, 0],   # 20 natural: éxito crítico, -2
		[15, 1, 0],   # 15 contra CD 11: éxito, -1
		[5, 1, 2],    # fallo, +1
		[1, 1, 3],    # 1 natural: fallo crítico, +2
		[12, 2, 1],   # 12 contra CD 12: éxito
		[11, 2, 3],   # 11 contra CD 12: fallo
	]) -> void:
	var c: Combatiente = _personaje()
	c.condiciones.herido = moribundo_inicial - 1
	c.recibir_danio(c.pg, false)
	assert_int(c.condiciones.moribundo).is_equal(moribundo_inicial)
	var resultado: ResultadoPrueba = c.prueba_de_recuperacion(DadosFijos.new([tirada]))
	assert_int(resultado.cd).is_equal(10 + moribundo_inicial)
	assert_int(c.condiciones.moribundo).is_equal(moribundo_final)


func test_perder_moribundo_por_recuperacion_sube_herido_y_sigue_inconsciente() -> void:
	var c: Combatiente = _personaje()
	c.recibir_danio(c.pg, false)
	c.prueba_de_recuperacion(DadosFijos.new([15]))
	assert_int(c.condiciones.moribundo).is_equal(0)
	assert_int(c.condiciones.herido).is_equal(1)
	assert_bool(c.condiciones.inconsciente).is_true()
	assert_int(c.pg).is_equal(0)


func test_moribundo_4_por_recuperacion_muere() -> void:
	var c: Combatiente = _personaje()
	c.condiciones.herido = 2
	c.recibir_danio(c.pg, false)  # moribundo 3
	c.prueba_de_recuperacion(DadosFijos.new([1]))  # fallo crítico, +2
	assert_bool(c.condiciones.muerto).is_true()


func test_curar_a_un_moribundo_lo_despierta_y_sube_herido() -> void:
	var c: Combatiente = _personaje()
	c.recibir_danio(c.pg, false)
	c.curar(5)
	assert_int(c.pg).is_equal(5)
	assert_int(c.condiciones.moribundo).is_equal(0)
	assert_int(c.condiciones.herido).is_equal(1)
	assert_bool(c.condiciones.inconsciente).is_false()
	assert_bool(c.condiciones.puede_actuar()).is_true()


func test_curar_no_supera_el_maximo_ni_revive_muertos() -> void:
	var c: Combatiente = _personaje()
	c.recibir_danio(3, false)
	c.curar(100)
	assert_int(c.pg).is_equal(c.pg_maximos())
	c.condiciones.muerto = true
	c.pg = 0
	c.curar(10)
	assert_int(c.pg).is_equal(0)


func test_danio_a_0_pg_estable_vuelve_a_moribundo() -> void:
	var c: Combatiente = _personaje()
	c.recibir_danio(c.pg, false)
	c.prueba_de_recuperacion(DadosFijos.new([15]))  # estable, herido 1
	c.recibir_danio(2, false)
	assert_int(c.condiciones.moribundo).is_equal(2)  # 1 + herido 1


func test_criatura_muere_a_0_pg() -> void:
	var e: Combatiente = Combatiente.desde_criatura(&"e", load(ENEMIGO), Vector2i.ZERO)
	e.recibir_danio(e.pg, false)
	assert_bool(e.condiciones.muerto).is_true()
	assert_int(e.condiciones.moribundo).is_equal(0)
	assert_object(e.prueba_de_recuperacion(DadosFijos.new([10]))).is_null()


func test_inconsciente_queda_desprevenido_y_con_menos_4_de_estatus() -> void:
	var c: Combatiente = _personaje()
	var ca_normal: int = c.defensa_contra(false).cd()
	c.recibir_danio(c.pg, false)
	assert_int(c.defensa_contra(false).cd()).is_equal(ca_normal - 2 - 4)


func test_inconsciente_menos_4_a_percepcion_y_reflejos_pero_no_a_fortaleza_ni_voluntad() -> void:
	var c: Combatiente = _personaje()
	var antes: Dictionary = {
		"percepcion": c.prueba_percepcion().modificador_total(),
		"reflejos": c.prueba_salvacion(Estadisticas.Salvacion.REFLEJOS).modificador_total(),
		"fortaleza": c.prueba_salvacion(Estadisticas.Salvacion.FORTALEZA).modificador_total(),
		"voluntad": c.prueba_salvacion(Estadisticas.Salvacion.VOLUNTAD).modificador_total(),
	}
	c.recibir_danio(c.pg, false)
	assert_int(c.prueba_percepcion().modificador_total()).is_equal(antes.percepcion - 4)
	assert_int(c.prueba_salvacion(Estadisticas.Salvacion.REFLEJOS).modificador_total()).is_equal(antes.reflejos - 4)
	assert_int(c.prueba_salvacion(Estadisticas.Salvacion.FORTALEZA).modificador_total()).is_equal(antes.fortaleza)
	assert_int(c.prueba_salvacion(Estadisticas.Salvacion.VOLUNTAD).modificador_total()).is_equal(antes.voluntad)


func test_restaurar_por_completo_limpia_todo() -> void:
	var c: Combatiente = _personaje()
	c.condiciones.herido = 1
	c.recibir_danio(c.pg, false)
	c.restaurar_por_completo()
	assert_int(c.pg).is_equal(c.pg_maximos())
	assert_int(c.condiciones.moribundo).is_equal(0)
	assert_int(c.condiciones.herido).is_equal(0)
	assert_bool(c.condiciones.inconsciente).is_false()

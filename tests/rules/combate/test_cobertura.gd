extends GdUnitTestSuite
## Cobertura (Player Core p. 424) y Tomar cobertura (p. 418): menor por criaturas, normal por paredes, mayor
## con Tomar cobertura; bonificador de circunstancia a la CA del Golpe y del ataque de conjuro.

const DadosFijos: GDScript = preload("res://tests/utiles/dados_fijos.gd")
const DIST: String = "res://data/personajes/party_prueba_distancia.tres"
const ENEMIGO: String = "res://data/criaturas/enemigo_prueba_cuerpo_a_cuerpo.tres"


## '#' pared. El personaje a distancia en (0,1) empieza; enemigo en `celda_enemigo`; `otros` en el medio.
func _combate(filas: Array[String], celda_enemigo: Vector2i, dados: Array = [], otros: Array[Combatiente] = []) -> Combate:
	var grilla: GrillaMapa = GrillaMapa.new(Rect2i(0, 0, filas[0].length(), filas.size()))
	for y in filas.size():
		for x in filas[y].length():
			grilla.set_transitable(Vector2i(x, y), filas[y][x] == ".")
	var participantes: Array[Combatiente] = [Combatiente.desde_personaje(&"pj", load(DIST), Vector2i(0, 1)),
		Combatiente.desde_criatura(&"e", load(ENEMIGO), celda_enemigo)]
	participantes.append_array(otros)
	var iniciativa: Array = [15, 1]
	for o in otros:
		iniciativa.append(1)
	var combate: Combate = Combate.new(participantes, grilla, DadosFijos.new(iniciativa + dados))
	combate.iniciar()
	assert_str(combate.turno_actual().id).is_equal("pj")
	return combate


func _nivel(combate: Combate) -> Cobertura.Nivel:
	return Cobertura.de(combate.combatiente(&"pj"), combate.combatiente(&"e"), combate.participantes, combate.vision())


func test_una_pared_en_la_recta_da_cobertura_normal() -> void:
	var combate: Combate = _combate(["......", "...#..", "......"], Vector2i(5, 1))
	assert_int(_nivel(combate)).is_equal(Cobertura.Nivel.NORMAL)


func test_una_criatura_en_la_recta_da_cobertura_menor() -> void:
	var aliado: Combatiente = Combatiente.desde_criatura(&"otro", load(ENEMIGO), Vector2i(3, 1))
	var combate: Combate = _combate(["......", "......", "......"], Vector2i(5, 1), [], [aliado])
	assert_int(_nivel(combate)).is_equal(Cobertura.Nivel.MENOR)


func test_en_campo_abierto_no_hay_cobertura() -> void:
	var combate: Combate = _combate(["......", "......", "......"], Vector2i(5, 1))
	assert_int(_nivel(combate)).is_equal(Cobertura.Nivel.NINGUNA)


func test_la_cobertura_suma_a_la_ca_del_golpe_y_sale_en_el_registro() -> void:
	# Enemigo CA 16 + 2 (normal) = 18.
	var combate: Combate = _combate(["......", "...#..", "......"], Vector2i(5, 1), [10, 3])
	var eventos: Array[EventoCombate] = combate.golpe(&"e")
	var resultado: ResultadoGolpe = eventos[0].datos.resultado
	assert_int(resultado.cobertura).is_equal(Cobertura.Nivel.NORMAL)
	assert_int(resultado.prueba.cd).is_equal(18)
	assert_str(FormatoRegistro.texto(eventos[0], combate)).contains("contra CA 18 (cobertura normal +2)")


func test_tomar_cobertura_pasa_de_normal_a_mayor_y_termina_al_moverse() -> void:
	# El enemigo, junto a la pared, toma cobertura: frente al personaje pasa de normal a mayor (+4).
	var combate: Combate = _combate(["......", "...#..", "......"], Vector2i(4, 1))
	combate.terminar_turno()
	assert_str(combate.turno_actual().id).is_equal("e")
	var eventos: Array[EventoCombate] = combate.especiales.tomar_cobertura()
	assert_str(FormatoRegistro.texto(eventos[0], combate)).is_equal("e usa Tomar cobertura")
	assert_int(_nivel(combate)).is_equal(Cobertura.Nivel.MAYOR)
	assert_str(combate.especiales.motivo_tomar_cobertura_imposible(combate.turno_actual())).is_equal("ya está a cubierto")
	combate.paso(Vector2i(5, 2))
	assert_bool(combate.combatiente(&"e").tomando_cobertura).is_false()


func test_tomar_cobertura_sin_cobertura_da_normal_y_sin_pared_no_se_puede() -> void:
	var combate: Combate = _combate(["......", "......", ".....#"], Vector2i(5, 1))
	combate.terminar_turno()
	combate.especiales.tomar_cobertura()  # junto a la pared de (5,2), pero sin cobertura frente al personaje
	assert_int(_nivel(combate)).is_equal(Cobertura.Nivel.NORMAL)
	var abierto: Combate = _combate(["......", "......", "......"], Vector2i(4, 1))  # (el borde del mapa cuenta como pared)
	abierto.terminar_turno()
	assert_str(abierto.especiales.motivo_tomar_cobertura_imposible(abierto.turno_actual())).is_equal("no hay dónde cubrirse")


func test_la_cobertura_suma_a_la_ca_del_ataque_de_conjuro() -> void:
	# Bruja con Proyectil telequinético (ataque de conjuro) detrás de una pared en la recta: CA 16 + 2 = 18.
	var grilla: GrillaMapa = GrillaMapa.new(Rect2i(0, 0, 6, 3))
	for x in 6:
		for y in 3:
			grilla.set_transitable(Vector2i(x, y), not (x == 3 and y == 1))
	var participantes: Array[Combatiente] = [
		Combatiente.desde_personaje(&"bruja", ArmadorPersonaje.armar(load("res://data/builds/bruja.tres")), Vector2i(0, 1)),
		Combatiente.desde_criatura(&"e", load(ENEMIGO), Vector2i(5, 1))]
	var combate: Combate = Combate.new(participantes, grilla, DadosFijos.new([15, 1, 10, 3]))
	combate.iniciar()
	var eventos: Array[EventoCombate] = combate.lanzar_conjuro(load("res://data/conjuros/proyectil_telequinetico.tres"), &"e")
	var efecto: EventoCombate = eventos.filter(func(e: EventoCombate) -> bool: return e.tipo == EventoCombate.Tipo.EFECTO_CONJURO)[0]
	assert_int(efecto.datos.cobertura).is_equal(Cobertura.Nivel.NORMAL)
	assert_int((efecto.datos.resultado as ResultadoPrueba).cd).is_equal(18)
	assert_str(FormatoRegistro.texto(efecto, combate)).contains("contra CA 18 (cobertura normal +2)")

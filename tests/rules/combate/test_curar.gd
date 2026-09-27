extends GdUnitTestSuite
## Curar de 1 a 3 acciones (Player Core p. 335; docs/verificacion/c5_curar.md), fuente divina del clérigo,
## emanación y muertos vivientes. Clérigo: CD de conjuro 17. Enemigo de prueba: Fortaleza +8, 20 PG.

const DadosFijos: GDScript = preload("res://tests/utiles/dados_fijos.gd")
const CLERIGO: String = "res://data/builds/clerigo.tres"
const BRUJA: String = "res://data/builds/bruja.tres"
const ENEMIGO: String = "res://data/criaturas/enemigo_prueba_cuerpo_a_cuerpo.tres"
const CURAR: String = "res://data/conjuros/curar.tres"
const EFECTO: EventoCombate.Tipo = EventoCombate.Tipo.EFECTO_CONJURO
const INVALIDA: EventoCombate.Tipo = EventoCombate.Tipo.ACCION_INVALIDA


func _grilla() -> GrillaMapa:
	var grilla: GrillaMapa = GrillaMapa.new(Rect2i(0, 0, 20, 10))
	for x in 20:
		for y in 10:
			grilla.set_transitable(Vector2i(x, y), true)
	return grilla


func _pj(id: StringName, build: String, celda: Vector2i) -> Combatiente:
	return Combatiente.desde_personaje(id, ArmadorPersonaje.armar(load(build)), celda)


## Clérigo en (2,2) (empieza), bruja aliada en `celda_aliada`, enemigo en `celda_enemigo`.
func _combate(dados: Array, celda_aliada: Vector2i = Vector2i(3, 2), celda_enemigo: Vector2i = Vector2i(8, 2),
		enemigo: DefinicionCriatura = null) -> Combate:
	var criatura: DefinicionCriatura = enemigo if enemigo != null else load(ENEMIGO)
	var participantes: Array[Combatiente] = [_pj(&"clerigo", CLERIGO, Vector2i(2, 2)), _pj(&"aliada", BRUJA, celda_aliada),
		Combatiente.desde_criatura(&"e", criatura, celda_enemigo)]
	var combate: Combate = Combate.new(participantes, _grilla(), DadosFijos.new([15, 1, 5] + dados))
	combate.iniciar()
	assert_str(combate.turno_actual().id).is_equal("clerigo")
	return combate


func _efectos(eventos: Array[EventoCombate]) -> Array[EventoCombate]:
	var lista: Array[EventoCombate] = []
	for e: EventoCombate in eventos:
		if e.tipo == EFECTO:
			lista.append(e)
	return lista


func test_la_fuente_divina_da_4_curar_ademas_de_los_espacios() -> void:
	var clerigo: DefinicionPersonaje = ArmadorPersonaje.armar(load(CLERIGO))
	assert_int(clerigo.conjuros_preparados.filter(func(c: DefinicionConjuro) -> bool: return c.id == &"curar").size()).is_equal(4)
	assert_int(clerigo.conjuros_preparados.filter(func(c: DefinicionConjuro) -> bool: return c.id == &"miedo").size()).is_equal(2)
	var bruja: DefinicionPersonaje = ArmadorPersonaje.armar(load(BRUJA))
	assert_bool(bruja.conjuros_preparados.any(func(c: DefinicionConjuro) -> bool: return c.id == &"curar")).is_false()


func test_una_accion_toca_a_un_aliado_adyacente() -> void:
	var combate: Combate = _combate([5])
	var aliada: Combatiente = combate.combatiente(&"aliada")
	aliada.pg -= 10
	var eventos: Array[EventoCombate] = combate.lanzar_conjuro(load(CURAR), &"aliada", AccionesConjuro.SIN_CELDA, [], false, 1)
	assert_int(_efectos(eventos)[0].datos.curacion).is_equal(5)
	assert_int(aliada.pg).is_equal(aliada.pg_maximos() - 5)
	assert_int(combate.turno_actual().acciones_restantes).is_equal(2)
	assert_int(combate.turno_actual().conjuros.restantes(load(CURAR))).is_equal(3)


func test_el_toque_no_llega_lejos_pero_2_acciones_si_y_suman_8() -> void:
	var combate: Combate = _combate([3], Vector2i(6, 2))  # aliada a 20 pies
	var aliada: Combatiente = combate.combatiente(&"aliada")
	aliada.pg = 1
	var toque: Array[EventoCombate] = combate.lanzar_conjuro(load(CURAR), &"aliada", AccionesConjuro.SIN_CELDA, [], false, 1)
	assert_str(toque[0].datos.motivo).is_equal("fuera de alcance")
	var eventos: Array[EventoCombate] = combate.lanzar_conjuro(load(CURAR), &"aliada", AccionesConjuro.SIN_CELDA, [], false, 2)
	assert_int(_efectos(eventos)[0].datos.curacion).is_equal(11)  # 3 + 8
	assert_int(combate.turno_actual().acciones_restantes).is_equal(1)


func test_no_cura_a_un_enemigo_vivo_con_objetivo_unico() -> void:
	var combate: Combate = _combate([], Vector2i(3, 2), Vector2i(3, 3))
	var eventos: Array[EventoCombate] = combate.lanzar_conjuro(load(CURAR), &"e", AccionesConjuro.SIN_CELDA, [], false, 1)
	assert_str(eventos[0].datos.motivo).is_equal("solo aliados o muertos vivientes")


func test_sin_elegir_acciones_o_sin_acciones_suficientes_es_imposible() -> void:
	var combate: Combate = _combate([])
	assert_str(combate.lanzar_conjuro(load(CURAR), &"aliada")[0].datos.motivo).is_equal("elegí cuántas acciones")
	combate.turno_actual().gastar_acciones(2)
	assert_int(combate.lanzar_conjuro(load(CURAR), &"", AccionesConjuro.SIN_CELDA, [], false, 3)[0].tipo).is_equal(INVALIDA)
	assert_int(combate.turno_actual().conjuros.restantes(load(CURAR))).is_equal(4)


func test_tres_acciones_curan_a_todos_los_vivos_en_la_emanacion_con_una_sola_tirada() -> void:
	# Aliada a 5 pies, enemigo a 30 (dentro): los dos se curan 4 (una sola tirada); también el clérigo.
	var combate: Combate = _combate([4], Vector2i(3, 2), Vector2i(8, 2))
	for c: Combatiente in combate.participantes:
		c.pg -= 6
	var eventos: Array[EventoCombate] = combate.lanzar_conjuro(load(CURAR), &"", AccionesConjuro.SIN_CELDA, [], false, 3)
	var curados: Dictionary = {}
	for e: EventoCombate in _efectos(eventos):
		curados[e.datos.objetivo] = e.datos.curacion
	assert_dict(curados).is_equal({&"clerigo": 4, &"aliada": 4, &"e": 4})
	assert_int(combate.turno_actual().acciones_restantes).is_equal(0)


func test_la_emanacion_no_llega_mas_alla_de_30_pies() -> void:
	var combate: Combate = _combate([4], Vector2i(3, 2), Vector2i(9, 2))  # enemigo a 35 pies
	combate.combatiente(&"e").pg -= 6
	var eventos: Array[EventoCombate] = combate.lanzar_conjuro(load(CURAR), &"", AccionesConjuro.SIN_CELDA, [], false, 3)
	assert_bool(_efectos(eventos).any(func(e: EventoCombate) -> bool: return e.datos.objetivo == &"e")).is_false()


func test_curar_a_un_moribundo_lo_levanta() -> void:
	var combate: Combate = _combate([6])
	var aliada: Combatiente = combate.combatiente(&"aliada")
	aliada.recibir_danio(aliada.pg, false)
	var efecto: EventoCombate = _efectos(combate.lanzar_conjuro(load(CURAR), &"aliada", AccionesConjuro.SIN_CELDA, [], false, 1))[0]
	assert_bool(efecto.datos.levanta).is_true()
	assert_bool(aliada.condiciones.en_pie()).is_true()
	assert_int(aliada.condiciones.herido).is_equal(1)
	assert_str(FormatoRegistro.texto(efecto, combate)).is_equal("aliada recupera 6 PG y se levanta")


func test_a_un_muerto_viviente_le_hace_dano_de_vitalidad_con_fortaleza_basica() -> void:
	# Fortaleza +8 contra CD 17: 2 = 10 fallo, daño completo (1d8 = 6; sin el +8, que es solo para curar).
	var muerto: DefinicionCriatura = (load(ENEMIGO) as DefinicionCriatura).duplicate()
	muerto.rasgo = RasgoCriatura.Tipo.MUERTO_VIVIENTE
	var combate: Combate = _combate([6, 2], Vector2i(3, 2), Vector2i(6, 2), muerto)
	var efecto: EventoCombate = _efectos(combate.lanzar_conjuro(load(CURAR), &"e", AccionesConjuro.SIN_CELDA, [], false, 2))[0]
	assert_int(efecto.datos.danio).is_equal(6)
	assert_int(combate.combatiente(&"e").pg).is_equal(14)
	assert_str(FormatoRegistro.texto(efecto, combate)).ends_with("6 de daño de vitalidad")


func test_la_forma_de_2_y_3_acciones_tiene_concentrar() -> void:
	var curar: DefinicionConjuro = load(CURAR)
	assert_bool(curar.rasgos_con(1).has(DefinicionConjuro.Rasgo.CONCENTRAR)).is_false()
	assert_bool(curar.rasgos_con(2).has(DefinicionConjuro.Rasgo.CONCENTRAR)).is_true()
	assert_bool(curar.rasgos_con(3).has(DefinicionConjuro.Rasgo.CONCENTRAR)).is_true()


func test_el_modo_de_accion_pide_las_acciones_y_confirma_la_emanacion() -> void:
	var combate: Combate = _combate([4])
	var clerigo: Combatiente = combate.turno_actual()
	var modo: ModoAccion = ModoAccion.new()
	var opciones: Array[Dictionary] = ModoAccion.opciones(combate, clerigo)
	var indice: int = opciones.find_custom(func(o: Dictionary) -> bool: return o.get("conjuro") == load(CURAR))
	assert_str(opciones[indice].texto).is_equal("Curar ◆–◆◆◆ (4)")
	modo.elegir(combate, clerigo, indice)
	assert_bool(modo.pide_acciones()).is_true()
	assert_str(modo.texto(combate, clerigo)).is_equal(
		"Curar: 1 ◆ toque · 2 ◆◆ 30 pies (+8) · 3 ◆◆◆ emanación de 30 pies · Esc cancela")
	modo.elegir(combate, clerigo, 2)
	assert_bool(modo.es_area()).is_true()
	assert_array(modo.casillas_area(combate, clerigo)).contains([clerigo.celda, Vector2i(8, 2)])
	var eventos: Array[EventoCombate] = modo.al_click(combate, clerigo, clerigo.celda, false).call()
	assert_int(eventos[0].tipo).is_equal(EventoCombate.Tipo.LANZAMIENTO)
	assert_str(FormatoRegistro.texto(eventos[0], combate)).is_equal("clerigo lanza Curar (◆◆◆)")


func test_el_clerigo_puede_excluirse_de_su_emanacion() -> void:
	var combate: Combate = _combate([4])
	for c: Combatiente in combate.participantes:
		c.pg -= 6
	var pedido: PedidoConjuro = PedidoConjuro.new(load(CURAR), &"", 3)
	pedido.excluir_lanzador = true
	var curados: Array = _efectos(combate.lanzar_pedido(pedido)).map(func(e: EventoCombate) -> StringName: return e.datos.objetivo)
	assert_array(curados).not_contains([&"clerigo"])
	assert_array(curados).contains([&"aliada", &"e"])

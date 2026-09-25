extends GdUnitTestSuite
## Motor de lanzamiento (docs/verificacion/c4_conjuros.md): Mal de ojo, Debilitar, Pies ágiles, Sostener,
## un maleficio por turno, espacios y foco, Golpe reactivo ante manipular e interrupción por crítico.
## Bruja: Int +4, CD de conjuro 17, Percepción +5. Enemigo de prueba: Fortaleza +8, Voluntad +5, Percepción +6.

const DadosFijos: GDScript = preload("res://tests/utiles/dados_fijos.gd")
const BRUJA: String = "res://data/builds/bruja.tres"
const CLERIGO: String = "res://data/builds/clerigo.tres"
const GUERRERO: String = "res://data/builds/guerrero.tres"
const ENEMIGO: String = "res://data/criaturas/enemigo_prueba_cuerpo_a_cuerpo.tres"
const OJO: String = "res://data/conjuros/mal_de_ojo.tres"
const DEBILITAR: String = "res://data/conjuros/debilitar.tres"
const PIES: String = "res://data/conjuros/pies_agiles.tres"
const I: Condiciones.Tipo = Condiciones.Tipo.INDISPUESTO
const D: Condiciones.Tipo = Condiciones.Tipo.DEBILITADO
const T: Dictionary = {
	"LANZA": EventoCombate.Tipo.LANZAMIENTO, "EFECTO": EventoCombate.Tipo.EFECTO_CONJURO,
	"FALLIDO": EventoCombate.Tipo.CONJURO_FALLIDO, "COND": EventoCombate.Tipo.CONDICION,
	"INVALIDA": EventoCombate.Tipo.ACCION_INVALIDA, "FIN_CONJURO": EventoCombate.Tipo.FIN_CONJURO,
	"SOSTENER": EventoCombate.Tipo.SOSTENER, "GOLPE": EventoCombate.Tipo.GOLPE, "REACCION": EventoCombate.Tipo.REACCION,
	"MOV": EventoCombate.Tipo.MOVIMIENTO,
}


func _grilla() -> GrillaMapa:
	var grilla: GrillaMapa = GrillaMapa.new(Rect2i(0, 0, 14, 12))
	for x in 14:
		for y in 12:
			grilla.set_transitable(Vector2i(x, y), true)
	return grilla


func _personaje(id: StringName, build: String, celda: Vector2i, bando: Combatiente.Bando = Combatiente.Bando.PARTY) -> Combatiente:
	return Combatiente.new(id, FuentePersonaje.new(ArmadorPersonaje.armar(load(build))), bando, celda)


## La bruja (o el build pedido) empieza: d20 15 contra 5.
func _combate(dados_extra: Array = [], build: String = BRUJA, otro: Combatiente = null) -> Combate:
	var enemigo: Combatiente = otro if otro != null else Combatiente.desde_criatura(&"e", load(ENEMIGO), Vector2i(5, 2))
	var participantes: Array[Combatiente] = [_personaje(&"pj", build, Vector2i(2, 2)), enemigo]
	var combate: Combate = Combate.new(participantes, _grilla(), DadosFijos.new([15, 5] + dados_extra))
	combate.iniciar()
	assert_str(combate.turno_actual().id).is_equal("pj")
	return combate


func _tipos(eventos: Array[EventoCombate]) -> Array:
	return eventos.map(func(e: EventoCombate) -> EventoCombate.Tipo: return e.tipo)


# --- Mal de ojo ---

func test_mal_de_ojo_segun_la_voluntad() -> void:
	# Voluntad +5 contra CD 17: 2 = 7 fallo crítico; 8 = 13 fallo; 15 = 20 éxito.
	for caso: Array in [[2, 2], [8, 1], [15, 0]]:
		var combate: Combate = _combate([caso[0]])
		var eventos: Array[EventoCombate] = combate.lanzar_conjuro(load(OJO), &"e")
		assert_array(_tipos(eventos).slice(0, 2)).is_equal([T.LANZA, T.EFECTO])
		assert_int(combate.combatiente(&"e").condiciones.valor(I)).override_failure_message("d20 %d" % caso[0]).is_equal(caso[1])
		assert_int(combate.turno_actual().acciones_restantes).is_equal(2)
		assert_int(combate.conjuros.sostenidos.size()).is_equal(1 if caso[1] > 0 else 0)


func test_la_cd_del_indispuesto_es_la_cd_de_conjuro() -> void:
	var combate: Combate = _combate([8])
	combate.lanzar_conjuro(load(OJO), &"e")
	assert_int(combate.combatiente(&"e").condiciones.principal(I).cd).is_equal(17)


func test_un_segundo_maleficio_en_el_turno_falla_y_pierde_las_acciones() -> void:
	var combate: Combate = _combate([15])
	combate.lanzar_conjuro(load(OJO), &"e")
	var eventos: Array[EventoCombate] = combate.lanzar_conjuro(load(OJO), &"e")
	assert_array(_tipos(eventos)).is_equal([T.LANZA, T.FALLIDO])
	assert_int(combate.turno_actual().acciones_restantes).is_equal(1)


func test_fuera_de_alcance_o_sin_objetivo_es_imposible_y_no_gasta() -> void:
	var lejos: Combatiente = Combatiente.desde_criatura(&"e", load(ENEMIGO), Vector2i(13, 2))  # 55 pies
	var combate: Combate = _combate([], BRUJA, lejos)
	assert_array(_tipos(combate.lanzar_conjuro(load(OJO), &"e"))).is_equal([T.INVALIDA])
	assert_array(_tipos(combate.lanzar_conjuro(load(OJO), &"nadie"))).is_equal([T.INVALIDA])
	assert_int(combate.turno_actual().acciones_restantes).is_equal(3)


# --- Sostener ---

func test_sin_sostener_termina_al_final_del_proximo_turno_y_suelta_el_piso() -> void:
	# Fallo (indispuesto 1). Arcadas del enemigo con 20 (crítico): el piso lo deja en 1.
	var combate: Combate = _combate([8, 20])
	combate.lanzar_conjuro(load(OJO), &"e")
	var e: Combatiente = combate.combatiente(&"e")
	combate.terminar_turno()  # el turno del lanzamiento cuenta como sostenido
	assert_int(combate.conjuros.sostenidos.size()).is_equal(1)
	combate.arcadas()
	assert_int(e.condiciones.valor(I)).is_equal(1)
	combate.terminar_turno()
	var eventos: Array[EventoCombate] = combate.terminar_turno()  # la bruja no lo sostuvo
	assert_array(_tipos(eventos)).contains([T.FIN_CONJURO])
	assert_int(combate.conjuros.sostenidos.size()).is_equal(0)
	assert_int(e.condiciones.piso(I)).is_equal(0)
	assert_int(e.condiciones.valor(I)).is_equal(1)  # el indispuesto queda; ya se puede bajar


func test_sostener_lo_extiende_un_turno_mas() -> void:
	var combate: Combate = _combate([8])
	combate.lanzar_conjuro(load(OJO), &"e")
	combate.terminar_turno()
	combate.terminar_turno()
	assert_array(_tipos(combate.sostener())).is_equal([T.SOSTENER])
	assert_array(_tipos(combate.sostener())).is_equal([T.INVALIDA])  # ya lo sostuvo en este turno
	assert_array(_tipos(combate.terminar_turno())).not_contains([T.FIN_CONJURO])
	assert_int(combate.conjuros.sostenidos.size()).is_equal(1)


func test_sostener_sin_nada_sostenido_es_imposible() -> void:
	var combate: Combate = _combate()
	assert_array(_tipos(combate.sostener())).is_equal([T.INVALIDA])
	assert_int(combate.turno_actual().acciones_restantes).is_equal(3)


func test_sin_linea_de_vision_el_piso_no_vale() -> void:
	var combate: Combate = _combate([8])
	combate.lanzar_conjuro(load(OJO), &"e")
	var e: Combatiente = combate.combatiente(&"e")
	assert_int(e.condiciones.piso(I)).is_equal(1)
	combate.grilla().set_transitable(Vector2i(3, 2), false)
	combate.grilla().set_transitable(Vector2i(4, 2), false)
	combate.conjuros.actualizar_pisos()
	assert_int(e.condiciones.piso(I)).is_equal(0)


# --- Debilitar ---

func test_debilitar_segun_la_fortaleza_y_gasta_el_espacio() -> void:
	# Fortaleza +8 contra CD 17: 10 = 18 éxito (debilitado 1); 5 = 13 fallo (debilitado 2).
	for caso: Array in [[10, 1], [5, 2]]:
		var combate: Combate = _combate([caso[0]])
		var bruja: Combatiente = combate.turno_actual()
		assert_int(bruja.conjuros.restantes(load(DEBILITAR))).is_equal(1)
		combate.lanzar_conjuro(load(DEBILITAR), &"e")
		assert_int(combate.combatiente(&"e").condiciones.valor(D)).is_equal(caso[1])
		assert_int(bruja.acciones_restantes).is_equal(1)
		assert_int(bruja.conjuros.restantes(load(DEBILITAR))).is_equal(0)


func test_sin_espacios_no_se_puede_lanzar() -> void:
	var combate: Combate = _combate([10])
	combate.lanzar_conjuro(load(DEBILITAR), &"e")
	combate.terminar_turno()
	combate.terminar_turno()
	var eventos: Array[EventoCombate] = combate.lanzar_conjuro(load(DEBILITAR), &"e")
	assert_array(_tipos(eventos)).is_equal([T.INVALIDA])
	assert_str(eventos[0].datos.motivo).is_equal("sin espacios")


func test_debilitar_con_exito_dura_hasta_el_inicio_del_proximo_turno_de_la_bruja() -> void:
	var combate: Combate = _combate([10])
	combate.lanzar_conjuro(load(DEBILITAR), &"e")
	var e: Combatiente = combate.combatiente(&"e")
	combate.terminar_turno()
	assert_int(e.condiciones.valor(D)).is_equal(1)
	combate.terminar_turno()
	assert_bool(e.condiciones.tiene(D)).is_false()


# --- Pies ágiles ---

func test_pies_agiles_suma_5_pies_y_permite_una_zancada_en_el_lanzamiento() -> void:
	var combate: Combate = _combate([], CLERIGO)
	var clerigo: Combatiente = combate.turno_actual()
	var velocidad: int = clerigo.velocidad_pies()
	var destino: Vector2i = clerigo.celda + Vector2i(0, (velocidad + 5) / Medicion.PIES_POR_CASILLA)
	var eventos: Array[EventoCombate] = combate.lanzar_conjuro(load(PIES), &"", destino)
	assert_array(_tipos(eventos)).is_equal([T.LANZA, T.EFECTO, T.MOV])
	assert_that(clerigo.celda).is_equal(destino)
	assert_int(clerigo.acciones_restantes).is_equal(2)
	assert_int(clerigo.velocidad_pies()).is_equal(velocidad + 5)
	assert_int(clerigo.conjuros.foco).is_equal(0)
	combate.terminar_turno()
	assert_int(clerigo.velocidad_pies()).is_equal(velocidad)


func test_pies_agiles_sin_puntos_de_foco_es_imposible() -> void:
	var combate: Combate = _combate([], CLERIGO)
	combate.lanzar_conjuro(load(PIES))
	var eventos: Array[EventoCombate] = combate.lanzar_conjuro(load(PIES))
	assert_str(eventos[0].datos.motivo).is_equal("sin puntos de foco")


func test_pies_agiles_no_llega_mas_alla_de_la_velocidad_con_el_bonificador() -> void:
	var combate: Combate = _combate([], CLERIGO)
	var clerigo: Combatiente = combate.turno_actual()
	var lejos: Vector2i = clerigo.celda + Vector2i(0, (clerigo.velocidad_pies() + 10) / Medicion.PIES_POR_CASILLA)
	assert_array(_tipos(combate.lanzar_conjuro(load(PIES), &"", lejos))).is_equal([T.INVALIDA])
	assert_int(clerigo.conjuros.foco).is_equal(1)


# --- Golpe reactivo ante manipular ---

## Guerrero enemigo pegado a la bruja, con la reacción disponible (antes de su primer turno la decide el
## DJ, Player Core p. 436; el motor hoy no la da).
func _guerrero_enemigo_al_lado() -> Combatiente:
	var guerrero: Combatiente = _personaje(&"g", GUERRERO, Vector2i(3, 2), Combatiente.Bando.ENEMIGOS)
	guerrero.reaccion_disponible = true
	return guerrero


func test_el_golpe_reactivo_con_critico_interrumpe_el_conjuro() -> void:
	# Golpe reactivo: 20 natural (crítico), espadón 1 → (1 + 4) × 2 = 10. El espacio se pierde.
	var combate: Combate = _combate([20, 1], BRUJA, _guerrero_enemigo_al_lado())
	var bruja: Combatiente = combate.turno_actual()
	var eventos: Array[EventoCombate] = combate.lanzar_conjuro(load(DEBILITAR), &"g")
	assert_array(_tipos(eventos)).is_equal([T.LANZA, T.REACCION, T.GOLPE, T.FALLIDO])
	assert_str(eventos.back().datos.motivo).is_equal("interrumpido")
	assert_int(bruja.conjuros.restantes(load(DEBILITAR))).is_equal(0)
	assert_bool(combate.combatiente(&"g").condiciones.tiene(D)).is_false()


func test_el_golpe_reactivo_sin_critico_no_interrumpe() -> void:
	# Golpe: 10 + 9 = 19 contra CA 15, acierta (1 + 4 = 5). Fortaleza del guerrero +7: 2 = 9, fallo.
	var combate: Combate = _combate([10, 1, 2], BRUJA, _guerrero_enemigo_al_lado())
	var eventos: Array[EventoCombate] = combate.lanzar_conjuro(load(DEBILITAR), &"g")
	assert_array(_tipos(eventos).slice(0, 4)).is_equal([T.LANZA, T.REACCION, T.GOLPE, T.EFECTO])
	assert_int(combate.combatiente(&"g").condiciones.valor(D)).is_equal(2)


# --- Otras reglas ---

func test_huyendo_no_puede_lanzar() -> void:
	var combate: Combate = _combate()
	combate.turno_actual().condiciones.aplicar(EfectoCondicion.new(Condiciones.Tipo.HUYENDO, 1, 0, &"e"))
	assert_array(_tipos(combate.lanzar_conjuro(load(OJO), &"e"))).is_equal([T.INVALIDA])


func test_la_ia_indispuesta_que_no_puede_golpear_usa_arcadas() -> void:
	# El enemigo está lejos (50 pies): no llega a golpear este turno. Arcadas: 20 → crítico.
	var lejos: Combatiente = Combatiente.desde_criatura(&"e", load(ENEMIGO), Vector2i(12, 2))
	var combate: Combate = _combate([20], BRUJA, lejos)
	combate.terminar_turno()
	lejos.condiciones.aplicar(EfectoCondicion.new(I, 2, 17))
	var eventos: Array[EventoCombate] = IASimple.jugar_accion(combate)
	assert_array(_tipos(eventos)).is_equal([EventoCombate.Tipo.ARCADAS])
	assert_bool(lejos.condiciones.tiene(I)).is_false()


func test_la_ia_indispuesta_que_puede_golpear_golpea() -> void:
	var combate: Combate = _combate([2])  # enemigo a 15 pies: Zancada y Golpe
	combate.terminar_turno()
	combate.combatiente(&"e").condiciones.aplicar(EfectoCondicion.new(I, 1, 17))
	assert_array(_tipos(IASimple.jugar_accion(combate))).not_contains([EventoCombate.Tipo.ARCADAS])


func test_lo_gastado_se_guarda_y_se_restaura() -> void:
	var combate: Combate = _combate([10])
	var bruja: Combatiente = combate.turno_actual()
	combate.lanzar_conjuro(load(DEBILITAR), &"e")
	var otra: Combatiente = _personaje(&"pj", BRUJA, Vector2i.ZERO)
	otra.conjuros.aplicar_estado(bruja.conjuros.estado())
	assert_int(otra.conjuros.restantes(load(DEBILITAR))).is_equal(0)
	otra.restaurar_por_completo()
	assert_int(otra.conjuros.restantes(load(DEBILITAR))).is_equal(1)

extends GdUnitTestSuite
## Mapas del slice (M5; estructura en docs/lore/slice.md): encuentros con el presupuesto decidido, el reparto de
## recuerdos sin tocar el balance de M4e, las Lumbres y los recorridos obligados (no se llega a lo que está detrás
## de un encuentro sin pasar por su zona).

const MAPA: String = "res://scenes/world/mapas/%s.tscn"
const MAPAS: Array[String] = ["kardel", "linde_del_monte", "corazon_del_monte"]


func _mapa(id: String) -> Mapa:
	var mapa: Mapa = auto_free((load(MAPA % id) as PackedScene).instantiate())
	add_child(mapa)
	return mapa


func _encuentro(mapa: Mapa, id: StringName) -> Encuentro:
	for encuentro: Encuentro in mapa.encuentros():
		if encuentro.id == id:
			return encuentro
	return null


func _xp(encuentro: Encuentro) -> int:
	var criaturas: Array[DefinicionCriatura] = []
	for enemigo: EnemigoEnMapa in encuentro.enemigos():
		criaturas.append(enemigo.definicion)
	return PresupuestoEncuentro.xp_total(criaturas, 1)


func _objeto(mapa: Mapa, nombre: String) -> Interactuable:
	for objeto: Interactuable in mapa.interactuables():
		if objeto.name == nombre:
			return objeto
	return null


## Grilla del mapa sin las casillas de las zonas de sus encuentros (y con los enemigos como obstáculos).
func _grilla_sin_zonas(mapa: Mapa) -> GrillaMapa:
	var grilla: GrillaMapa = mapa.construir_grilla()
	for encuentro: Encuentro in mapa.encuentros():
		for enemigo: EnemigoEnMapa in encuentro.enemigos():
			grilla.set_transitable(enemigo.celda, false)
		for zona: DisparadorEncuentro in encuentro.disparadores():
			var rect: Rect2i = zona.get("zona")
			for x in range(rect.position.x, rect.end.x):
				for y in range(rect.position.y, rect.end.y):
					grilla.set_transitable(Vector2i(x, y), false)
	return grilla


func _salida(mapa: Mapa, nombre: String) -> Vector2i:
	return mapa.posicion_a_celda((mapa.get_node("Salidas/" + nombre) as Node2D).global_position)


func test_encuentros_con_el_presupuesto_decidido() -> void:
	var linde: Mapa = _mapa("linde_del_monte")
	var corazon: Mapa = _mapa("corazon_del_monte")
	assert_int(_xp(_encuentro(linde, &"encuentro_linde"))).is_equal(80)
	assert_int(_xp(_encuentro(corazon, &"encuentro_muertos"))).is_equal(80)
	assert_int(_xp(_encuentro(corazon, &"encuentro_final"))).is_equal(120)
	assert_array(_mapa("kardel").encuentros()).is_empty()


func test_reparto_de_recuerdos_con_el_balance_de_m4e() -> void:
	var ids: Array[String] = []
	var vendible: int = 0
	for id: String in MAPAS:
		var mapa: Mapa = _mapa(id)
		var recuerdos: Array[DefinicionRecuerdo] = []
		for objeto: Interactuable in mapa.interactuables():
			if objeto is ObjetoRecuerdo:
				recuerdos.append((objeto as ObjetoRecuerdo).recuerdo)
		for encuentro: Encuentro in mapa.encuentros():
			for enemigo: EnemigoEnMapa in encuentro.enemigos():
				if enemigo.recuerdo_extraible() != null:
					recuerdos.append(enemigo.recuerdo_extraible())
		for recuerdo: DefinicionRecuerdo in recuerdos:
			ids.append(String(recuerdo.id))
			if recuerdo.vendible():
				vendible += recuerdo.valor
	ids.sort()
	assert_array(ids).is_equal(["destreza_duro_de_matar", "destreza_medicina", "destreza_sigilo", "doliente_2",
		"vivencia_2", "vivencia_3", "vivencia_4"])
	assert_int(vendible).is_equal(110)


func test_lumbres_en_kardel_y_al_final_del_linde() -> void:
	var kardel: Mapa = _mapa("kardel")
	assert_str(String((_objeto(kardel, "LumbreFarol") as PuntoEstable).id)).is_equal("lumbre_kardel")
	var linde: Mapa = _mapa("linde_del_monte")
	var lumbre: PuntoEstable = _objeto(linde, "LumbreLinde")
	assert_str(String(lumbre.id)).is_equal("lumbre_linde")
	# Justo antes de la salida al corazón, después del encuentro.
	assert_int(Medicion.pies_entre(lumbre.celda, _salida(linde, "Salida_corazon_del_monte"))).is_less_equal(25)
	var corazon: Mapa = _mapa("corazon_del_monte")
	assert_bool(corazon.interactuables().any(func(o: Interactuable) -> bool: return o is PuntoEstable)).is_false()


func test_en_el_linde_no_se_llega_al_corazon_sin_pasar_por_el_combate() -> void:
	var linde: Mapa = _mapa("linde_del_monte")
	var entrada: Vector2i = linde.celda_de_entrada(&"desde_kardel")
	var salida: Vector2i = _salida(linde, "Salida_corazon_del_monte")
	assert_array(linde.construir_grilla().camino(entrada, salida)).is_not_empty()
	assert_array(_grilla_sin_zonas(linde).camino(entrada, salida)).is_empty()
	# El sendero que vuelve sobre sí mismo se alcanza sin pelear.
	assert_array(_grilla_sin_zonas(linde).camino(entrada, _salida(linde, "Salida_sendero_que_vuelve"))).is_not_empty()


func test_en_el_corazon_el_fragmento_esta_detras_de_los_dos_combates() -> void:
	var corazon: Mapa = _mapa("corazon_del_monte")
	var entrada: Vector2i = corazon.celda_de_entrada(&"desde_linde")
	var fragmento: ObjetoRecuerdo = _objeto(corazon, "FragmentoDoliente2")
	assert_bool(fragmento.cierra_el_slice).is_true()
	assert_object(corazon.construir_grilla().celda_junto_a(entrada, fragmento.celda)).is_not_null()
	var sin_zonas: GrillaMapa = _grilla_sin_zonas(corazon)
	assert_object(sin_zonas.celda_junto_a(entrada, fragmento.celda)).is_null()
	assert_object(sin_zonas.celda_junto_a(entrada, _objeto(corazon, "RecuerdoSigilo").celda)).is_null()


func test_kardel_todo_alcanzable_desde_el_camino() -> void:
	var kardel: Mapa = _mapa("kardel")
	var grilla: GrillaMapa = kardel.construir_grilla()
	var entrada: Vector2i = kardel.celda_de_entrada(&"camino")
	for objeto: Interactuable in kardel.interactuables():
		assert_object(grilla.celda_junto_a(entrada, objeto.celda)).override_failure_message(objeto.name).is_not_null()
	assert_array(grilla.camino(entrada, _salida(kardel, "Salida_linde_del_monte"))).is_not_empty()


func test_el_juego_empieza_en_kardel() -> void:
	var mundo: PackedScene = load("res://scenes/world/mundo.tscn")
	var estado: SceneState = mundo.get_state()
	var valores: Dictionary = {}
	for i in estado.get_node_property_count(0):
		valores[estado.get_node_property_name(0, i)] = estado.get_node_property_value(0, i)
	assert_str(String(valores.id_mapa_inicial)).is_equal("kardel")
	assert_str(String(valores.id_entrada_inicial)).is_equal("camino")

extends GdUnitTestSuite
## Pared de prueba: bloque de 64×32 con 64 px de cara, base en (0, 0).
## Su rect de textura sería x -32..32, y -80..16; la silueta es el hexágono dentro de ese rect.

const TILE: Vector2 = Vector2(64, 32)
const ALTO: float = 64.0

var _silueta: PackedVector2Array = OclusionParedes.silueta_bloque(Vector2.ZERO, TILE, ALTO)


func _rect_actor(base: Vector2) -> Rect2:
	return Rect2(base + Vector2(-16, -56), Vector2(32, 56))


func test_silueta_es_el_hexagono_del_bloque() -> void:
	assert_array(Array(_silueta)).is_equal([
		Vector2(0, -80), Vector2(32, -64), Vector2(32, 0), Vector2(0, 16), Vector2(-32, 0), Vector2(-32, -64)])


func test_actor_detras_y_superpuesto_queda_tapado() -> void:
	var base: Vector2 = Vector2(0, -32)  # celda justo detrás
	assert_bool(OclusionParedes.tapa(_silueta, 0.0, _rect_actor(base), base.y)).is_true()


func test_actor_delante_no_queda_tapado_aunque_se_superponga() -> void:
	var base: Vector2 = Vector2(0, 32)
	assert_bool(OclusionParedes.tapa(_silueta, 0.0, _rect_actor(base), base.y)).is_false()


func test_actor_al_costado_a_la_misma_altura_no_queda_tapado() -> void:
	var base: Vector2 = Vector2(64, 0)
	assert_bool(OclusionParedes.tapa(_silueta, 0.0, _rect_actor(base), base.y)).is_false()


func test_esquina_vacia_de_la_textura_no_cuenta() -> void:
	# El actor roza la esquina superior derecha del rect de la textura (x 20..32, y -80..-78),
	# que está vacía: la silueta ahí empieza recién en y ≈ -70.
	var base: Vector2 = Vector2(36, -78)
	var rect: Rect2 = _rect_actor(base)
	assert_bool(Rect2(-32, -80, 64, 96).intersects(rect)).override_failure_message("el caso tiene que tocar el rect").is_true()
	assert_bool(OclusionParedes.tapa(_silueta, 0.0, rect, base.y)).is_false()


func test_actor_lejos_no_queda_tapado() -> void:
	var base: Vector2 = Vector2(300, -32)
	assert_bool(OclusionParedes.tapa(_silueta, 0.0, _rect_actor(base), base.y)).is_false()

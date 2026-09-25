extends GdUnitTestSuite

const RECT_ACTOR: Rect2 = Rect2(100, 44, 32, 56)
const BASE_ACTOR: float = 100.0


func test_pared_delante_y_superpuesta_tapa() -> void:
	assert_bool(OclusionParedes.tapa(Rect2(90, 30, 64, 96), 110.0, RECT_ACTOR, BASE_ACTOR)).is_true()


func test_pared_detras_no_tapa_aunque_se_superponga() -> void:
	assert_bool(OclusionParedes.tapa(Rect2(90, 0, 64, 96), 80.0, RECT_ACTOR, BASE_ACTOR)).is_false()


func test_pared_delante_pero_sin_superponerse_no_tapa() -> void:
	assert_bool(OclusionParedes.tapa(Rect2(300, 30, 64, 96), 110.0, RECT_ACTOR, BASE_ACTOR)).is_false()


func test_misma_base_no_tapa() -> void:
	assert_bool(OclusionParedes.tapa(Rect2(90, 30, 64, 96), BASE_ACTOR, RECT_ACTOR, BASE_ACTOR)).is_false()

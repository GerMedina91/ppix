extends GdUnitTestSuite

const VISIBLE: Vector2 = Vector2(640, 360)


func test_mapa_mas_grande_usa_sus_bordes() -> void:
	var mapa: Rect2 = Rect2(0, 0, 1024, 640)
	assert_that(CamaraMundo.limites_para(mapa, VISIBLE)).is_equal(mapa)


func test_mapa_mas_angosto_se_centra_en_x() -> void:
	var limites: Rect2 = CamaraMundo.limites_para(Rect2(0, 0, 320, 640), VISIBLE)
	assert_that(limites).is_equal(Rect2(-160, 0, 640, 640))


func test_mapa_mas_bajo_se_centra_en_y() -> void:
	var limites: Rect2 = CamaraMundo.limites_para(Rect2(0, 0, 1024, 160), VISIBLE)
	assert_that(limites).is_equal(Rect2(0, -100, 1024, 360))

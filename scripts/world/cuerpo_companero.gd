class_name CuerpoCompanero
extends Interactuable
## Cuerpo de un compañero muerto (muerte permanente, GDD 4.3): queda en la casilla donde cayó. En M4e el Eco
## podrá extraerle sus recuerdos. Placeholder: el color del miembro, oscuro y tendido.

const TAMANO_TENDIDO: Vector2 = Vector2(40, 14)
const OSCURECER: float = 0.55

var id_miembro: StringName = &""


func _draw() -> void:
	draw_rect(Rect2(Vector2(-TAMANO_TENDIDO.x / 2.0, -TAMANO_TENDIDO.y), TAMANO_TENDIDO), color_placeholder.darkened(OSCURECER))

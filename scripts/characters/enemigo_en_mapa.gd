class_name EnemigoEnMapa
extends ActorMapa
## Enemigo colocado en el mapa como parte de un Encuentro. Su casilla sale de su posición.

const COLOR_BORDE: Color = Color(0.1, 0.05, 0.05)

@export var definicion: DefinicionCriatura


func _draw() -> void:
	super()
	draw_rect(Rect2(_origen_placeholder(), TAMANO_PLACEHOLDER), COLOR_BORDE, false, 1.0)

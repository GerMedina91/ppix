class_name EntradaMapa
extends Marker2D
## Punto donde aparece la party al entrar al mapa. Se ubica en el centro de una celda.

@export var id: StringName = &""
## Casillas de formación, en orden (líder primero), cada una vecina de la anterior.
## Vacío = se calcula sola desde la entrada, alejándose de las salidas (ver Formacion).
@export var formacion: Array[Vector2i] = []

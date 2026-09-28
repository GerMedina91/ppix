@tool
class_name EntradaMapa
extends Marker2D
## Punto donde aparece la party al entrar al mapa. Se ubica en el centro de una celda (en el editor se
## acomoda sola).

@export var id: StringName = &"":
	set(valor):
		id = valor
		update_configuration_warnings()
## Casillas de formación, en orden (líder primero), cada una vecina de la anterior.
## Vacío = se calcula sola desde la entrada, alejándose de las salidas (ver Formacion).
@export var formacion: Array[Vector2i] = []

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		set_notify_transform(true)


func _notification(que: int) -> void:
	if que == NOTIFICATION_TRANSFORM_CHANGED and Engine.is_editor_hint():
		ValidacionMapa.centrar(self)
		update_configuration_warnings()



func _get_configuration_warnings() -> PackedStringArray:
	return ValidacionMapa.avisos_de_casilla(self) + ValidacionMapa.avisos_de_id(self, id, "la entrada")

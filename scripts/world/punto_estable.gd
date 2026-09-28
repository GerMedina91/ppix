@tool
class_name PuntoEstable
extends Interactuable
## Punto estable (GDD 4.3): lugar donde la Convergencia no deforma la realidad. Al interactuar se abre su
## panel: descansar recupera a la party, lo registra como punto de reaparición del Eco y guarda.

## Único en todo el mundo (GameState guarda el último usado).
@export var id: StringName = &"":
	set(valor):
		id = valor
		update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
	return super() + ValidacionMapa.avisos_de_id(self, id, "punto estable")

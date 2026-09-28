@tool
class_name ObjetoRecuerdo
extends Interactuable
## Objeto del mapa con un recuerdo (GDD 4.2: fuente "encontrar en el mundo"). Al interactuar, el Eco lo toma
## (suelto) y el objeto desaparece para siempre (GameState.mundo; el nombre del nodo es su id en el mapa).

@export var recuerdo: DefinicionRecuerdo:
	set(valor):
		recuerdo = valor
		update_configuration_warnings()
## Al tomarlo termina el vertical slice (el fragmento 2 del Doliente, en el corazón del Monte).
@export var cierra_el_slice: bool = false


func _get_configuration_warnings() -> PackedStringArray:
	var avisos: PackedStringArray = super()
	if recuerdo == null:
		avisos.append("Falta el recuerdo.")
	elif not ValidacionMapa.recuerdo_catalogado(recuerdo):
		avisos.append("El recuerdo '%s' no está en data/recuerdos/catalogo_recuerdos.tres (el guardado no lo encontraría)." % recuerdo.get("id"))
	return avisos

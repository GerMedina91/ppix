class_name CatalogoRecuerdos
extends Resource
## Todos los recuerdos del juego, para resolver ids al cargar una partida guardada.

@export var recuerdos: Array[DefinicionRecuerdo] = []


func buscar(id: StringName) -> DefinicionRecuerdo:
	for recuerdo: DefinicionRecuerdo in recuerdos:
		if recuerdo.id == id:
			return recuerdo
	return null

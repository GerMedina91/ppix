class_name CatalogoMapas
extends Resource
## Lista de todos los mapas del mundo, para resolver un id de mapa a su definición.

@export var mapas: Array[DefinicionMapa] = []


## Devuelve la definición con ese id, o null si no existe.
func buscar(id: StringName) -> DefinicionMapa:
	for definicion: DefinicionMapa in mapas:
		if definicion.id == id:
			return definicion
	return null

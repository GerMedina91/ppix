class_name CatalogoSuenos
extends Resource
## Sueños del juego, en el orden en que llegan. Cada uno se ve una sola vez (GameState.suenos_vistos).

@export var suenos: Array[DefinicionSueno] = []


## El primer sueño que todavía no se vio, o null si ya se vieron todos.
func proximo(vistos: Array[StringName]) -> DefinicionSueno:
	for sueno: DefinicionSueno in suenos:
		if not vistos.has(sueno.id):
			return sueno
	return null

class_name Descanso
extends RefCounted
## Descanso en un punto estable (M4c; verificado en docs/verificacion/m4_recuerdos.md). Simplificación del
## descanso de 8 horas y los preparativos diarios (Player Core p. 439): PG completos, espacios de conjuro y
## puntos de foco recuperados, herido fuera (con PG completos y descanso, p. 447) y fin de la inmunidad a la
## Medicina en batalla (dura un día). Los muertos siguen muertos.


## Aplica el descanso al estado persistente de la party (GameState.estado_party: id -> estado). Sin entrada
## = PG completos, sin herido y con todo recuperado; los muertos conservan la suya.
static func descansar(estado_party: Dictionary[StringName, Dictionary]) -> void:
	for id: StringName in estado_party.keys():
		if not estado_party[id].get("muerto", false):
			estado_party.erase(id)

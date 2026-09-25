class_name Competencia
extends RefCounted
## Rangos de competencia y su bonificador (Remaster):
## no entrenado +0 (sin sumar el nivel); entrenado nivel + 2; experto nivel + 4;
## maestro nivel + 6; legendario nivel + 8.

enum Rango { NO_ENTRENADO, ENTRENADO, EXPERTO, MAESTRO, LEGENDARIO }

## Bonificador fijo que se suma al nivel en cada rango.
const BONIFICADOR_POR_RANGO: Dictionary[Rango, int] = {
	Rango.NO_ENTRENADO: 0,
	Rango.ENTRENADO: 2,
	Rango.EXPERTO: 4,
	Rango.MAESTRO: 6,
	Rango.LEGENDARIO: 8,
}

const _NOMBRES: Dictionary[Rango, String] = {
	Rango.NO_ENTRENADO: "no entrenado",
	Rango.ENTRENADO: "entrenado",
	Rango.EXPERTO: "experto",
	Rango.MAESTRO: "maestro",
	Rango.LEGENDARIO: "legendario",
}


static func bonificador(rango: Rango, nivel: int) -> int:
	if rango == Rango.NO_ENTRENADO:
		return 0
	return nivel + BONIFICADOR_POR_RANGO[rango]


static func nombre(rango: Rango) -> String:
	return _NOMBRES[rango]

class_name Posicionamiento
extends RefCounted
## Posicionamiento previo al combate (decisión del director, 2026-09-28): antes de tirar iniciativa, cada miembro
## de la party puede moverse hasta 10 pies desde donde estaba al dispararse el encuentro. No es una regla de
## PF2e: representa el instante antes de notarse; la iniciativa (Percepción) no depende de la posición. Sin
## sorpresa en el slice (docs/verificacion/cobertura.md). Sin estado.
## Casillas posibles: a 10 pies o menos caminando por la grilla (diagonales 5/10, sin cortar esquinas, sin pasar
## por otras criaturas), pisables, libres y no al lado de un enemigo.

const RADIO_PIES: int = 10
const _PIES_DIAGONAL: Array[int] = [5, 10]


## `origen`: donde estaba el miembro; `ocupadas`: casillas de las demás criaturas (y el propio miembro puede
## volver a su origen aunque esté ahí); `enemigos`: sus casillas.
static func casillas_posibles(grilla: GrillaMapa, origen: Vector2i, ocupadas: Dictionary[Vector2i, bool],
		enemigos: Array[Vector2i]) -> Array[Vector2i]:
	# Búsqueda por costo con la paridad de diagonales (la segunda diagonal cuesta 10).
	var mejor: Dictionary = {[origen, 0]: 0}
	var pendientes: Array = [[origen, 0, 0]]
	var alcanzadas: Dictionary[Vector2i, bool] = {origen: true}
	while not pendientes.is_empty():
		var actual: Array = pendientes.pop_front()
		var celda: Vector2i = actual[0]
		for dx in [-1, 0, 1]:
			for dy in [-1, 0, 1]:
				var paso: Vector2i = Vector2i(dx, dy)
				if paso == Vector2i.ZERO or not grilla.puede_dar_paso(celda, celda + paso) or ocupadas.has(celda + paso):
					continue
				var diagonal: bool = dx != 0 and dy != 0
				var costo: int = actual[2] + (_PIES_DIAGONAL[actual[1]] if diagonal else Medicion.PIES_POR_CASILLA)
				var paridad: int = (actual[1] + 1) % 2 if diagonal else actual[1]
				if costo > RADIO_PIES or mejor.get([celda + paso, paridad], RADIO_PIES + 1) <= costo:
					continue
				mejor[[celda + paso, paridad]] = costo
				alcanzadas[celda + paso] = true
				pendientes.append([celda + paso, paridad, costo])
	var lista: Array[Vector2i] = []
	for casilla: Vector2i in alcanzadas:
		if not _junto_a_enemigo(casilla, enemigos):
			lista.append(casilla)
	lista.sort()
	return lista


static func _junto_a_enemigo(casilla: Vector2i, enemigos: Array[Vector2i]) -> bool:
	return enemigos.any(func(e: Vector2i) -> bool: return absi(e.x - casilla.x) <= 1 and absi(e.y - casilla.y) <= 1)

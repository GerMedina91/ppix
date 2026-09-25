class_name Formacion
extends RefCounted
## Posiciones de la party al entrar a un mapa: una cadena de casillas donde cada una es vecina de la
## anterior (así la fila india arranca desplegada y cada seguidor da pasos válidos).
## Se arma desde la entrada, alejándose de las casillas a evitar (p. ej. salidas).

const _VECINAS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
	Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1),
]


## Cadena de hasta `cantidad` casillas empezando por `entrada`. Si no entran todas, devuelve las que
## pudo; quien arma la party repite la última para el resto.
static func cadena(grilla: GrillaMapa, entrada: Vector2i, cantidad: int, evitar: Array[Vector2i]) -> Array[Vector2i]:
	var direccion: Vector2 = _direccion_de_alejamiento(entrada, evitar)
	var mejor: Array[Vector2i] = [entrada]
	var camino: Array[Vector2i] = [entrada]
	_buscar(grilla, camino, cantidad, evitar, direccion, mejor)
	return mejor


static func _buscar(grilla: GrillaMapa, camino: Array[Vector2i], cantidad: int, evitar: Array[Vector2i],
		direccion: Vector2, mejor: Array[Vector2i]) -> bool:
	if camino.size() > mejor.size():
		mejor.assign(camino)
	if camino.size() >= cantidad:
		return true
	var actual: Vector2i = camino.back()
	var vecinas: Array[Vector2i] = _VECINAS.duplicate()
	vecinas.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return Vector2(a).normalized().dot(direccion) > Vector2(b).normalized().dot(direccion))
	for vecina: Vector2i in vecinas:
		var siguiente: Vector2i = actual + vecina
		if camino.has(siguiente) or evitar.has(siguiente) or not grilla.puede_dar_paso(actual, siguiente):
			continue
		camino.append(siguiente)
		if _buscar(grilla, camino, cantidad, evitar, direccion, mejor):
			return true
		camino.pop_back()
	return false


static func _direccion_de_alejamiento(entrada: Vector2i, evitar: Array[Vector2i]) -> Vector2:
	var mas_cercana: Variant = null
	for casilla: Vector2i in evitar:
		if mas_cercana == null or (casilla - entrada).length_squared() < (mas_cercana - entrada).length_squared():
			mas_cercana = casilla
	if mas_cercana == null or mas_cercana == entrada:
		return Vector2.DOWN
	return Vector2(entrada - mas_cercana).normalized()

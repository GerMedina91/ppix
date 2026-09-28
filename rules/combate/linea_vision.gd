class_name LineaVision
extends RefCounted
## Línea de visión y cobertura entre casillas (Player Core p. 424; decisión del director: fiel a PF2e).
## - **Se puede apuntar** si algún segmento desde tu casilla (su centro o una esquina) hasta la del objetivo (su
##   centro o una esquina) no pasa por una pared: no cruza el interior de una casilla opaca, no corre por un
##   borde entre dos opacas y no toca un "pellizco" (vértice donde dos opacas se tocan en diagonal: no se ve
##   entre dos paredes que se tocan en diagonal).
## - **La cobertura** la decide la recta de centro a centro (recorrido "supercover": todas las casillas que toca):
##   si pasa por una pared, cobertura normal (ver Cobertura); si pasa por una criatura, menor.
## - Opacas: las casillas no transitables de la grilla (paredes) y las de fuera del mapa. Origen y destino nunca.
## Geometría exacta en coordenadas duplicadas: la casilla (x, y) ocupa [2x, 2x + 2] × [2y, 2y + 2].

const _EPSILON: float = 1e-9

var _grilla: GrillaMapa


func _init(grilla: GrillaMapa) -> void:
	_grilla = grilla


func hay_linea(desde: Vector2i, hasta: Vector2i) -> bool:
	if desde == hasta:
		return true
	var opacas: Array[Vector2i] = _opacas_entre(desde, hasta)
	if opacas.is_empty():
		return true
	var pellizcos: Array[Vector2i] = _pellizcos(desde, hasta)
	for origen: Vector2i in _puntos(desde):
		for destino: Vector2i in _puntos(hasta):
			if _segmento_libre(origen, destino, opacas, pellizcos):
				return true
	return false


## La recta de centro a centro pasa por una pared (o entre dos que se tocan en diagonal): cobertura normal.
func tapa_la_recta_central(desde: Vector2i, hasta: Vector2i) -> bool:
	return not _recorrer(desde, hasta).visible


## Casillas intermedias que toca la recta de centro a centro (sin origen ni destino): cobertura por criaturas
## y depuración.
func casillas_atravesadas(desde: Vector2i, hasta: Vector2i) -> Array[Vector2i]:
	return _recorrer(desde, hasta).casillas


func es_opaca(casilla: Vector2i) -> bool:
	return not _grilla.es_transitable(casilla)


## Centro primero (el caso más común), después las cuatro esquinas.
static func _puntos(celda: Vector2i) -> Array[Vector2i]:
	var base: Vector2i = celda * 2
	return [base + Vector2i(1, 1), base, base + Vector2i(2, 0), base + Vector2i(0, 2), base + Vector2i(2, 2)]


## Casillas opacas en el rectángulo que envuelve a las dos (sin contarlas a ellas).
func _opacas_entre(desde: Vector2i, hasta: Vector2i) -> Array[Vector2i]:
	var lista: Array[Vector2i] = []
	for x in range(mini(desde.x, hasta.x), maxi(desde.x, hasta.x) + 1):
		for y in range(mini(desde.y, hasta.y), maxi(desde.y, hasta.y) + 1):
			var celda: Vector2i = Vector2i(x, y)
			if celda != desde and celda != hasta and es_opaca(celda):
				lista.append(celda)
	return lista


## Vértices (en coordenadas duplicadas) donde dos casillas opacas se tocan en diagonal, en el rectángulo que
## envuelve a las dos ampliado una casilla (un pellizco del borde puede tener una de sus paredes afuera).
func _pellizcos(desde: Vector2i, hasta: Vector2i) -> Array[Vector2i]:
	var lista: Array[Vector2i] = []
	for x in range(mini(desde.x, hasta.x) - 1, maxi(desde.x, hasta.x) + 1):
		for y in range(mini(desde.y, hasta.y) - 1, maxi(desde.y, hasta.y) + 1):
			var celda: Vector2i = Vector2i(x, y)
			if es_opaca(celda):
				_sumar_pellizcos(celda, lista)
	return lista


func _sumar_pellizcos(celda: Vector2i, lista: Array[Vector2i]) -> void:
	for diagonal: Vector2i in [Vector2i(1, 1), Vector2i(-1, 1)]:
		if es_opaca(celda + diagonal):
			# Vértice compartido por `celda` y `celda + diagonal`.
			var vertice: Vector2i = (celda * 2) + Vector2i(2 if diagonal.x > 0 else 0, 2)
			if not lista.has(vertice):
				lista.append(vertice)


func _segmento_libre(a: Vector2i, b: Vector2i, opacas: Array[Vector2i], pellizcos: Array[Vector2i]) -> bool:
	for vertice: Vector2i in pellizcos:
		if _contiene_punto(a, b, vertice):
			return false
	for celda: Vector2i in opacas:
		if _cruza_interior(a, b, celda):
			return false
	return not _corre_entre_opacas(a, b)


## El punto está sobre el segmento (extremos incluidos). Enteros: exacto.
static func _contiene_punto(a: Vector2i, b: Vector2i, p: Vector2i) -> bool:
	var ab: Vector2i = b - a
	var ap: Vector2i = p - a
	if ab.x * ap.y - ab.y * ap.x != 0:
		return false
	var producto: int = ab.x * ap.x + ab.y * ap.y
	return producto >= 0 and producto <= ab.x * ab.x + ab.y * ab.y


## El segmento cruza el interior abierto de la casilla (Liang-Barsky; los tramos que solo tocan el borde
## tienen largo 0 y no cuentan).
static func _cruza_interior(a: Vector2i, b: Vector2i, celda: Vector2i) -> bool:
	var entrada: float = 0.0
	var salida: float = 1.0
	var d: Vector2i = b - a
	for eje in 2:
		var inicio: int = a[eje]
		var delta: int = d[eje]
		var minimo: int = celda[eje] * 2
		var maximo: int = minimo + 2
		if delta == 0:
			if inicio <= minimo or inicio >= maximo:
				return false
			continue
		var t1: float = float(minimo - inicio) / delta
		var t2: float = float(maximo - inicio) / delta
		entrada = maxf(entrada, minf(t1, t2))
		salida = minf(salida, maxf(t1, t2))
	return salida - entrada > _EPSILON


## El segmento corre por una línea de la grilla con casillas opacas a los dos lados en algún tramo.
func _corre_entre_opacas(a: Vector2i, b: Vector2i) -> bool:
	for eje in 2:
		var otro: int = 1 - eje
		if a[eje] != b[eje] or a[eje] % 2 != 0:
			continue
		var linea: int = a[eje] / 2
		var desde: int = mini(a[otro], b[otro])
		var hasta: int = maxi(a[otro], b[otro])
		for fila in range(floori(desde / 2.0), ceili(hasta / 2.0)):
			if fila * 2 + 2 <= desde or fila * 2 >= hasta:
				continue
			var lado_a: Vector2i = Vector2i.ZERO
			var lado_b: Vector2i = Vector2i.ZERO
			lado_a[eje] = linea - 1
			lado_b[eje] = linea
			lado_a[otro] = fila
			lado_b[otro] = fila
			if es_opaca(lado_a) and es_opaca(lado_b):
				return true
	return false


## Recta de centro a centro, casilla por casilla (supercover).
func _recorrer(desde: Vector2i, hasta: Vector2i) -> Dictionary:
	var casillas: Array[Vector2i] = []
	var visible: bool = true
	var dx: int = absi(hasta.x - desde.x)
	var dy: int = absi(hasta.y - desde.y)
	var paso: Vector2i = Vector2i(signi(hasta.x - desde.x), signi(hasta.y - desde.y))
	var actual: Vector2i = desde
	var avance_x: int = 0
	var avance_y: int = 0
	while avance_x < dx or avance_y < dy:
		var decision: int = (1 + 2 * avance_x) * dy - (1 + 2 * avance_y) * dx
		if decision == 0:
			# La recta pasa justo por la esquina: se mira a los dos costados.
			var lateral_x: Vector2i = actual + Vector2i(paso.x, 0)
			var lateral_y: Vector2i = actual + Vector2i(0, paso.y)
			if es_opaca(lateral_x) and es_opaca(lateral_y):
				visible = false
			actual += paso
			avance_x += 1
			avance_y += 1
		elif decision < 0:
			actual.x += paso.x
			avance_x += 1
		else:
			actual.y += paso.y
			avance_y += 1
		if actual != hasta:
			casillas.append(actual)
			if es_opaca(actual):
				visible = false
	return {"visible": visible, "casillas": casillas}

class_name MovimientoCombate
extends RefCounted
## Movimiento en combate con el costo de PF2e (diagonales alternadas 5/10 pies), calculado aparte
## del AStarGrid2D de exploración. Dijkstra sobre (casilla, paridad de diagonales hechas):
## la alternancia se cuenta a lo largo de todo el movimiento.
## - Paredes y esquinas: se respeta GrillaMapa.puede_dar_paso (no se cortan esquinas de paredes).
## - Casillas bloqueadas (enemigos): no se pueden atravesar.
## - Casillas de aliados: se pueden atravesar pero no se puede terminar ahí.
## Internamente cada estado es un entero: índice de casilla * 2 + paridad. Las vecinas de cada casilla
## se calculan una vez al crear el objeto (las paredes no cambian durante un combate).

const _SIN_LIMITE: int = 1 << 30
const _NINGUNO: int = -1
const _VECINAS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
	Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1),
]

var _grilla: GrillaMapa
var _region: Rect2i
## Por índice de casilla: vecinas a las que se puede dar un paso, como índice * 2 + (1 si es diagonal).
var _vecinas: Array[PackedInt32Array] = []


func _init(grilla: GrillaMapa) -> void:
	_grilla = grilla
	_region = grilla.region()
	_vecinas.resize(_region.get_area())
	for i in _vecinas.size():
		var celda: Vector2i = celda_de(i)
		var lista: PackedInt32Array = PackedInt32Array()
		for d: Vector2i in _VECINAS:
			if grilla.puede_dar_paso(celda, celda + d):
				lista.append(indice_de(celda + d) * 2 + (1 if d.x != 0 and d.y != 0 else 0))
		_vecinas[i] = lista


func indice_de(celda: Vector2i) -> int:
	var local: Vector2i = celda - _region.position
	return local.y * _region.size.x + local.x


func celda_de(indice: int) -> Vector2i:
	return _region.position + Vector2i(indice % _region.size.x, indice / _region.size.x)


## Casillas donde se puede terminar un movimiento de hasta `presupuesto_pies`, con su costo mínimo.
## No incluye el origen ni casillas de aliados.
func alcanzables(origen: Vector2i, presupuesto_pies: int, bloqueadas: Dictionary, de_aliados: Dictionary) -> Dictionary[Vector2i, int]:
	var resultado: Dictionary[Vector2i, int] = {}
	if not _region.has_point(origen):
		return resultado
	var busqueda: Dictionary = _buscar(PackedInt32Array([indice_de(origen)]), presupuesto_pies, bloqueadas)
	var costos: PackedInt32Array = busqueda.costos
	for estado: int in busqueda.orden as PackedInt32Array:
		var celda: Vector2i = celda_de(estado >> 1)
		# `orden` va de menor a mayor costo: el primer estado de cada casilla es el más barato.
		if celda != origen and not de_aliados.has(celda) and not resultado.has(celda):
			resultado[celda] = costos[estado]
	return resultado


## Alcance con hasta `zancadas_max` Zancadas. Cada Zancada es un movimiento aparte de hasta
## `velocidad_pies` (la alternancia de diagonales empieza de nuevo en cada una) y no puede terminar en
## casillas de aliados. Una sola búsqueda por Zancada: todas las casillas donde pudo terminar la
## anterior salen juntas (multi-origen, costo 0 y paridad 0).
func alcance_de_zancadas(origen: Vector2i, velocidad_pies: int, zancadas_max: int, bloqueadas: Dictionary, de_aliados: Dictionary) -> AlcanceZancadas:
	var alcance: AlcanceZancadas = AlcanceZancadas.new(self, origen)
	if not _region.has_point(origen):
		return alcance
	var frontera: PackedInt32Array = PackedInt32Array([indice_de(origen)])
	for n in range(1, zancadas_max + 1):
		if frontera.is_empty():
			break
		var busqueda: Dictionary = _buscar(frontera, velocidad_pies, bloqueadas)
		alcance.agregar_capa(busqueda.previos)
		var nueva: PackedInt32Array = PackedInt32Array()
		for estado: int in busqueda.orden as PackedInt32Array:
			var celda: Vector2i = celda_de(estado >> 1)
			if celda == origen or de_aliados.has(celda) or alcance.llega(celda):
				continue
			alcance.asignar(celda, n, estado)
			nueva.append(estado >> 1)
		frontera = nueva
	return alcance


## Camino más barato hasta `destino` (sin incluir el origen), o vacío si no se puede terminar ahí.
func camino(origen: Vector2i, destino: Vector2i, bloqueadas: Dictionary, de_aliados: Dictionary) -> Array[Vector2i]:
	var resultado: Array[Vector2i] = []
	if destino == origen or de_aliados.has(destino) or bloqueadas.has(destino) \
			or not _region.has_point(origen) or not _region.has_point(destino):
		return resultado
	var busqueda: Dictionary = _buscar(PackedInt32Array([indice_de(origen)]), _SIN_LIMITE, bloqueadas, indice_de(destino))
	if busqueda.llegada == _NINGUNO:
		return resultado
	return recorrido(busqueda.previos, busqueda.llegada)


## Casillas desde la raíz de la búsqueda (sin incluirla) hasta `estado`, siguiendo `previos`.
func recorrido(previos: PackedInt32Array, estado: int) -> Array[Vector2i]:
	var resultado: Array[Vector2i] = []
	var actual: int = estado
	while previos[actual] != _NINGUNO:
		resultado.append(celda_de(actual >> 1))
		actual = previos[actual]
	resultado.reverse()
	return resultado


## Raíz de la búsqueda de la que sale `estado` (la casilla donde empieza ese movimiento).
func raiz(previos: PackedInt32Array, estado: int) -> Vector2i:
	var actual: int = estado
	while previos[actual] != _NINGUNO:
		actual = previos[actual]
	return celda_de(actual >> 1)


## true si `casillas` es un movimiento posible desde `origen`: pasos a casillas vecinas sin cortar
## esquinas, sin atravesar oponentes y sin terminar en un aliado. No mira el costo.
func es_camino_valido(origen: Vector2i, casillas: Array[Vector2i], bloqueadas: Dictionary, de_aliados: Dictionary) -> bool:
	if casillas.is_empty() or de_aliados.has(casillas.back()):
		return false
	var anterior: Vector2i = origen
	for casilla: Vector2i in casillas:
		if bloqueadas.has(casilla) or not _grilla.puede_dar_paso(anterior, casilla):
			return false
		anterior = casilla
	return true


## Costo en pies de un camino (lista de casillas vecinas) desde `origen`, con diagonales alternadas.
static func costo_de(origen: Vector2i, casillas: Array[Vector2i]) -> int:
	var total: int = 0
	var diagonales: int = 0
	var anterior: Vector2i = origen
	for casilla: Vector2i in casillas:
		var paso: Vector2i = casilla - anterior
		if paso.x != 0 and paso.y != 0:
			total += Medicion.PIES_POR_CASILLA * (2 if diagonales % 2 == 1 else 1)
			diagonales += 1
		else:
			total += Medicion.PIES_POR_CASILLA
		anterior = casilla
	return total


## Dijkstra desde uno o varios orígenes (índices de casilla; todos con costo 0 y paridad 0), con cola por
## baldes (algoritmo de Dial): los costos son múltiplos de 5 pies y cada paso suma 5 o 10, así que el
## balde i tiene los estados que cuestan i casillas. Si se pasa `destino`, termina al sacar el primer
## estado de esa casilla.
## Devuelve {"costos": PackedInt32Array por estado (-1 = sin alcanzar), "previos": estado anterior (-1 =
## raíz), "orden": estados cerrados de menor a mayor costo, "llegada": estado de `destino` o -1}.
func _buscar(origenes: PackedInt32Array, presupuesto_pies: int, bloqueadas: Dictionary, destino: int = _NINGUNO) -> Dictionary:
	var estados: int = _vecinas.size() * 2
	var costos: PackedInt32Array = PackedInt32Array()
	costos.resize(estados)
	costos.fill(_NINGUNO)
	var previos: PackedInt32Array = costos.duplicate()
	var cerrados: PackedByteArray = PackedByteArray()
	cerrados.resize(estados)
	var bloqueo: PackedByteArray = PackedByteArray()
	bloqueo.resize(_vecinas.size())
	for celda: Vector2i in bloqueadas:
		if _region.has_point(celda):
			bloqueo[indice_de(celda)] = 1
	var orden: PackedInt32Array = PackedInt32Array()
	var baldes: Array[Array] = [[]]
	for origen: int in origenes:
		costos[origen * 2] = 0
		baldes[0].append(origen * 2)
	var i: int = 0
	while i < baldes.size():
		var costo_balde: int = i * Medicion.PIES_POR_CASILLA
		for actual: int in baldes[i]:
			if cerrados[actual] == 1 or costos[actual] != costo_balde:
				continue  # entrada vieja: el estado ya salió con un costo menor
			cerrados[actual] = 1
			orden.append(actual)
			if actual >> 1 == destino:
				return {"costos": costos, "previos": previos, "orden": orden, "llegada": actual}
			var paridad: int = actual & 1
			for vecina: int in _vecinas[actual >> 1]:
				var casilla: int = vecina >> 1
				if bloqueo[casilla] == 1:
					continue
				var diagonal: int = vecina & 1
				var costo: int = costo_balde + Medicion.PIES_POR_CASILLA * (2 if diagonal == 1 and paridad == 1 else 1)
				if costo > presupuesto_pies:
					continue
				var estado: int = casilla * 2 + (paridad ^ diagonal)
				if costos[estado] == _NINGUNO or costo < costos[estado]:
					costos[estado] = costo
					previos[estado] = actual
					var balde: int = costo / Medicion.PIES_POR_CASILLA
					while baldes.size() <= balde:
						baldes.append([])
					baldes[balde].append(estado)
		i += 1
	return {"costos": costos, "previos": previos, "orden": orden, "llegada": _NINGUNO}

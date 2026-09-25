class_name MovimientoCombate
extends RefCounted
## Movimiento en combate con el costo de PF2e (diagonales alternadas 5/10 pies), calculado aparte
## del AStarGrid2D de exploración. Dijkstra sobre (casilla, paridad de diagonales hechas):
## la alternancia se cuenta a lo largo de todo el movimiento.
## - Paredes y esquinas: se respeta GrillaMapa.puede_dar_paso (no se cortan esquinas de paredes).
## - Casillas bloqueadas (enemigos): no se pueden atravesar.
## - Casillas de aliados: se pueden atravesar pero no se puede terminar ahí.

const _SIN_LIMITE: int = 1 << 30
const _VECINAS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
	Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1),
]

var _grilla: GrillaMapa


func _init(grilla: GrillaMapa) -> void:
	_grilla = grilla


## Casillas donde se puede terminar un movimiento de hasta `presupuesto_pies`, con su costo mínimo.
## No incluye el origen ni casillas de aliados.
func alcanzables(origen: Vector2i, presupuesto_pies: int, bloqueadas: Dictionary, de_aliados: Dictionary) -> Dictionary[Vector2i, int]:
	var busqueda: Dictionary = _buscar(origen, presupuesto_pies, bloqueadas)
	var costos: Dictionary = busqueda.costos
	var resultado: Dictionary[Vector2i, int] = {}
	for estado: Vector3i in costos:
		var celda: Vector2i = Vector2i(estado.x, estado.y)
		if celda == origen or de_aliados.has(celda):
			continue
		if not resultado.has(celda) or costos[estado] < resultado[celda]:
			resultado[celda] = costos[estado]
	return resultado


## Camino más barato hasta `destino` (sin incluir el origen), o vacío si no se puede terminar ahí.
func camino(origen: Vector2i, destino: Vector2i, bloqueadas: Dictionary, de_aliados: Dictionary) -> Array[Vector2i]:
	var resultado: Array[Vector2i] = []
	if destino == origen or de_aliados.has(destino) or bloqueadas.has(destino):
		return resultado
	var busqueda: Dictionary = _buscar(origen, _SIN_LIMITE, bloqueadas)
	var mejor: Variant = null
	for paridad: int in [0, 1]:
		var estado: Vector3i = Vector3i(destino.x, destino.y, paridad)
		if busqueda.costos.has(estado) and (mejor == null or busqueda.costos[estado] < busqueda.costos[mejor]):
			mejor = estado
	if mejor == null:
		return resultado
	var actual: Vector3i = mejor
	while busqueda.previos.has(actual):
		resultado.push_front(Vector2i(actual.x, actual.y))
		actual = busqueda.previos[actual]
	return resultado


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


## Dijkstra. Devuelve {"costos": {Vector3i(x, y, paridad): pies}, "previos": {estado: estado_anterior}}.
func _buscar(origen: Vector2i, presupuesto_pies: int, bloqueadas: Dictionary) -> Dictionary:
	var inicio: Vector3i = Vector3i(origen.x, origen.y, 0)
	var costos: Dictionary = {inicio: 0}
	var previos: Dictionary = {}
	var abiertos: Array[Vector3i] = [inicio]
	var cerrados: Dictionary = {}
	while not abiertos.is_empty():
		var actual: Vector3i = _extraer_minimo(abiertos, costos)
		if cerrados.has(actual):
			continue
		cerrados[actual] = true
		var celda: Vector2i = Vector2i(actual.x, actual.y)
		for vecina: Vector2i in _VECINAS:
			var siguiente: Vector2i = celda + vecina
			if bloqueadas.has(siguiente) or not _grilla.puede_dar_paso(celda, siguiente):
				continue
			var es_diagonal: bool = vecina.x != 0 and vecina.y != 0
			var paso: int = Medicion.PIES_POR_CASILLA * (2 if es_diagonal and actual.z == 1 else 1)
			var costo: int = costos[actual] + paso
			if costo > presupuesto_pies:
				continue
			var paridad: int = (actual.z + 1) % 2 if es_diagonal else actual.z
			var estado: Vector3i = Vector3i(siguiente.x, siguiente.y, paridad)
			if not costos.has(estado) or costo < costos[estado]:
				costos[estado] = costo
				previos[estado] = actual
				abiertos.append(estado)
	return {"costos": costos, "previos": previos}


static func _extraer_minimo(abiertos: Array[Vector3i], costos: Dictionary) -> Vector3i:
	var indice: int = 0
	for i in range(1, abiertos.size()):
		if costos[abiertos[i]] < costos[abiertos[indice]]:
			indice = i
	var estado: Vector3i = abiertos[indice]
	abiertos.remove_at(indice)
	return estado

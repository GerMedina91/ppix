class_name AlcanceZancadas
extends RefCounted
## Resultado de MovimientoCombate.alcance_de_zancadas: a qué casillas se llega con 1, 2 o 3 Zancadas
## y por dónde va cada una. Se calcula una vez (una búsqueda por Zancada) y después solo se consulta.

var origen: Vector2i
## Casilla -> cantidad mínima de Zancadas para terminar ahí.
var por_casilla: Dictionary[Vector2i, int] = {}
var _movimiento: MovimientoCombate
## Por capa (índice = Zancada - 1): los previos de la búsqueda de esa Zancada.
var _previos_por_capa: Array[PackedInt32Array] = []
## Casilla -> estado más barato con el que la alcanzó su capa.
var _estado_final: Dictionary[Vector2i, int] = {}


func _init(movimiento: MovimientoCombate, desde: Vector2i) -> void:
	_movimiento = movimiento
	origen = desde


func llega(destino: Vector2i) -> bool:
	return por_casilla.has(destino)


## Casilla por casilla, el recorrido de cada Zancada hasta `destino` (sin la casilla de partida de cada una).
## Vacío si no se llega.
func tramos(destino: Vector2i) -> Array[Array]:
	var resultado: Array[Array] = []
	var actual: Vector2i = destino
	while por_casilla.has(actual):
		var previos: PackedInt32Array = _previos_por_capa[por_casilla[actual] - 1]
		resultado.push_front(_movimiento.recorrido(previos, _estado_final[actual]))
		actual = _movimiento.raiz(previos, _estado_final[actual])
	return resultado


## Dónde termina cada Zancada (el último elemento es `destino`).
func plan(destino: Vector2i) -> Array[Vector2i]:
	var resultado: Array[Vector2i] = []
	for tramo: Array in tramos(destino):
		resultado.append(tramo.back())
	return resultado


## Recorrido completo de todas las Zancadas hasta `destino`.
func camino(destino: Vector2i) -> Array[Vector2i]:
	var resultado: Array[Vector2i] = []
	for tramo: Array in tramos(destino):
		resultado.append_array(tramo)
	return resultado


func agregar_capa(previos: PackedInt32Array) -> void:
	_previos_por_capa.append(previos)


func asignar(casilla: Vector2i, zancadas: int, estado: int) -> void:
	por_casilla[casilla] = zancadas
	_estado_final[casilla] = estado

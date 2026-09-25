class_name SeguimientoFila
extends RefCounted
## Seguimiento en fila india: cuando el líder da un paso, cada seguidor avanza a la celda
## que ocupaba el miembro de adelante antes de ese paso.
## Es una estrategia separada de ControlParty para poder desactivarla a futuro
## (party separada, cada miembro con órdenes propias) sin tocar el movimiento de los miembros.


## Recibe las celdas de toda la party antes del paso del líder (índice 0 = líder)
## y devuelve el destino de cada seguidor (índice 0 = primer seguidor).
static func destinos(celdas_antes: Array[Vector2i]) -> Array[Vector2i]:
	var resultado: Array[Vector2i] = []
	for i in range(1, celdas_antes.size()):
		resultado.append(celdas_antes[i - 1])
	return resultado

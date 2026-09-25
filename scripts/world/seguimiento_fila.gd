class_name SeguimientoFila
extends RefCounted
## Recorrido pendiente de un seguidor en la fila india: las celdas que fue dejando el miembro
## de adelante, en orden. El seguidor las recorre a su propio ritmo, así nunca corta camino
## aunque sus pasos duren distinto que los del de adelante (diagonal vs. ortogonal).
## Es una pieza separada de ControlParty para poder desactivar el seguimiento a futuro
## (party separada, cada miembro con órdenes propias) sin tocar el movimiento de los miembros.

var _pendientes: Array[Vector2i] = []


## El de adelante acaba de salir de `celda_dejada`. Se agrega al recorrido salvo que el seguidor
## ya esté (o ya vaya a estar) en esa celda.
func registrar_salida(celda_dejada: Vector2i, celda_propia: Vector2i) -> void:
	var ultima: Vector2i = _pendientes.back() if not _pendientes.is_empty() else celda_propia
	if celda_dejada != ultima:
		_pendientes.append(celda_dejada)


func tiene_pendientes() -> bool:
	return not _pendientes.is_empty()


func proxima() -> Vector2i:
	return _pendientes.pop_front()


func limpiar() -> void:
	_pendientes.clear()

class_name Reaccion
extends RefCounted
## Punto de extensión para reacciones (p. ej. Golpe reactivo, que es de clase). En M3 no hay ninguna.
## Combate le pasa cada evento; una reacción puede actuar y devolver sus propios eventos.


func al_evento(_evento: EventoCombate, _combate: Combate) -> Array[EventoCombate]:
	return []

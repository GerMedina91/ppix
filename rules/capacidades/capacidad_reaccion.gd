class_name CapacidadReaccion
extends Capacidad
## Capacidad que se usa como reacción (una por asalto: se recupera al empezar el turno propio).


## true si `reactor` puede usarla ante `disparo` (además de tener la reacción disponible y poder actuar).
func aplica(_reactor: Combatiente, _disparo: DisparoReaccion, _combate: Combate) -> bool:
	return false


## Resuelve la reacción y devuelve sus eventos.
func ejecutar(_reactor: Combatiente, _disparo: DisparoReaccion, _combate: Combate) -> Array[EventoCombate]:
	return []

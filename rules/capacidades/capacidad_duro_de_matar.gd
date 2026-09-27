class_name CapacidadDuroDeMatar
extends Capacidad
## Duro de matar (dote general 1, Player Core p. 254; verificado en docs/verificacion/m4_recuerdos.md):
## se muere con moribundo 5 en vez de 4.

const UMBRAL: int = 5


func umbral_de_muerte(actual: int) -> int:
	return maxi(actual, UMBRAL)

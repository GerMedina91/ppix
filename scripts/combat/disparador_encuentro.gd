class_name DisparadorEncuentro
extends Node
## Interfaz genérica de lo que inicia un Encuentro. Se evalúa cada vez que la party se mueve.
## Hoy: ZonaEncuentro. A futuro: detección por visión de los enemigos, eventos de guion, etc.


func debe_disparar(_celdas_party: Array[Vector2i], _encuentro: Encuentro) -> bool:
	return false

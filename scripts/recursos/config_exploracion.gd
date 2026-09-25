class_name ConfigExploracion
extends Resource
## Parámetros de la exploración. Los valores reales viven en data/config/config_exploracion.tres.

## Duración de un paso de una celda, en segundos.
@export var segundos_por_paso: float = 0.2
## Duración del fundido a negro al cambiar de mapa (cada mitad), en segundos.
@export var segundos_fundido: float = 0.25

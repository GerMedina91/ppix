class_name ConfigExploracion
extends Resource
## Parámetros de la exploración. Los valores reales viven en data/config/config_exploracion.tres.

## Segundos que tarda un paso ortogonal de una celda. Un paso diagonal tarda ×√2
## (velocidad constante sobre el suelo, no en pantalla).
@export var segundos_por_celda: float = 0.2
## Opacidad de una pared mientras tapa a un actor visible (party, y en M3 enemigos y NPCs).
@export var alfa_pared_transparente: float = 0.35
## Duración del fundido a negro al cambiar de mapa (cada mitad), en segundos.
@export var segundos_fundido: float = 0.25

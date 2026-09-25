class_name ConfigCombate
extends Resource
## Tiempos de la presentación del combate. Los valores reales viven en data/config/config_combate.tres.

## Segundos por casilla ortogonal al moverse en combate (diagonal ×√2).
@export var segundos_por_celda: float = 0.15
## Pausa después de cada evento (golpe, caída, texto flotante).
@export var pausa_entre_eventos: float = 0.25
## Duración de la embestida de un Golpe (ida y vuelta).
@export var segundos_golpe: float = 0.2
## Duración del texto flotante (daño, "falla", etc.).
@export var segundos_texto_flotante: float = 0.8

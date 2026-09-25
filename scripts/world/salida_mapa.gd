class_name SalidaMapa
extends Marker2D
## Celda que lleva a otro mapa al pisarla. Se ubica en el centro de una celda.
## Se referencia el destino por id (no por escena) para evitar dependencias circulares entre mapas.

@export var id_mapa_destino: StringName = &""
@export var id_entrada_destino: StringName = &""

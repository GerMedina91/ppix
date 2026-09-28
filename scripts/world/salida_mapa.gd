@tool
class_name SalidaMapa
extends Marker2D
## Celda que lleva a otro mapa al pisarla. Se ubica en el centro de una celda.
## Se referencia el destino por id (no por escena) para evitar dependencias circulares entre mapas.

@export var id_mapa_destino: StringName = &"":
	set(valor):
		id_mapa_destino = valor
		update_configuration_warnings()
@export var id_entrada_destino: StringName = &"":
	set(valor):
		id_entrada_destino = valor
		update_configuration_warnings()

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		set_notify_transform(true)


func _notification(que: int) -> void:
	if que == NOTIFICATION_TRANSFORM_CHANGED and Engine.is_editor_hint():
		ValidacionMapa.centrar(self)
		update_configuration_warnings()



func _get_configuration_warnings() -> PackedStringArray:
	var avisos: PackedStringArray = ValidacionMapa.avisos_de_casilla(self)
	if not ValidacionMapa.mapa_existe(id_mapa_destino):
		avisos.append("El mapa destino '%s' no está en data/mapas/catalogo_mapas.tres." % id_mapa_destino)
	elif not ValidacionMapa.entradas_de(id_mapa_destino).has(String(id_entrada_destino)):
		avisos.append("El mapa '%s' no tiene la entrada '%s'." % [id_mapa_destino, id_entrada_destino])
	return avisos

class_name EstadoMundo
extends RefCounted
## Lo que cambió en los mapas y no se revierte (GDD 4.3: "lo hecho, hecho está"): encuentros resueltos y
## enemigos que ya no están (muertos; hoy también los vencidos inconscientes, que M4e deja en el mapa). Ids
## globales "mapa/nombre" (EstadoRecuerdos.id_enemigo). Lo aplica el Mundo al cargar cada mapa.

var encuentros_resueltos: Dictionary[StringName, bool] = {}
var enemigos_retirados: Dictionary[StringName, bool] = {}


static func id_global(id_mapa: StringName, nombre: StringName) -> StringName:
	return StringName("%s/%s" % [id_mapa, nombre])


func resolver_encuentro(id_mapa: StringName, id_encuentro: StringName) -> void:
	encuentros_resueltos[id_global(id_mapa, id_encuentro)] = true


func encuentro_resuelto(id_mapa: StringName, id_encuentro: StringName) -> bool:
	return encuentros_resueltos.has(id_global(id_mapa, id_encuentro))


func retirar_enemigo(id_mapa: StringName, nombre: StringName) -> void:
	enemigos_retirados[id_global(id_mapa, nombre)] = true


func enemigo_retirado(id_mapa: StringName, nombre: StringName) -> bool:
	return enemigos_retirados.has(id_global(id_mapa, nombre))


func a_diccionario() -> Dictionary:
	return {"encuentros_resueltos": _claves(encuentros_resueltos), "enemigos_retirados": _claves(enemigos_retirados)}


static func desde_diccionario(datos: Dictionary) -> EstadoMundo:
	var estado: EstadoMundo = EstadoMundo.new()
	for id: Variant in datos.get("encuentros_resueltos", []):
		estado.encuentros_resueltos[StringName(id)] = true
	for id: Variant in datos.get("enemigos_retirados", []):
		estado.enemigos_retirados[StringName(id)] = true
	return estado


static func _claves(conjunto: Dictionary[StringName, bool]) -> Array[String]:
	var lista: Array[String] = []
	for id: StringName in conjunto:
		lista.append(String(id))
	return lista

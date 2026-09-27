class_name EstadoMundo
extends RefCounted
## Lo que cambió en los mapas y no se revierte (GDD 4.3: "lo hecho, hecho está"): encuentros resueltos,
## enemigos que ya no están (muertos; hoy también los vencidos inconscientes, que M4e deja en el mapa) y los
## cuerpos de los compañeros muertos. Ids
## globales "mapa/nombre" (EstadoRecuerdos.id_enemigo). Lo aplica el Mundo al cargar cada mapa.

var encuentros_resueltos: Dictionary[StringName, bool] = {}
var enemigos_retirados: Dictionary[StringName, bool] = {}
## Cuerpos de los compañeros muertos (muerte permanente): id del miembro -> {"mapa": StringName, "celda": Vector2i}.
var cuerpos: Dictionary[StringName, Dictionary] = {}


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


func dejar_cuerpo(id_miembro: StringName, id_mapa: StringName, celda: Vector2i) -> void:
	cuerpos[id_miembro] = {"mapa": id_mapa, "celda": celda}


## Cuerpos que están en `id_mapa`: id del miembro -> casilla.
func cuerpos_en(id_mapa: StringName) -> Dictionary[StringName, Vector2i]:
	var en_mapa: Dictionary[StringName, Vector2i] = {}
	for id: StringName in cuerpos:
		if cuerpos[id].mapa == id_mapa:
			en_mapa[id] = cuerpos[id].celda
	return en_mapa


func a_diccionario() -> Dictionary:
	var datos_cuerpos: Dictionary = {}
	for id: StringName in cuerpos:
		datos_cuerpos[String(id)] = {"mapa": String(cuerpos[id].mapa), "celda": [cuerpos[id].celda.x, cuerpos[id].celda.y]}
	return {"encuentros_resueltos": _claves(encuentros_resueltos), "enemigos_retirados": _claves(enemigos_retirados),
		"cuerpos": datos_cuerpos}


static func desde_diccionario(datos: Dictionary) -> EstadoMundo:
	var estado: EstadoMundo = EstadoMundo.new()
	for id: Variant in datos.get("encuentros_resueltos", []):
		estado.encuentros_resueltos[StringName(id)] = true
	for id: Variant in datos.get("enemigos_retirados", []):
		estado.enemigos_retirados[StringName(id)] = true
	var datos_cuerpos: Dictionary = datos.get("cuerpos", {})
	for id: String in datos_cuerpos:
		var c: Dictionary = datos_cuerpos[id]
		estado.dejar_cuerpo(StringName(id), StringName(c.mapa), Vector2i(int(c.celda[0]), int(c.celda[1])))
	return estado


static func _claves(conjunto: Dictionary[StringName, bool]) -> Array[String]:
	var lista: Array[String] = []
	for id: StringName in conjunto:
		lista.append(String(id))
	return lista

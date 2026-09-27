class_name SerializacionParty
extends RefCounted
## Estado persistente de la party (GameState.estado_party) de ida y vuelta por JSON: los números vuelven
## como float y los ids como String, así que se normalizan al cargar. Sin estado.


static func a_diccionario(estado_party: Dictionary[StringName, Dictionary]) -> Dictionary:
	var datos: Dictionary = {}
	for id: StringName in estado_party:
		var e: Dictionary = estado_party[id]
		var fila: Dictionary = {"pg": e.pg, "herido": e.get("herido", 0), "muerto": e.get("muerto", false)}
		if e.has("conjuros"):
			fila["conjuros"] = {"usados": Array(e.conjuros.get("usados", [])), "foco": e.conjuros.get("foco", 0)}
		if e.has("inmune_medicina"):
			fila["inmune_medicina"] = Array(e.inmune_medicina).map(func(s: Variant) -> String: return String(s))
		datos[String(id)] = fila
	return datos


static func desde_diccionario(datos: Dictionary) -> Dictionary[StringName, Dictionary]:
	var estado: Dictionary[StringName, Dictionary] = {}
	for id: String in datos:
		var fila: Dictionary = datos[id]
		var e: Dictionary = {"pg": int(fila.get("pg", 0)), "herido": int(fila.get("herido", 0)), "muerto": bool(fila.get("muerto", false))}
		if fila.has("conjuros"):
			var usados: Array[bool] = []
			for u: Variant in fila.conjuros.get("usados", []):
				usados.append(bool(u))
			e["conjuros"] = {"usados": usados, "foco": int(fila.conjuros.get("foco", 0))}
		if fila.has("inmune_medicina"):
			var inmunes: Array[StringName] = []
			for s: Variant in fila.inmune_medicina:
				inmunes.append(StringName(s))
			e["inmune_medicina"] = inmunes
		estado[StringName(id)] = e
	return estado

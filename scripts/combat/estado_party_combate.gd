class_name EstadoPartyCombate
extends RefCounted
## Estado de la party que persiste entre combates (GameState.estado_party): PG, herido y muerte.


## Aplica al combatiente lo que quedó del combate anterior (sin entrada: PG completos).
static func aplicar(c: Combatiente) -> void:
	var guardado: Dictionary = GameState.estado_party.get(c.id, {})
	if guardado.is_empty():
		return
	c.pg = guardado.pg
	c.condiciones.herido = guardado.herido
	c.condiciones.muerto = guardado.get("muerto", false)
	c.condiciones.inconsciente = c.pg == 0 and not c.condiciones.muerto


## Guarda el estado de los miembros al ganar. Los moribundos se estabilizan antes.
static func guardar(party: ControlParty, combate: Combate) -> void:
	for miembro: MiembroParty in party.miembros():
		var c: Combatiente = combate.combatiente(StringName(miembro.name))
		c.estabilizar()
		GameState.estado_party[c.id] = {"pg": c.pg, "herido": c.condiciones.herido, "muerto": c.condiciones.muerto}

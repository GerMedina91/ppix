class_name EstadoPartyCombate
extends RefCounted
## Estado de la party que persiste entre combates (GameState.estado_party): PG, herido, muerte y lo
## gastado de conjuros (espacios y foco; se recupera en puntos estables, C7).


## Aplica al combatiente lo que quedó del combate anterior (sin entrada: PG completos).
static func aplicar(c: Combatiente) -> void:
	var guardado: Dictionary = GameState.estado_party.get(c.id, {})
	if guardado.is_empty():
		return
	c.pg = guardado.pg
	c.condiciones.herido = guardado.herido
	c.condiciones.muerto = guardado.get("muerto", false)
	c.condiciones.inconsciente = c.pg == 0 and not c.condiciones.muerto
	c.conjuros.aplicar_estado(guardado.get("conjuros", {}))
	for sanador: Variant in guardado.get("inmune_medicina", []):
		c.inmune_medicina_de[StringName(sanador)] = true


## Puntos de foco que se recuperan al terminar cada combate (GDD, M3c: versión simplificada de Reenfocar).
const FOCO_POR_COMBATE: int = 1


## Guarda el estado de los miembros al ganar. Los moribundos se estabilizan antes, los inconscientes
## estables despiertan con 1 PG (conservan su herido; GDD, M4e) y cada uno recupera FOCO_POR_COMBATE punto
## de foco.
static func guardar(party: ControlParty, combate: Combate) -> void:
	for miembro: MiembroParty in party.miembros():
		var c: Combatiente = combate.combatiente(StringName(miembro.name))
		c.estabilizar()
		c.despertar_tras_el_combate()
		c.conjuros.recuperar_foco(FOCO_POR_COMBATE)
		GameState.estado_party[c.id] = {"pg": c.pg, "herido": c.condiciones.herido, "muerto": c.condiciones.muerto,
			"conjuros": c.conjuros.estado(), "inmune_medicina": c.inmune_medicina_de.keys()}

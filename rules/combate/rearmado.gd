class_name Rearmado
extends RefCounted
## Rearmado de la party en el último punto estable tras la muerte del Eco (GDD 4.3). Como un descanso (PG,
## espacios, foco e inmunidades), salvo que los compañeros conservan su herido y los que estaban moribundos
## sobreviven con herido +1. Los compañeros muertos siguen muertos. El Eco se rearma sin herido.


## Estado persistente de la party (GameState.estado_party) después del rearmado, a partir del combate perdido.
static func estado_party(combate: Combate) -> Dictionary[StringName, Dictionary]:
	var estado: Dictionary[StringName, Dictionary] = {}
	for c: Combatiente in combate.participantes:
		if c.bando != Combatiente.Bando.PARTY or c.es_eco:
			continue
		if c.condiciones.muerto:
			estado[c.id] = {"pg": 0, "herido": c.condiciones.herido, "muerto": true}
			continue
		var herido: int = c.condiciones.herido + (1 if c.condiciones.moribundo > 0 else 0)
		if herido > 0:
			estado[c.id] = {"pg": c.pg_maximos(), "herido": herido}
	return estado

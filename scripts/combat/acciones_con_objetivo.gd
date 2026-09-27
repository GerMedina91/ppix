class_name AccionesConObjetivo
extends RefCounted
## Acciones del jugador que se eligen en la barra y después piden una criatura (además de los conjuros):
## Golpe no letal, Carga repentina, Medicina en batalla y Recordar conocimiento. Qué hay disponible, a quién
## se puede elegir y qué intención arma el click. Sin estado; las reglas están en rules/.

const GOLPE_NO_LETAL: StringName = &"golpe_no_letal"
const CARGA_REPENTINA: StringName = &"carga_repentina"
const MEDICINA_EN_BATALLA: StringName = &"medicina_en_batalla"
const RECORDAR_CONOCIMIENTO: StringName = &"recordar_conocimiento"
const ORDEN: Array[StringName] = [GOLPE_NO_LETAL, CARGA_REPENTINA, MEDICINA_EN_BATALLA, RECORDAR_CONOCIMIENTO]
const NOMBRES: Dictionary[StringName, String] = {
	GOLPE_NO_LETAL: "Golpe no letal", CARGA_REPENTINA: "Carga repentina",
	MEDICINA_EN_BATALLA: "Medicina en batalla", RECORDAR_CONOCIMIENTO: "Recordar conocimiento",
}
const COSTOS: Dictionary[StringName, int] = {
	GOLPE_NO_LETAL: Combate.COSTO_GOLPE, CARGA_REPENTINA: AccionesEspeciales.COSTO_CARGA,
	MEDICINA_EN_BATALLA: 1, RECORDAR_CONOCIMIENTO: 1,
}


## Las que el actor tiene y le alcanzan las acciones (sin mirar objetivos).
static func disponibles(actor: Combatiente) -> Array[StringName]:
	var lista: Array[StringName] = []
	for id: StringName in ORDEN:
		if actor.acciones_restantes < COSTOS[id]:
			continue
		match id:
			GOLPE_NO_LETAL:
				if actor.arma_principal() == null:
					continue
			CARGA_REPENTINA:
				if not AccionesEspeciales.tiene(actor, AccionesEspeciales.CARGA_REPENTINA) or actor.floritura_en_turno:
					continue
			MEDICINA_EN_BATALLA:
				if not AccionesEspeciales.tiene(actor, AccionesHabilidad.MEDICINA_EN_BATALLA):
					continue
		lista.append(id)
	return lista


## Por qué `actor` no puede usar `id` sobre `objetivo` ahora ("" si puede).
static func motivo(combate: Combate, actor: Combatiente, id: StringName, objetivo: Combatiente) -> String:
	match id:
		GOLPE_NO_LETAL:
			var valido: bool = objetivo != null and Golpe.validar(actor, objetivo, actor.arma_principal(), combate.vision()) == Golpe.Motivo.VALIDO
			return "" if valido else "fuera de alcance"
		CARGA_REPENTINA:
			return combate.especiales.motivo_carga_imposible(actor, objetivo)
		MEDICINA_EN_BATALLA:
			return combate.habilidades.motivo_medicina_imposible(actor, objetivo)
		RECORDAR_CONOCIMIENTO:
			return combate.habilidades.motivo_recordar_imposible(actor, objetivo)
	return "acción desconocida"


static func objetivos(combate: Combate, actor: Combatiente, id: StringName) -> Array[Combatiente]:
	var lista: Array[Combatiente] = []
	for c: Combatiente in combate.participantes:
		if motivo(combate, actor, id, c) == "":
			lista.append(c)
	return lista


## Intención de usar `id` sobre la criatura `objetivo` (el Combate valida y avisa si es imposible).
static func intencion(combate: Combate, id: StringName, objetivo: StringName) -> Callable:
	match id:
		GOLPE_NO_LETAL:
			return combate.golpe.bind(objetivo, null, true)
		CARGA_REPENTINA:
			return combate.especiales.carga_repentina.bind(objetivo)
		MEDICINA_EN_BATALLA:
			return combate.habilidades.medicina_en_batalla.bind(objetivo)
		RECORDAR_CONOCIMIENTO:
			return combate.habilidades.recordar_conocimiento.bind(objetivo)
	return Callable()


static func texto(id: StringName) -> String:
	return "%s %s" % [NOMBRES[id], "◆".repeat(COSTOS[id])]

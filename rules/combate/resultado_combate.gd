class_name ResultadoCombate
extends RefCounted
## Cómo terminó un combate, para lo que pasa después en el mundo (GDD 4.2 y 4.3): lo arma ArmadoCombate al
## cerrar y viaja en ControladorCombate.combate_terminado. Ids = los de los combatientes.

var victoria: bool = false
## Derrota = muerte del Eco (murió o cayó toda la party).
var muerte_del_eco: bool = false
## Casilla donde cayó el Eco (ahí queda el residuo).
var celda_eco: Vector2i = Vector2i.ZERO
var enemigos_muertos: Array[StringName] = []
var enemigos_inconscientes: Array[StringName] = []
var companeros_muertos: Array[StringName] = []


static func desde(combate: Combate) -> ResultadoCombate:
	var r: ResultadoCombate = ResultadoCombate.new()
	r.victoria = combate.estado == Combate.Estado.VICTORIA
	r.muerte_del_eco = combate.estado == Combate.Estado.DERROTA
	for c: Combatiente in combate.participantes:
		if c.es_eco:
			r.celda_eco = c.celda
		if c.bando == Combatiente.Bando.ENEMIGOS:
			if c.condiciones.muerto:
				r.enemigos_muertos.append(c.id)
			elif c.condiciones.inconsciente:
				r.enemigos_inconscientes.append(c.id)
		elif c.condiciones.muerto and not c.es_eco:
			r.companeros_muertos.append(c.id)
	return r

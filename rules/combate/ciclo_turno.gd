class_name CicloTurno
extends RefCounted
## Lo que pasa al empezar y al terminar el turno de un combatiente (Player Core p. 435). Combate lleva el
## orden de iniciativa y llama acá; sin estado.
## - Inicio: 3 acciones y la reacción; duraciones y aturdido (ReglasCondiciones); moribundo: prueba de
##   recuperación.
## - Fin: condiciones (asustado, duraciones) y conjuros sostenidos (terminan si no se sostuvieron).


static func inicio(combate: Combate, actor: Combatiente) -> Array[EventoCombate]:
	actor.empezar_turno()
	var eventos: Array[EventoCombate] = [combate.emitir(EventoCombate.new(EventoCombate.Tipo.INICIO_TURNO, actor.id, {"ronda": combate.ronda}))]
	eventos.append_array(ReglasCondiciones.inicio_de_turno(combate, actor))
	if actor.condiciones.moribundo > 0:
		var resultado: ResultadoPrueba = actor.prueba_de_recuperacion(combate.dados())
		eventos.append(combate.emitir(EventoCombate.new(EventoCombate.Tipo.RECUPERACION, actor.id,
			{"resultado": resultado, "moribundo": actor.condiciones.moribundo})))
		if actor.condiciones.muerto:
			eventos.append(combate.emitir(EventoCombate.new(EventoCombate.Tipo.MUERTE, actor.id)))
			eventos.append_array(combate.verificar_fin())
	return eventos


## true si después del inicio no puede hacer nada en este turno (inconsciente o sin acciones).
static func pierde_el_turno(actor: Combatiente) -> bool:
	return not actor.condiciones.puede_actuar() or actor.acciones_restantes == 0


static func fin(combate: Combate, actor: Combatiente) -> Array[EventoCombate]:
	var eventos: Array[EventoCombate] = ReglasCondiciones.fin_de_turno(combate, actor)
	eventos.append_array(combate.conjuros.fin_de_turno(actor))
	eventos.append_array(combate.conjuros.actualizar_pisos())
	return eventos

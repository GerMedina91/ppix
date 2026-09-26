class_name ArmadoCombate
extends RefCounted
## Arma el Combate a partir de la party y el Encuentro, y lo cierra al terminar (estado de la party,
## enemigos muertos, encuentro resuelto). Sin estado: lo usa el ControladorCombate.


## Participantes y sus actores del mapa: {"participantes": Array[Combatiente], "actores": {id: ActorMapa}}.
## `siempre`: miembros que reaccionan sin preguntar (auto_jugar_party o "Siempre" en el aviso).
static func participantes(party: ControlParty, encuentro: Encuentro, siempre: Callable) -> Dictionary:
	var lista: Array[Combatiente] = []
	var actores: Dictionary[StringName, ActorMapa] = {}
	for miembro: MiembroParty in party.miembros():
		var c: Combatiente = Combatiente.desde_personaje(StringName(miembro.name), miembro.definicion_de_reglas(), miembro.celda)
		EstadoPartyCombate.aplicar(c)
		if siempre.call(c.id):
			c.politica_reacciones = Combatiente.PoliticaReaccion.SIEMPRE
		lista.append(c)
		actores[c.id] = miembro
	for enemigo: EnemigoEnMapa in encuentro.enemigos():
		var c: Combatiente = Combatiente.desde_criatura(StringName(enemigo.name), enemigo.definicion, enemigo.celda)
		lista.append(c)
		actores[c.id] = enemigo
	return {"participantes": lista, "actores": actores}


## Combate listo para iniciar(), con las opciones de la config y la pausa tras reacciones (la presentación
## anima cada reacción antes de seguir).
static func nuevo_combate(participantes_combate: Array[Combatiente], mapa: Mapa, config: ConfigCombate) -> Combate:
	var combate: Combate = Combate.new(participantes_combate, mapa.construir_grilla(), GameState.dados)
	combate.pausar_tras_reacciones = true
	combate.reacciones_antes_del_primer_turno = config.reacciones_antes_del_primer_turno
	return combate


## Al terminar: si ganaron, guarda el estado de la party, saca a los enemigos derrotados (muertos o
## noqueados) y marca el encuentro
## como resuelto. Devuelve si fue victoria.
static func cerrar(combate: Combate, party: ControlParty, encuentro: Encuentro) -> bool:
	var victoria: bool = combate.estado == Combate.Estado.VICTORIA
	if victoria:
		EstadoPartyCombate.guardar(party, combate)
		for enemigo: EnemigoEnMapa in encuentro.enemigos():
			if combate.combatiente(StringName(enemigo.name)).condiciones.fuera_de_combate():
				enemigo.queue_free()
		encuentro.resuelto = true
	return victoria

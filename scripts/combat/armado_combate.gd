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
		c.nombre_visible = miembro.nombre_visible()
		c.es_eco = miembro.es_eco
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


## Al terminar arma el ResultadoCombate y deja anotado en el mundo (GameState.mundo) lo que no se revierte
## (los compañeros muertos dejan su cuerpo donde cayeron):
## - Victoria: guarda el estado de la party, saca a los enemigos muertos y marca el encuentro como resuelto.
##   Los inconscientes quedan en el mapa: los resuelve FuentesRecuerdos (extraer, perdonar o rematar).
## - Derrota (muerte del Eco): los enemigos muertos siguen muertos; el encuentro queda sin resolver (los demás
##   vuelven a su lugar con todos sus PG al recargar el mapa) y la party queda rearmada (Rearmado). El
##   residuo, la reaparición y la pérdida los hace GestorMuerte.
static func cerrar(combate: Combate, party: ControlParty, encuentro: Encuentro) -> ResultadoCombate:
	var resultado: ResultadoCombate = ResultadoCombate.desde(combate)
	var id_mapa: StringName = GameState.id_mapa_actual
	if resultado.victoria:
		EstadoPartyCombate.guardar(party, combate)
		encuentro.resuelto = true
		GameState.mundo.resolver_encuentro(id_mapa, encuentro.id)
	else:
		GameState.estado_party = Rearmado.estado_party(combate)
	for id: StringName in resultado.companeros_muertos:
		GameState.mundo.dejar_cuerpo(id, id_mapa, combate.combatiente(id).celda)
	for enemigo: EnemigoEnMapa in encuentro.enemigos():
		var c: Combatiente = combate.combatiente(StringName(enemigo.name))
		if c.condiciones.muerto:
			GameState.mundo.retirar_enemigo(id_mapa, c.id)
			enemigo.queue_free()
	return resultado

class_name CapacidadGolpeReactivo
extends CapacidadReaccion
## Golpe reactivo del guerrero (Player Core p. 138; verificado): cuando una criatura a su alcance sale de
## una casilla durante un movimiento o hace un ataque a distancia, le hace un Golpe cuerpo a cuerpo que no
## cuenta para el penalizador por ataque múltiple ni lo sufre. (Acciones de manipular e interrupción por
## crítico: con los conjuros, C4.)


func aplica(reactor: Combatiente, disparo: DisparoReaccion, combate: Combate) -> bool:
	if disparo.tipo != DisparoReaccion.Tipo.SALE_DE_CASILLA and disparo.tipo != DisparoReaccion.Tipo.ATAQUE_A_DISTANCIA:
		return false
	if disparo.actor.es_aliado_de(reactor) or not disparo.actor.condiciones.en_pie():
		return false
	return arma_para(reactor, disparo.celda) != null and combate.vision().hay_linea(reactor.celda, disparo.celda)


func ejecutar(reactor: Combatiente, disparo: DisparoReaccion, combate: Combate) -> Array[EventoCombate]:
	return combate.golpe_de_reaccion(reactor, disparo.actor, arma_para(reactor, disparo.celda))


## Arma cuerpo a cuerpo del reactor que llega a `casilla`, o null.
static func arma_para(reactor: Combatiente, casilla: Vector2i) -> DefinicionArma:
	for arma: DefinicionArma in reactor.fuente.armas():
		if not arma.a_distancia and Medicion.en_alcance(reactor.celda, casilla, arma.alcance_pies):
			return arma
	return null

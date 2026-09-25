class_name CapacidadGolpeReactivo
extends CapacidadReaccion
## Golpe reactivo del guerrero (Player Core p. 138; verificado): cuando una criatura a su alcance usa una
## acción de manipular, sale de una casilla durante un movimiento o hace un ataque a distancia, le hace un
## Golpe cuerpo a cuerpo que no cuenta para el penalizador por ataque múltiple ni lo sufre. Si es crítico
## y el disparo fue una acción de manipular, la interrumpe.

const _DISPAROS: Array[DisparoReaccion.Tipo] = [DisparoReaccion.Tipo.SALE_DE_CASILLA,
	DisparoReaccion.Tipo.ATAQUE_A_DISTANCIA, DisparoReaccion.Tipo.USA_MANIPULAR]


func aplica(reactor: Combatiente, disparo: DisparoReaccion, combate: Combate) -> bool:
	if not _DISPAROS.has(disparo.tipo):
		return false
	if disparo.actor.es_aliado_de(reactor) or not disparo.actor.condiciones.en_pie():
		return false
	return arma_para(reactor, disparo.celda) != null and combate.vision().hay_linea(reactor.celda, disparo.celda)


func ejecutar(reactor: Combatiente, disparo: DisparoReaccion, combate: Combate) -> Array[EventoCombate]:
	var eventos: Array[EventoCombate] = combate.golpe_de_reaccion(reactor, disparo.actor, arma_para(reactor, disparo.celda))
	if disparo.tipo == DisparoReaccion.Tipo.USA_MANIPULAR:
		for evento: EventoCombate in eventos:
			if evento.tipo == EventoCombate.Tipo.GOLPE and (evento.datos.resultado as ResultadoGolpe).critico:
				disparo.interrumpida = true
	return eventos


## Arma cuerpo a cuerpo del reactor que llega a `casilla`, o null.
static func arma_para(reactor: Combatiente, casilla: Vector2i) -> DefinicionArma:
	for arma: DefinicionArma in reactor.fuente.armas():
		if not arma.a_distancia and Medicion.en_alcance(reactor.celda, casilla, arma.alcance_pies):
			return arma
	return null

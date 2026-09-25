class_name CapacidadEsquivaAgil
extends CapacidadReaccion
## Esquiva ágil (dote de pícaro 1, Player Core p. 169; verificado): cuando una criatura que puede ver lo
## elige como objetivo de un ataque, +2 por circunstancia a la CA contra ese ataque.

const BONIFICADOR: int = 2


func aplica(reactor: Combatiente, disparo: DisparoReaccion, combate: Combate) -> bool:
	return disparo.tipo == DisparoReaccion.Tipo.OBJETIVO_DE_ATAQUE and disparo.objetivo == reactor \
		and combate.vision().hay_linea(reactor.celda, disparo.actor.celda)


func ejecutar(_reactor: Combatiente, disparo: DisparoReaccion, _combate: Combate) -> Array[EventoCombate]:
	disparo.bonificadores_ca.append(Modificador.new(BONIFICADOR, Modificador.Tipo.CIRCUNSTANCIA, nombre))
	return []

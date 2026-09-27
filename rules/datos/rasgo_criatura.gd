class_name RasgoCriatura
extends RefCounted
## Rasgo de tipo de una criatura y lo que se usa para Recordar conocimiento (GM Core p. 52 y 54; verificado en
## docs/verificacion/m4_recuerdos.md): habilidades con que se la identifica, CD por nivel y ajuste por rareza.

enum Tipo {
	ABERRACION, ANIMAL, ASTRAL, BESTIA, CELESTIAL, CIENO, CONSTRUCTO, DRAGON, ELEMENTAL, ESPIRITU, ETEREO,
	FEERICO, HONGO, HUMANOIDE, INFERNAL, MONITOR, MUERTO_VIVIENTE, ONIRICO, PLANTA, SOMBRA, TIEMPO,
}
enum Rareza { COMUN, POCO_COMUN, RARO, UNICO }

const HABILIDADES: Dictionary[Tipo, Array] = {
	Tipo.ABERRACION: [Habilidad.Tipo.OCULTISMO], Tipo.ANIMAL: [Habilidad.Tipo.NATURALEZA],
	Tipo.ASTRAL: [Habilidad.Tipo.OCULTISMO], Tipo.BESTIA: [Habilidad.Tipo.ARCANOS, Habilidad.Tipo.NATURALEZA],
	Tipo.CELESTIAL: [Habilidad.Tipo.RELIGION], Tipo.CIENO: [Habilidad.Tipo.OCULTISMO],
	Tipo.CONSTRUCTO: [Habilidad.Tipo.ARCANOS, Habilidad.Tipo.ARTESANIA], Tipo.DRAGON: [Habilidad.Tipo.ARCANOS],
	Tipo.ELEMENTAL: [Habilidad.Tipo.ARCANOS, Habilidad.Tipo.NATURALEZA], Tipo.ESPIRITU: [Habilidad.Tipo.OCULTISMO],
	Tipo.ETEREO: [Habilidad.Tipo.OCULTISMO], Tipo.FEERICO: [Habilidad.Tipo.NATURALEZA],
	Tipo.HONGO: [Habilidad.Tipo.NATURALEZA], Tipo.HUMANOIDE: [Habilidad.Tipo.SOCIEDAD],
	Tipo.INFERNAL: [Habilidad.Tipo.RELIGION], Tipo.MONITOR: [Habilidad.Tipo.RELIGION],
	Tipo.MUERTO_VIVIENTE: [Habilidad.Tipo.RELIGION], Tipo.ONIRICO: [Habilidad.Tipo.OCULTISMO],
	Tipo.PLANTA: [Habilidad.Tipo.NATURALEZA], Tipo.SOMBRA: [Habilidad.Tipo.RELIGION],
	Tipo.TIEMPO: [Habilidad.Tipo.OCULTISMO],
}
## CD por nivel, de 0 a 10 (niveles negativos usan la de 0; el slice no pasa de nivel 10).
const CD_POR_NIVEL: Array[int] = [14, 15, 16, 18, 19, 20, 22, 23, 24, 26, 27]
const AJUSTE_RAREZA: Dictionary[Rareza, int] = {Rareza.COMUN: 0, Rareza.POCO_COMUN: 2, Rareza.RARO: 5, Rareza.UNICO: 10}


static func habilidades_de(tipo: Tipo) -> Array[Habilidad.Tipo]:
	var lista: Array[Habilidad.Tipo] = []
	lista.assign(HABILIDADES[tipo])
	return lista


## CD para Recordar conocimiento sobre una criatura de ese nivel y rareza.
static func cd_recordar(nivel: int, rareza: Rareza) -> int:
	return CD_POR_NIVEL[clampi(nivel, 0, CD_POR_NIVEL.size() - 1)] + AJUSTE_RAREZA[rareza]

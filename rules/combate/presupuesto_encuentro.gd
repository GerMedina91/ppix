class_name PresupuestoEncuentro
extends RefCounted
## Presupuesto de XP de un encuentro para una party de 4 (GM Core p. 75-76; docs/verificacion/m5_criaturas.md).
## Cada criatura vale según su nivel menos el de la party; la suma da la amenaza.

enum Amenaza { TRIVIAL, BAJA, MODERADA, SEVERA, EXTREMA }

## Nivel de la criatura menos el de la party → XP (GM Core, tabla de XP por criatura).
const XP_POR_DIFERENCIA: Dictionary[int, int] = {-4: 10, -3: 15, -2: 20, -1: 30, 0: 40, 1: 60, 2: 80, 3: 120, 4: 160}
## XP de cada amenaza (GM Core, presupuesto por amenaza; party de 4).
const XP_POR_AMENAZA: Dictionary[Amenaza, int] = {
	Amenaza.TRIVIAL: 40, Amenaza.BAJA: 60, Amenaza.MODERADA: 80, Amenaza.SEVERA: 120, Amenaza.EXTREMA: 160,
}
const _NOMBRES: Dictionary[Amenaza, String] = {
	Amenaza.TRIVIAL: "trivial", Amenaza.BAJA: "baja", Amenaza.MODERADA: "moderada", Amenaza.SEVERA: "severa",
	Amenaza.EXTREMA: "extrema",
}


## XP de una criatura (0 si está más de 4 niveles por debajo; la de +4 si está más arriba).
static func xp_de(nivel_criatura: int, nivel_party: int) -> int:
	var diferencia: int = nivel_criatura - nivel_party
	if diferencia < -4:
		return 0
	return XP_POR_DIFERENCIA[mini(diferencia, 4)]


static func xp_total(criaturas: Array[DefinicionCriatura], nivel_party: int) -> int:
	var total: int = 0
	for criatura: DefinicionCriatura in criaturas:
		total += xp_de(criatura.nivel, nivel_party)
	return total


## La amenaza más alta cuyo presupuesto alcanza ese XP.
static func amenaza(xp: int) -> Amenaza:
	var resultado: Amenaza = Amenaza.TRIVIAL
	for nivel: Amenaza in XP_POR_AMENAZA:
		if xp >= XP_POR_AMENAZA[nivel]:
			resultado = nivel
	return resultado


static func nombre(nivel: Amenaza) -> String:
	return _NOMBRES[nivel]

class_name Cobertura
extends RefCounted
## Cobertura (Player Core p. 424; verificada en docs/verificacion/cobertura.md). Relativa a cada atacante: la
## decide la recta de centro a centro (LineaVision). Sin estado.
## - Menor (+1 a la CA): la recta pasa por una criatura (que no sea el atacante ni el objetivo).
## - Normal (+2 a la CA, a Reflejos contra áreas y a Sigilo): la recta pasa por una pared.
## - Mayor (+4): con Tomar cobertura, si ya tenía normal. Si no, Tomar cobertura da normal.
## Si hay varias, vale la mayor. Es un bonificador de circunstancia.

enum Nivel { NINGUNA, MENOR, NORMAL, MAYOR }

const BONO_CA: Dictionary[Nivel, int] = {Nivel.NINGUNA: 0, Nivel.MENOR: 1, Nivel.NORMAL: 2, Nivel.MAYOR: 4}
const NOMBRES: Dictionary[Nivel, String] = {
	Nivel.NINGUNA: "sin cobertura", Nivel.MENOR: "cobertura menor", Nivel.NORMAL: "cobertura normal", Nivel.MAYOR: "cobertura mayor",
}


## Cobertura de `objetivo` frente a `atacante`.
static func de(atacante: Combatiente, objetivo: Combatiente, participantes: Array[Combatiente], vision: LineaVision) -> Nivel:
	var nivel: Nivel = natural(atacante.celda, objetivo.celda, _celdas_de_criaturas(participantes, atacante, objetivo), vision)
	if objetivo.tomando_cobertura:
		nivel = Nivel.MAYOR if nivel >= Nivel.NORMAL else Nivel.NORMAL
	return nivel


## Sin Tomar cobertura: pared en la recta central = normal; criatura en la recta = menor.
static func natural(desde: Vector2i, hasta: Vector2i, criaturas: Dictionary[Vector2i, bool], vision: LineaVision) -> Nivel:
	if vision.tapa_la_recta_central(desde, hasta):
		return Nivel.NORMAL
	for casilla: Vector2i in vision.casillas_atravesadas(desde, hasta):
		if criaturas.has(casilla):
			return Nivel.MENOR
	return Nivel.NINGUNA


## Bonificador de circunstancia a la CA (null si no hay cobertura).
static func modificador_ca(nivel: Nivel) -> Modificador:
	if nivel == Nivel.NINGUNA:
		return null
	return Modificador.new(BONO_CA[nivel], Modificador.Tipo.CIRCUNSTANCIA, NOMBRES[nivel])


static func texto(nivel: Nivel) -> String:
	return "%s (+%d CA)" % [NOMBRES[nivel], BONO_CA[nivel]] if nivel != Nivel.NINGUNA else ""


static func _celdas_de_criaturas(participantes: Array[Combatiente], atacante: Combatiente, objetivo: Combatiente) -> Dictionary[Vector2i, bool]:
	var celdas: Dictionary[Vector2i, bool] = {}
	for c: Combatiente in participantes:
		if c != atacante and c != objetivo and not c.condiciones.muerto:
			celdas[c.celda] = true
	return celdas

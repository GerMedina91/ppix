class_name Habilidad
extends RefCounted
## Habilidades del Player Core con su atributo (verificado en docs/verificacion/c1_clases.md; ver
## docs/GLOSARIO.md). Saber (Lore) queda para más adelante: se divide en subcategorías.

enum Tipo {
	ACROBACIAS, ARCANOS, ATLETISMO, ARTESANIA, ENGANO, DIPLOMACIA, INTIMIDACION, MEDICINA,
	NATURALEZA, OCULTISMO, INTERPRETACION, RELIGION, SOCIEDAD, SIGILO, SUPERVIVENCIA, LATROCINIO,
}

const ATRIBUTO: Dictionary[Tipo, Atributo.Tipo] = {
	Tipo.ACROBACIAS: Atributo.Tipo.DESTREZA,
	Tipo.ARCANOS: Atributo.Tipo.INTELIGENCIA,
	Tipo.ATLETISMO: Atributo.Tipo.FUERZA,
	Tipo.ARTESANIA: Atributo.Tipo.INTELIGENCIA,
	Tipo.ENGANO: Atributo.Tipo.CARISMA,
	Tipo.DIPLOMACIA: Atributo.Tipo.CARISMA,
	Tipo.INTIMIDACION: Atributo.Tipo.CARISMA,
	Tipo.MEDICINA: Atributo.Tipo.SABIDURIA,
	Tipo.NATURALEZA: Atributo.Tipo.SABIDURIA,
	Tipo.OCULTISMO: Atributo.Tipo.INTELIGENCIA,
	Tipo.INTERPRETACION: Atributo.Tipo.CARISMA,
	Tipo.RELIGION: Atributo.Tipo.SABIDURIA,
	Tipo.SOCIEDAD: Atributo.Tipo.INTELIGENCIA,
	Tipo.SIGILO: Atributo.Tipo.DESTREZA,
	Tipo.SUPERVIVENCIA: Atributo.Tipo.SABIDURIA,
	Tipo.LATROCINIO: Atributo.Tipo.DESTREZA,
}

const _NOMBRES: Dictionary[Tipo, String] = {
	Tipo.ACROBACIAS: "Acrobacias",
	Tipo.ARCANOS: "Arcanos",
	Tipo.ATLETISMO: "Atletismo",
	Tipo.ARTESANIA: "Artesanía",
	Tipo.ENGANO: "Engaño",
	Tipo.DIPLOMACIA: "Diplomacia",
	Tipo.INTIMIDACION: "Intimidación",
	Tipo.MEDICINA: "Medicina",
	Tipo.NATURALEZA: "Naturaleza",
	Tipo.OCULTISMO: "Ocultismo",
	Tipo.INTERPRETACION: "Interpretación",
	Tipo.RELIGION: "Religión",
	Tipo.SOCIEDAD: "Sociedad",
	Tipo.SIGILO: "Sigilo",
	Tipo.SUPERVIVENCIA: "Supervivencia",
	Tipo.LATROCINIO: "Latrocinio",
}


static func nombre(tipo: Tipo) -> String:
	return _NOMBRES[tipo]


## true si la habilidad usa Fuerza o Destreza (le afecta el penalizador a pruebas de la armadura).
static func es_fisica(tipo: Tipo) -> bool:
	return ATRIBUTO[tipo] == Atributo.Tipo.FUERZA or ATRIBUTO[tipo] == Atributo.Tipo.DESTREZA

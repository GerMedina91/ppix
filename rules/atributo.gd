class_name Atributo
extends RefCounted
## Los seis atributos. En Remaster se usan directamente sus modificadores (no puntuaciones).

enum Tipo { FUERZA, DESTREZA, CONSTITUCION, INTELIGENCIA, SABIDURIA, CARISMA }

const _NOMBRES: Dictionary[Tipo, String] = {
	Tipo.FUERZA: "Fuerza",
	Tipo.DESTREZA: "Destreza",
	Tipo.CONSTITUCION: "Constitución",
	Tipo.INTELIGENCIA: "Inteligencia",
	Tipo.SABIDURIA: "Sabiduría",
	Tipo.CARISMA: "Carisma",
}


static func nombre(tipo: Tipo) -> String:
	return _NOMBRES[tipo]

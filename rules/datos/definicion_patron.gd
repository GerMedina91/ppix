class_name DefinicionPatron
extends DefinicionSubclase
## Patrón de la bruja (lore en docs/lore/patrones.md): tradición, habilidad, truco de maleficio (se suma
## a los trucos de la bruja) y conjuro otorgado (lo aprende el familiar; la bruja lo puede preparar).

@export var tradicion: Tradicion.Tipo = Tradicion.Tipo.OCULTISTA
@export var truco_maleficio: DefinicionConjuro
@export var conjuro_otorgado: DefinicionConjuro
## Patrón del Player Core Remaster del que se toma la mecánica (referencia, no se muestra).
@export var mecanica_base: String = ""

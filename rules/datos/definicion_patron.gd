class_name DefinicionPatron
extends DefinicionSubclase
## Patrón de la bruja (lore en docs/lore/patrones.md). Tradición y habilidad en C1; truco de maleficio
## y conjuro otorgado llegan con el motor de conjuros (C4).

enum Tradicion { ARCANA, DIVINA, OCULTISTA, PRIMIGENIA }

@export var tradicion: Tradicion = Tradicion.OCULTISTA
## Patrón del Player Core Remaster del que se toma la mecánica (referencia, no se muestra).
@export var mecanica_base: String = ""

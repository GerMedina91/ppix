class_name MiembroParty
extends ActorMapa
## Miembro de la party en el mapa. No decide adónde ir: eso es de ControlParty (exploración)
## o del ControladorCombate (combate).

## Números de reglas del miembro (hoy personajes de prueba; a futuro, armados desde clase y ascendencia).
@export var definicion: DefinicionPersonaje

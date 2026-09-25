class_name MiembroParty
extends ActorMapa
## Miembro de la party en el mapa. No decide adónde ir: eso es de ControlParty (exploración)
## o del ControladorCombate (combate).

## Build del miembro (clase, ascendencia, equipo). Si está, sus números salen de acá.
@export var build: DefinicionBuild
## Definición directa (personajes de prueba sin build). Se usa solo si no hay build.
@export var definicion: DefinicionPersonaje

var _armado: DefinicionPersonaje


## Números de reglas del miembro: el build armado (una vez) o la definición directa.
func definicion_de_reglas() -> DefinicionPersonaje:
	if build == null:
		return definicion
	if _armado == null:
		_armado = ArmadorPersonaje.armar(build)
	return _armado

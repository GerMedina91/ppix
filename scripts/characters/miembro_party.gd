class_name MiembroParty
extends ActorMapa
## Miembro de la party en el mapa. No decide adónde ir: eso es de ControlParty (exploración)
## o del ControladorCombate (combate).

## Build del miembro (clase, ascendencia, equipo). Si está, sus números salen de acá.
@export var build: DefinicionBuild
## Definición directa (personajes de prueba sin build). Se usa solo si no hay build.
@export var definicion: DefinicionPersonaje
## El Eco (el protagonista): el único que integra recuerdos (GDD 4.2). En el slice, el guerrero.
@export var es_eco: bool = false

var _armado: DefinicionPersonaje


## Números de reglas del miembro: el build armado o la definición directa. El Eco se arma cada vez con
## sus recuerdos integrados (cambian fuera de combate); los demás, una sola vez.
func definicion_de_reglas() -> DefinicionPersonaje:
	if build == null:
		return definicion
	if es_eco:
		return ArmadorPersonaje.armar(build, GameState.recuerdos.inventario.integrados)
	if _armado == null:
		_armado = ArmadorPersonaje.armar(build)
	return _armado

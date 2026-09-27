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

## Cómo se lo nombra en el HUD y el registro (docs/lore/companeros.md).
const NOMBRE_ECO: String = "el Eco"


## El Eco siempre es "el Eco"; los demás, el nombre de su build (sin build, el del nodo).
func nombre_visible() -> String:
	if es_eco:
		return NOMBRE_ECO
	return build.nombre if build != null else String(name)


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

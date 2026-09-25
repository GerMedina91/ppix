class_name Condiciones
extends RefCounted
## Condiciones básicas de un combatiente. Las reglas que las modifican están en Combatiente
## (recibir daño, curar, prueba de recuperación). El flanqueo no se guarda acá: se calcula en cada
## ataque, porque solo deja desprevenido frente a quienes flanquean (ver Flanqueo).

## Con este valor de moribundo, el personaje muere.
const MORIBUNDO_MUERTE: int = 4

var moribundo: int = 0
var herido: int = 0
var inconsciente: bool = false
var muerto: bool = false
## Desprevenido frente a todos (por otros efectos; el flanqueo va aparte).
var desprevenido: bool = false


func puede_actuar() -> bool:
	return not inconsciente and not muerto


func fuera_de_combate() -> bool:
	return inconsciente or muerto

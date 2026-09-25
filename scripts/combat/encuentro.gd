class_name Encuentro
extends Node2D
## Encuentro de combate dentro de un mapa: sus enemigos (EnemigoEnMapa) y lo que lo dispara
## (hijos DisparadorEncuentro). Se resuelve una sola vez.

@export var id: StringName = &""

var resuelto: bool = false


func enemigos() -> Array[EnemigoEnMapa]:
	var lista: Array[EnemigoEnMapa] = []
	for hijo: Node in get_children():
		if hijo is EnemigoEnMapa:
			lista.append(hijo)
	return lista


func disparadores() -> Array[DisparadorEncuentro]:
	var lista: Array[DisparadorEncuentro] = []
	for hijo: Node in get_children():
		if hijo is DisparadorEncuentro:
			lista.append(hijo)
	return lista


## true si no está resuelto y alguno de sus disparadores se activa.
func evaluar(celdas_party: Array[Vector2i]) -> bool:
	if resuelto:
		return false
	return disparadores().any(func(d: DisparadorEncuentro) -> bool: return d.debe_disparar(celdas_party, self))

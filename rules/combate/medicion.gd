class_name Medicion
extends RefCounted
## Distancias en pies sobre la grilla con la regla de PF2e: cada casilla son 5 pies y las diagonales
## alternan 5 y 10 pies (la primera cuesta 5, la segunda 10, la tercera 5...).
## Excepción: un alcance de 10 pies llega a dos casillas en diagonal aunque medidas darían 15.

const PIES_POR_CASILLA: int = 5
const ALCANCE_CON_EXCEPCION_DIAGONAL: int = 10


## Distancia en pies entre dos casillas (camino recto, sin obstáculos).
static func pies_entre(desde: Vector2i, hasta: Vector2i) -> int:
	var dx: int = absi(hasta.x - desde.x)
	var dy: int = absi(hasta.y - desde.y)
	var diagonales: int = mini(dx, dy)
	var rectas: int = maxi(dx, dy) - diagonales
	return (rectas + diagonales + diagonales / 2) * PIES_POR_CASILLA


## true si `objetivo` está dentro de `alcance_pies` de `origen`.
static func en_alcance(origen: Vector2i, objetivo: Vector2i, alcance_pies: int) -> bool:
	if origen == objetivo:
		return false
	var dx: int = absi(objetivo.x - origen.x)
	var dy: int = absi(objetivo.y - origen.y)
	if alcance_pies == ALCANCE_CON_EXCEPCION_DIAGONAL and dx == 2 and dy == 2:
		return true
	return pies_entre(origen, objetivo) <= alcance_pies

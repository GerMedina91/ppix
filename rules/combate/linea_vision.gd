class_name LineaVision
extends RefCounted
## Línea de visión entre centros de casillas (recorrido "supercover": todas las casillas que toca la recta).
## - Opacas: las casillas no transitables de la grilla (paredes) y las de fuera del mapa.
## - Las casillas de origen y destino no bloquean.
## - Si la recta pasa justo por una esquina, bloquea solo si las dos casillas laterales son opacas
##   (no se ve entre dos paredes que se tocan en diagonal; rozar una sola esquina sí deja ver).
## Base para la cobertura (después de M3).

var _grilla: GrillaMapa


func _init(grilla: GrillaMapa) -> void:
	_grilla = grilla


func hay_linea(desde: Vector2i, hasta: Vector2i) -> bool:
	return _recorrer(desde, hasta).visible


## Casillas intermedias que toca la recta (sin origen ni destino), para depuración.
func casillas_atravesadas(desde: Vector2i, hasta: Vector2i) -> Array[Vector2i]:
	return _recorrer(desde, hasta).casillas


func es_opaca(casilla: Vector2i) -> bool:
	return not _grilla.es_transitable(casilla)


func _recorrer(desde: Vector2i, hasta: Vector2i) -> Dictionary:
	var casillas: Array[Vector2i] = []
	var visible: bool = true
	var dx: int = absi(hasta.x - desde.x)
	var dy: int = absi(hasta.y - desde.y)
	var paso: Vector2i = Vector2i(signi(hasta.x - desde.x), signi(hasta.y - desde.y))
	var actual: Vector2i = desde
	var avance_x: int = 0
	var avance_y: int = 0
	while avance_x < dx or avance_y < dy:
		var decision: int = (1 + 2 * avance_x) * dy - (1 + 2 * avance_y) * dx
		if decision == 0:
			# La recta pasa justo por la esquina: se mira a los dos costados.
			var lateral_x: Vector2i = actual + Vector2i(paso.x, 0)
			var lateral_y: Vector2i = actual + Vector2i(0, paso.y)
			if es_opaca(lateral_x) and es_opaca(lateral_y):
				visible = false
			actual += paso
			avance_x += 1
			avance_y += 1
		elif decision < 0:
			actual.x += paso.x
			avance_x += 1
		else:
			actual.y += paso.y
			avance_y += 1
		if actual != hasta:
			casillas.append(actual)
			if es_opaca(actual):
				visible = false
	return {"visible": visible, "casillas": casillas}

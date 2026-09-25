extends Node2D
## Escena de prueba de render: dibuja la grilla de tiles para verificar a ojo
## el escalado entero y el filtro Nearest (bordes nítidos, píxeles cuadrados).

## Tamaño de tile del proyecto (ver CLAUDE.md: 1 tile = 32 px = 5 pies).
const TAMANO_TILE: int = 32
const COLOR_A: Color = Color(0.16, 0.16, 0.2)
const COLOR_B: Color = Color(0.22, 0.22, 0.28)
const COLOR_BORDE: Color = Color(0.9, 0.9, 0.9)
const COLOR_MARCA: Color = Color(0.85, 0.2, 0.2)


func _draw() -> void:
	var tamano: Vector2i = get_viewport_rect().size
	var columnas: int = ceili(float(tamano.x) / TAMANO_TILE)
	var filas: int = ceili(float(tamano.y) / TAMANO_TILE)
	for fila in filas:
		for columna in columnas:
			var color: Color = COLOR_A if (fila + columna) % 2 == 0 else COLOR_B
			draw_rect(Rect2(columna * TAMANO_TILE, fila * TAMANO_TILE, TAMANO_TILE, TAMANO_TILE), color)
	# Borde de 1 px alrededor del viewport: si se ve completo y nítido, el escalado es correcto.
	draw_rect(Rect2(0.5, 0.5, tamano.x - 1, tamano.y - 1), COLOR_BORDE, false, 1.0)
	# Tablero de 1 px en un tile: con filtro Nearest no se ve gris, se ven píxeles alternados.
	for y in TAMANO_TILE:
		for x in TAMANO_TILE:
			if (x + y) % 2 == 0:
				draw_rect(Rect2(TAMANO_TILE + x, TAMANO_TILE + y, 1, 1), COLOR_MARCA)

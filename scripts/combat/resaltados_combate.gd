class_name ResaltadosCombate
extends Node2D
## Resaltados del combate sobre el suelo (debajo de los actores): casilla del actor activo y, cuando
## le toca decidir al jugador, alcance de movimiento por cantidad de Zancadas (1, 2 o 3 acciones),
## camino completo hasta el cursor con su costo (◆◆) y enemigos golpeables (◆ al pasar el cursor).
## Lee el estado del ControladorCombate (su padre); no decide nada.

const COLOR_ACTIVO: Color = Color(1.0, 0.85, 0.3, 0.5)
## Alcance según las acciones que cuesta llegar: índice = cantidad de Zancadas.
const COLOR_POR_ZANCADAS: Array[Color] = [
	Color.TRANSPARENT,
	Color(0.3, 0.6, 1.0, 0.22),
	Color(0.3, 0.85, 0.7, 0.18),
	Color(0.7, 0.45, 1.0, 0.15),
]
const COLOR_CAMINO: Color = Color(0.4, 0.75, 1.0, 0.5)
const COLOR_OBJETIVO: Color = Color(1.0, 0.25, 0.25, 0.45)
const COLOR_COSTO: Color = Color(1.0, 0.95, 0.6)
const PIP_ACCION: String = "◆"
const TAMANO_FUENTE_COSTO: int = 12
## Altura sobre el centro de la casilla donde se muestra el costo.
const ALTURA_COSTO: float = 40.0
const ANCHO_COSTO: float = 60.0

var controlador: ControladorCombate


func _ready() -> void:
	# Mismo z que el suelo y después en el árbol: se dibuja encima del suelo y debajo de los actores.
	z_as_relative = false
	z_index = -1


func _draw() -> void:
	if controlador == null or not controlador.en_curso():
		return
	var combate: Combate = controlador.combate()
	var actor: Combatiente = combate.turno_actual()
	_rombo(actor.celda, COLOR_ACTIVO)
	if not controlador.esperando_decision():
		return
	var alcance: Dictionary[Vector2i, int] = controlador.alcance_actual()
	for casilla: Vector2i in alcance:
		_rombo(casilla, COLOR_POR_ZANCADAS[alcance[casilla]])
	var cursor: Vector2i = controlador.celda_cursor()
	for casilla: Vector2i in controlador.camino_previsto(cursor):
		_rombo(casilla, COLOR_CAMINO)
	var arma: DefinicionArma = actor.arma_principal()
	for c: Combatiente in combate.participantes:
		if arma != null and Golpe.validar(actor, c, arma, combate.vision()) == Golpe.Motivo.VALIDO:
			_rombo(c.celda, COLOR_OBJETIVO)
	var costo: int = controlador.costo_previsto(cursor)
	if costo > 0:
		_texto_costo(cursor, PIP_ACCION.repeat(costo))


func _rombo(celda: Vector2i, color: Color) -> void:
	var local: PackedVector2Array = PackedVector2Array()
	for punto: Vector2 in controlador.rombo_global(celda):
		local.append(to_local(punto))
	draw_colored_polygon(local, color)


func _texto_costo(celda: Vector2i, texto: String) -> void:
	var fuente: Font = ThemeDB.fallback_font
	var posicion: Vector2 = to_local(controlador.centro_global(celda)) + Vector2(-ANCHO_COSTO / 2.0, -ALTURA_COSTO)
	draw_string_outline(fuente, posicion, texto, HORIZONTAL_ALIGNMENT_CENTER, ANCHO_COSTO, TAMANO_FUENTE_COSTO, 3, Color.BLACK)
	draw_string(fuente, posicion, texto, HORIZONTAL_ALIGNMENT_CENTER, ANCHO_COSTO, TAMANO_FUENTE_COSTO, COLOR_COSTO)

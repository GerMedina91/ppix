class_name ResaltadosCombate
extends Node2D
## Resaltados del combate sobre el suelo (debajo de los actores): casilla del actor activo y, cuando
## le toca decidir al jugador, alcance de movimiento por cantidad de Zancadas (1, 2 o 3 acciones),
## camino completo hasta el cursor con su costo (◆◆) y enemigos golpeables (◆ al pasar el cursor).
## Lee el estado del ControladorCombate (su padre); no decide nada.

const PIP_ACCION: String = "◆"
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
	var estilo: EstiloHud = controlador.estilo()
	_rombo(controlador.combate().turno_actual().celda, estilo.resaltado_activo)
	# Todo sale de la previsión de la decisión en curso: acá solo se consulta.
	var prevision: PrevisionTurno = controlador.prevision_actual()
	if prevision == null:
		return
	var modo: ModoAccion = controlador.modo_accion()
	if modo.hay_eleccion():
		var actor: Combatiente = controlador.combate().turno_actual()
		for casilla: Vector2i in modo.casillas_movimiento:
			_rombo(casilla, estilo.resaltado_conjuro_movimiento)
		for casilla: Vector2i in modo.casillas_area(controlador.combate(), actor):
			_rombo(casilla, estilo.resaltado_conjuro_area)
		for c: Combatiente in modo.objetivos(controlador.combate(), actor):
			_rombo(c.celda, estilo.resaltado_conjuro_aliado if c.es_aliado_de(actor) else estilo.resaltado_conjuro_oponente)
		return
	var alcance: Dictionary[Vector2i, int] = prevision.por_casilla
	for casilla: Vector2i in alcance:
		_rombo(casilla, estilo.color_zancadas(alcance[casilla]))
	var cursor: Vector2i = controlador.celda_cursor()
	for casilla: Vector2i in prevision.camino(cursor):
		_rombo(casilla, estilo.resaltado_camino)
	for casilla: Vector2i in prevision.golpeables:
		_rombo(casilla, estilo.resaltado_objetivo)
	var costo: int = prevision.costo(cursor)
	if costo > 0:
		_texto_costo(cursor, PIP_ACCION.repeat(costo))


func _rombo(celda: Vector2i, color: Color) -> void:
	var local: PackedVector2Array = PackedVector2Array()
	for punto: Vector2 in controlador.rombo_global(celda):
		local.append(to_local(punto))
	draw_colored_polygon(local, color)


func _texto_costo(celda: Vector2i, texto: String) -> void:
	var estilo: EstiloHud = controlador.estilo()
	var fuente: Font = estilo.fuente_efectiva()
	var posicion: Vector2 = to_local(controlador.centro_global(celda)) + Vector2(-ANCHO_COSTO / 2.0, -ALTURA_COSTO)
	draw_string_outline(fuente, posicion, texto, HORIZONTAL_ALIGNMENT_CENTER, ANCHO_COSTO, estilo.tamano_costo, estilo.borde_texto, estilo.color_borde_texto)
	draw_string(fuente, posicion, texto, HORIZONTAL_ALIGNMENT_CENTER, ANCHO_COSTO, estilo.tamano_costo, estilo.color_costo)

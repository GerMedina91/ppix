class_name ResaltadosCombate
extends Node2D
## Resaltados del combate sobre el suelo (debajo de los actores): casilla del actor activo y, cuando
## le toca decidir al jugador, alcance de la Zancada, camino hasta el cursor y enemigos golpeables.
## Lee el estado del ControladorCombate (su padre); no decide nada.

const COLOR_ACTIVO: Color = Color(1.0, 0.85, 0.3, 0.5)
const COLOR_ZANCADA: Color = Color(0.3, 0.6, 1.0, 0.18)
const COLOR_CAMINO: Color = Color(0.4, 0.75, 1.0, 0.5)
const COLOR_OBJETIVO: Color = Color(1.0, 0.25, 0.25, 0.45)

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
	var zancada: Dictionary[Vector2i, int] = controlador.casillas_de_zancada_actuales()
	for casilla: Vector2i in zancada:
		_rombo(casilla, COLOR_ZANCADA)
	var cursor: Vector2i = controlador.celda_cursor()
	if zancada.has(cursor):
		for casilla: Vector2i in combate.camino_de_zancada(actor, cursor):
			_rombo(casilla, COLOR_CAMINO)
	var arma: DefinicionArma = actor.arma_principal()
	for c: Combatiente in combate.participantes:
		if arma != null and Golpe.validar(actor, c, arma, combate.vision()) == Golpe.Motivo.VALIDO:
			_rombo(c.celda, COLOR_OBJETIVO)


func _rombo(celda: Vector2i, color: Color) -> void:
	var local: PackedVector2Array = PackedVector2Array()
	for punto: Vector2 in controlador.rombo_global(celda):
		local.append(to_local(punto))
	draw_colored_polygon(local, color)

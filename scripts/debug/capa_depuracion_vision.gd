class_name CapaDepuracionVision
extends CapaDepuracion
## En combate: línea de visión del actor activo a la casilla bajo el cursor, con las casillas que
## atraviesa. Verde si hay línea; rojo si está bloqueada. Base para depurar cobertura (después de M3).

const COLOR_VISIBLE: Color = Color(0.3, 1.0, 0.4)
const COLOR_BLOQUEADA: Color = Color(1.0, 0.3, 0.3)
const COLOR_ATRAVESADA: Color = Color(1.0, 1.0, 1.0, 0.15)


func nombre() -> String:
	return "Línea de visión"


func dibujar(lienzo: OverlayDepuracion) -> void:
	var control: ControladorCombate = ControladorCombate.activo(lienzo.get_tree())
	if control == null or not control.en_curso():
		return
	var actor: Combatiente = control.combate().turno_actual()
	var destino: Vector2i = control.celda_cursor()
	if destino == actor.celda or not control.combate().grilla().region().has_point(destino):
		return
	var vision: LineaVision = control.combate().vision()
	for casilla: Vector2i in vision.casillas_atravesadas(actor.celda, destino):
		var opaca: bool = vision.es_opaca(casilla)
		lienzo.poligono_global(control.rombo_global(casilla), COLOR_BLOQUEADA if opaca else COLOR_ATRAVESADA,
			COLOR_BLOQUEADA * Color(1, 1, 1, 0.3) if opaca else Color.TRANSPARENT)
	var color: Color = COLOR_VISIBLE if vision.hay_linea(actor.celda, destino) else COLOR_BLOQUEADA
	lienzo.linea_global(control.centro_global(actor.celda), control.centro_global(destino), color)

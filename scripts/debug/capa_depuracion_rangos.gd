class_name CapaDepuracionRangos
extends CapaDepuracion
## En combate: casillas de Zancada del actor activo y alcance de su arma principal
## (cuerpo a cuerpo: su alcance; a distancia: el primer incremento, sin penalizador).
## Del alcance se dibuja solo el borde (casillas en alcance con alguna vecina fuera), para no tapar el mapa.

const COLOR_ZANCADA: Color = Color(0.3, 0.6, 1.0, 0.8)
const COLOR_ALCANCE: Color = Color(1.0, 0.6, 0.2, 0.9)
const _VECINAS: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
## Radio de búsqueda de casillas del alcance, en casillas (60 pies de incremento = 12).
const RADIO_MAXIMO: int = 24


func nombre() -> String:
	return "Rangos"


func dibujar(lienzo: OverlayDepuracion) -> void:
	var control: ControladorCombate = ControladorCombate.activo(lienzo.get_tree())
	if control == null or not control.en_curso():
		return
	var combate: Combate = control.combate()
	var actor: Combatiente = combate.turno_actual()
	for casilla: Vector2i in combate.casillas_de_zancada(actor):
		lienzo.poligono_global(control.rombo_global(casilla), COLOR_ZANCADA)
	var arma: DefinicionArma = actor.arma_principal()
	if arma == null:
		return
	var alcance: int = arma.incremento_rango_pies if arma.a_distancia else arma.alcance_pies
	var radio: int = mini(alcance / Medicion.PIES_POR_CASILLA + 1, RADIO_MAXIMO)
	for dx in range(-radio, radio + 1):
		for dy in range(-radio, radio + 1):
			var casilla: Vector2i = actor.celda + Vector2i(dx, dy)
			if Medicion.en_alcance(actor.celda, casilla, alcance) and _es_borde(actor.celda, casilla, alcance):
				lienzo.poligono_global(control.rombo_global(casilla), COLOR_ALCANCE)


static func _es_borde(origen: Vector2i, casilla: Vector2i, alcance: int) -> bool:
	return _VECINAS.any(func(v: Vector2i) -> bool:
		var vecina: Vector2i = casilla + v
		return vecina != origen and not Medicion.en_alcance(origen, vecina, alcance))

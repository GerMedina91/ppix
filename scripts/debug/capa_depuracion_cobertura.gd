class_name CapaDepuracionCobertura
extends CapaDepuracion
## En combate: la cobertura de cada criatura frente al actor activo (Cobertura), con la recta de centro a
## centro que la decide. Amarillo = menor, naranja = normal, rojo = mayor; gris = no se la puede apuntar
## (sin línea de visión). Sin color: sin cobertura.

const COLORES: Dictionary[Cobertura.Nivel, Color] = {
	Cobertura.Nivel.MENOR: Color(1.0, 0.95, 0.3), Cobertura.Nivel.NORMAL: Color(1.0, 0.6, 0.2),
	Cobertura.Nivel.MAYOR: Color(1.0, 0.25, 0.25),
}
const COLOR_SIN_LINEA: Color = Color(0.6, 0.6, 0.6)
const ALFA_RELLENO: float = 0.35


func nombre() -> String:
	return "Cobertura"


func dibujar(lienzo: OverlayDepuracion) -> void:
	var control: ControladorCombate = ControladorCombate.activo(lienzo.get_tree())
	if control == null or not control.en_curso():
		return
	var combate: Combate = control.combate()
	var actor: Combatiente = combate.turno_actual()
	for c: Combatiente in combate.participantes:
		if c == actor or c.condiciones.muerto:
			continue
		var color: Color = COLOR_SIN_LINEA
		if combate.vision().hay_linea(actor.celda, c.celda):
			var nivel: Cobertura.Nivel = Cobertura.de(actor, c, combate.participantes, combate.vision())
			if nivel == Cobertura.Nivel.NINGUNA:
				continue
			color = COLORES[nivel]
		lienzo.poligono_global(control.rombo_global(c.celda), color * Color(1, 1, 1, ALFA_RELLENO), color)
		lienzo.linea_global(control.centro_global(actor.celda), control.centro_global(c.celda), color)

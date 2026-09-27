class_name FichaCombatiente
extends PanelContainer
## Ficha del combatiente bajo el cursor (HUD, funcional y placeholder): nombre, condiciones y, si es de la
## party, sus PG (de los enemigos no se muestran números). Se actualiza sola al mover el cursor o cuando
## cambia lo que muestra. El aspecto sale del Theme del HUD.

var controlador: ControladorCombate
var _texto: Label
var _mostrado: String = ""


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_texto = Label.new()
	_texto.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_texto)
	visible = false


func _process(_delta: float) -> void:
	var texto: String = texto_para(controlador.celda_cursor()) if controlador.en_curso() else ""
	if texto == _mostrado:
		return
	_mostrado = texto
	_texto.text = texto
	visible = not texto.is_empty()


## Texto de la ficha para la casilla (vacío si no hay nadie vivo ahí).
func texto_para(celda: Vector2i) -> String:
	for c: Combatiente in controlador.combate().participantes:
		if c.celda == celda and not c.condiciones.muerto:
			return ficha(c)
	return ""


static func ficha(c: Combatiente) -> String:
	var lineas: PackedStringArray = PackedStringArray([FormatoRegistro.capitalizar(c.nombre_visible)])
	if c.bando == Combatiente.Bando.PARTY:
		lineas.append("PG %d/%d" % [c.pg, c.pg_maximos()])
	var condiciones: String = FormatoRegistro.condiciones_de(c)
	lineas.append(condiciones if not condiciones.is_empty() else "sin condiciones")
	if c.conocimiento.has("salvacion_debil"):
		lineas.append("Salvación más débil: %s (según %s)" % [
			Estadisticas.nombre_salvacion(c.conocimiento.salvacion_debil), c.conocimiento.segun])
	return "\n".join(lineas)

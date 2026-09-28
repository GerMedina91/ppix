class_name FichaCombatiente
extends PanelContainer
## Ficha del combatiente bajo el cursor (HUD, funcional y placeholder): nombre, condiciones y, si es de la
## party, sus PG (de los enemigos no se muestran números), y su cobertura frente al que está en turno. Se actualiza sola al mover el cursor o cuando
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
			return ficha(c, controlador.combate())
	return ""


## Con `combate`: la cobertura de `c` frente al que está en turno (la previsualización del Golpe o del conjuro).
static func ficha(c: Combatiente, combate: Combate = null) -> String:
	var lineas: PackedStringArray = PackedStringArray([FormatoRegistro.capitalizar(c.nombre_visible)])
	if c.bando == Combatiente.Bando.PARTY:
		lineas.append("PG %d/%d" % [c.pg, c.pg_maximos()])
	var condiciones: String = FormatoRegistro.condiciones_de(c)
	lineas.append(condiciones if not condiciones.is_empty() else "sin condiciones")
	if c.conocimiento.has("salvacion_debil"):
		lineas.append("Salvación más débil: %s (según %s)" % [
			Estadisticas.nombre_salvacion(c.conocimiento.salvacion_debil), c.conocimiento.segun])
	if c.tomando_cobertura:
		lineas.append("A cubierto (Tomar cobertura)")
	var actor: Combatiente = combate.turno_actual() if combate != null else null
	if actor != null and actor != c:
		var nivel: Cobertura.Nivel = Cobertura.de(actor, c, combate.participantes, combate.vision())
		if nivel != Cobertura.Nivel.NINGUNA:
			var texto: String = Cobertura.texto(nivel)
			lineas.append("%s%s frente a %s" % [texto.left(1).to_upper(), texto.substr(1), actor.nombre_visible])
	return "\n".join(lineas)

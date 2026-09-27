class_name PantallaRecuerdos
extends CanvasLayer
## Recuerdos del Eco y diario (GDD 4.2; funcional, placeholder). Solo fuera de combate.
## - Recuerdos: capacidad de integrados de destreza; los integrados, con Soltar (se pierde para siempre: pide
##   confirmación); los sueltos, con Integrar (destreza) o Ver (vivencia o fragmento del Doliente: se consume y
##   pasa al diario). Lo que no se puede, en gris con el motivo.
## - Diario: lo visto; al elegir uno se lee su texto.
## Las reglas están en InventarioRecuerdos (rules/). Esc o click derecho (`cancelar_accion`) cierra.

signal cerrada

enum Pestana { RECUERDOS, DIARIO }

@export var estilo: EstiloHud
@export var config: ConfigRecuerdos

var _eco: MiembroParty
var _pestana: Pestana = Pestana.RECUERDOS
var _por_soltar: DefinicionRecuerdo
var _contenido: VBoxContainer
var _mensaje: Label
var _detalle: Label


func _ready() -> void:
	layer = 6
	var columna: VBoxContainer = ConstruccionUi.panel_centrado(ConstruccionUi.raiz(self, estilo), 480, 0.45)
	columna.add_child(ConstruccionUi.titulo("Recuerdos del Eco", estilo))
	var pestanas: HBoxContainer = HBoxContainer.new()
	pestanas.add_child(ConstruccionUi.boton("Recuerdos", mostrar.bind(Pestana.RECUERDOS)))
	pestanas.add_child(ConstruccionUi.boton("Diario", mostrar.bind(Pestana.DIARIO)))
	columna.add_child(pestanas)
	_contenido = VBoxContainer.new()
	columna.add_child(_contenido)
	_detalle = ConstruccionUi.etiqueta("")
	_detalle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	columna.add_child(_detalle)
	_mensaje = ConstruccionUi.etiqueta("")
	columna.add_child(_mensaje)
	columna.add_child(ConstruccionUi.boton("Cerrar (Esc)", cerrar))
	visible = false


func abierta() -> bool:
	return visible


func abrir(eco: MiembroParty) -> void:
	_eco = eco
	_por_soltar = null
	_mensaje.text = ""
	_detalle.text = ""
	mostrar(Pestana.RECUERDOS)
	visible = true


func cerrar() -> void:
	if visible:
		visible = false
		cerrada.emit()


func mostrar(pestana: Pestana) -> void:
	_pestana = pestana
	_detalle.text = ""
	actualizar()


func integrar(recuerdo: DefinicionRecuerdo) -> void:
	var motivo: String = _inventario().motivo_no_integrable(recuerdo, _eco.definicion_de_reglas(), _capacidad())
	if motivo != "":
		_mensaje.text = motivo
		return
	_inventario().integrar(recuerdo)
	EventBus.cambio_irreversible.emit("recuerdo visto" if recuerdo.se_ve() else "recuerdo integrado")
	if recuerdo.se_ve():
		_mensaje.text = "Visto: %s (quedó en el diario)" % recuerdo.nombre
		_pestana = Pestana.DIARIO
		actualizar()
		leer(recuerdo)
		return
	_mensaje.text = "Integrado: %s" % recuerdo.nombre
	actualizar()


## Primer click: pide confirmación; con `confirmado`, lo suelta (se pierde para siempre).
func soltar(recuerdo: DefinicionRecuerdo, confirmado: bool = false) -> void:
	if not confirmado:
		_por_soltar = recuerdo
	else:
		_inventario().soltar_integrado(recuerdo)
		EventBus.cambio_irreversible.emit("recuerdo soltado")
		_por_soltar = null
		_mensaje.text = "Soltaste %s: se perdió para siempre" % recuerdo.nombre
	actualizar()


func leer(recuerdo: DefinicionRecuerdo) -> void:
	_detalle.text = "%s\n%s" % [recuerdo.nombre, recuerdo.texto]


func actualizar() -> void:
	ConstruccionUi.vaciar(_contenido)
	if _pestana == Pestana.DIARIO:
		_llenar_diario()
	else:
		_llenar_recuerdos()


## Textos de los botones del contenido, en orden (para tests y capturas).
func botones() -> PackedStringArray:
	return ConstruccionUi.textos_de_botones(_contenido)


func mensaje() -> String:
	return _mensaje.text


func detalle() -> String:
	return _detalle.text


func _llenar_recuerdos() -> void:
	var inventario: InventarioRecuerdos = _inventario()
	var gris: Color = _estilo().color_ayuda
	_contenido.add_child(ConstruccionUi.etiqueta("Integrados de destreza: %d/%d" % [inventario.integrados_de_destreza(), _capacidad()], gris))
	for recuerdo: DefinicionRecuerdo in inventario.integrados:
		var controles: Array[Control] = []
		if recuerdo == _por_soltar:
			controles.append(ConstruccionUi.boton("Confirmar: se pierde para siempre", soltar.bind(recuerdo, true)))
			controles.append(ConstruccionUi.boton("No", _cancelar_soltar))
		else:
			controles.append(ConstruccionUi.boton("Soltar", soltar.bind(recuerdo)))
		_contenido.add_child(ConstruccionUi.fila("%s: %s" % [recuerdo.nombre, recuerdo.beneficio.descripcion()], controles))
	_contenido.add_child(ConstruccionUi.etiqueta("Sueltos:", gris))
	if inventario.sueltos.is_empty():
		_contenido.add_child(ConstruccionUi.etiqueta("(ninguno)"))
	var eco: DefinicionPersonaje = _eco.definicion_de_reglas()
	for recuerdo: DefinicionRecuerdo in inventario.sueltos:
		var motivo: String = inventario.motivo_no_integrable(recuerdo, eco, _capacidad())
		var boton: Button = ConstruccionUi.boton("Ver" if recuerdo.se_ve() else "Integrar", integrar.bind(recuerdo), motivo)
		_contenido.add_child(ConstruccionUi.fila(PantallaTasador._descripcion(recuerdo), [boton]))


func _llenar_diario() -> void:
	var vistos: Array[DefinicionRecuerdo] = _inventario().vistos
	if vistos.is_empty():
		_contenido.add_child(ConstruccionUi.etiqueta("(todavía no viste ningún recuerdo)"))
	for recuerdo: DefinicionRecuerdo in vistos:
		_contenido.add_child(ConstruccionUi.boton(recuerdo.nombre, leer.bind(recuerdo)))


func _cancelar_soltar() -> void:
	_por_soltar = null
	actualizar()


func _capacidad() -> int:
	return config.capacidad(_eco.definicion_de_reglas().nivel)


func _inventario() -> InventarioRecuerdos:
	return GameState.recuerdos.inventario


func _estilo() -> EstiloHud:
	return estilo if estilo != null else EstiloHud.por_defecto()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed(&"cancelar_accion"):
		cerrar()
		get_viewport().set_input_as_handled()

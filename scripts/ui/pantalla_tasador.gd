class_name PantallaTasador
extends CanvasLayer
## Trueque con el Tasador (GDD 4.2; funcional, placeholder): su stock con precio y Comprar, y los recuerdos
## sueltos del Eco con lo que acredita cada uno y Vender. Lo que no se puede, en gris con el motivo. Las
## reglas están en Tasador (rules/). Esc o click derecho (`cancelar_accion`) cierra.

signal cerrada
## Botón "Hablar": una charla con el Tasador (después de la presentación).
signal hablar_pedido

const TITULO: String = "Tasador"
const NOMBRES_TIPO: Dictionary[DefinicionRecuerdo.Tipo, String] = {
	DefinicionRecuerdo.Tipo.DESTREZA: "destreza", DefinicionRecuerdo.Tipo.VIVENCIA: "vivencia",
	DefinicionRecuerdo.Tipo.DOLIENTE: "del Doliente",
}

@export var estilo: EstiloHud
@export var config: ConfigRecuerdos

var _credito: Label
var _stock: VBoxContainer
var _sueltos: VBoxContainer
var _mensaje: Label


func _ready() -> void:
	layer = 6
	var columna: VBoxContainer = ConstruccionUi.panel_centrado(ConstruccionUi.raiz(self, estilo), 460, 0.45)
	columna.add_child(ConstruccionUi.titulo(TITULO, estilo))
	_credito = ConstruccionUi.etiqueta("")
	columna.add_child(_credito)
	columna.add_child(ConstruccionUi.etiqueta("Vende:", _color_seccion()))
	_stock = VBoxContainer.new()
	columna.add_child(_stock)
	columna.add_child(ConstruccionUi.etiqueta("Tus recuerdos sueltos:", _color_seccion()))
	_sueltos = VBoxContainer.new()
	columna.add_child(_sueltos)
	_mensaje = ConstruccionUi.etiqueta("")
	columna.add_child(_mensaje)
	var botones: HBoxContainer = HBoxContainer.new()
	botones.add_child(ConstruccionUi.boton("Hablar", func() -> void: hablar_pedido.emit()))
	botones.add_child(ConstruccionUi.boton("Cerrar (Esc)", cerrar))
	columna.add_child(botones)
	visible = false


func abierta() -> bool:
	return visible


func abrir() -> void:
	_mensaje.text = ""
	actualizar()
	visible = true


func cerrar() -> void:
	if visible:
		visible = false
		cerrada.emit()


func comprar(indice: int) -> void:
	var nombre: String = _tasador().stock[indice].recuerdo.nombre
	var motivo: String = _tasador().comprar(indice, GameState.recuerdos.inventario, config)
	_mensaje.text = "Compraste: %s" % nombre if motivo == "" else motivo
	if motivo == "":
		EventBus.cambio_irreversible.emit("compra al Tasador")
	actualizar()


func vender(recuerdo: DefinicionRecuerdo) -> void:
	var credito: int = _tasador().precio_compra(recuerdo, config)
	var motivo: String = _tasador().vender(recuerdo, GameState.recuerdos.inventario, config)
	_mensaje.text = "Vendiste %s (+%d de crédito)" % [recuerdo.nombre, credito] if motivo == "" else motivo
	if motivo == "":
		EventBus.cambio_irreversible.emit("venta al Tasador")
	actualizar()


func actualizar() -> void:
	var tasador: Tasador = _tasador()
	var inventario: InventarioRecuerdos = GameState.recuerdos.inventario
	_credito.text = "Crédito: %d" % tasador.credito
	ConstruccionUi.vaciar(_stock)
	for i in tasador.stock.size():
		var entrada: Tasador.Entrada = tasador.stock[i]
		var boton: Button = ConstruccionUi.boton("Comprar (%d)" % tasador.precio_venta(entrada, config), comprar.bind(i),
			tasador.motivo_compra(i, config))
		_stock.add_child(ConstruccionUi.fila(_descripcion(entrada.recuerdo), [boton]))
	ConstruccionUi.vaciar(_sueltos)
	if inventario.sueltos.is_empty():
		_sueltos.add_child(ConstruccionUi.etiqueta("(ninguno)"))
	for recuerdo: DefinicionRecuerdo in inventario.sueltos:
		var boton: Button = ConstruccionUi.boton("Vender (+%d)" % tasador.precio_compra(recuerdo, config), vender.bind(recuerdo),
			tasador.motivo_venta(recuerdo, inventario))
		_sueltos.add_child(ConstruccionUi.fila(_descripcion(recuerdo), [boton]))


## Textos de los botones, en orden (para tests y capturas).
func botones() -> PackedStringArray:
	return ConstruccionUi.textos_de_botones(_stock) + ConstruccionUi.textos_de_botones(_sueltos)


func mensaje() -> String:
	return _mensaje.text


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed(&"cancelar_accion"):
		cerrar()
		get_viewport().set_input_as_handled()


static func _descripcion(recuerdo: DefinicionRecuerdo) -> String:
	return "%s (%s)" % [recuerdo.nombre, NOMBRES_TIPO[recuerdo.tipo]]


func _tasador() -> Tasador:
	return GameState.recuerdos.tasador


func _color_seccion() -> Color:
	return (estilo if estilo != null else EstiloHud.por_defecto()).color_ayuda

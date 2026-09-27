class_name Tasador
extends RefCounted
## El Tasador (GDD 4.2): trueque de recuerdos. Venderle un recuerdo acredita el porcentaje de compra de su
## valor (50 %) en un crédito con él; comprarle cuesta el precio de venta (100 %, más el recargo de los que
## vinieron de un residuo perdido). Lo que se le vende entra a su stock. Los del Doliente no se le venden.

class Entrada:
	var recuerdo: DefinicionRecuerdo
	## Recargo en porcentaje sobre el precio de venta (residuos perdidos del Eco).
	var recargo: int = 0

	func _init(r: DefinicionRecuerdo, porcentaje_recargo: int = 0) -> void:
		recuerdo = r
		recargo = porcentaje_recargo

var stock: Array[Entrada] = []
var credito: int = 0


func agregar_al_stock(recuerdo: DefinicionRecuerdo, recargo: int = 0) -> void:
	stock.append(Entrada.new(recuerdo, recargo))


## Lo que acredita por un recuerdo (redondeando hacia abajo).
func precio_compra(recuerdo: DefinicionRecuerdo, config: ConfigRecuerdos) -> int:
	return recuerdo.valor * config.porcentaje_compra / 100


## Lo que cuesta una entrada del stock.
func precio_venta(entrada: Entrada, config: ConfigRecuerdos) -> int:
	return con_recargo(entrada.recuerdo.valor * config.porcentaje_venta / 100, entrada.recargo)


static func con_recargo(precio: int, recargo: int) -> int:
	return precio + precio * recargo / 100


## Le vende al Tasador un recuerdo suelto del inventario ("" si pudo; si no, el motivo).
func vender(recuerdo: DefinicionRecuerdo, inventario: InventarioRecuerdos, config: ConfigRecuerdos) -> String:
	if not recuerdo.vendible():
		return "ese recuerdo no se vende"
	if not inventario.quitar_suelto(recuerdo):
		return "no lo tenés suelto"
	credito += precio_compra(recuerdo, config)
	agregar_al_stock(recuerdo)
	return ""


## Le compra al Tasador la entrada `indice` del stock con el crédito ("" si pudo; si no, el motivo).
func comprar(indice: int, inventario: InventarioRecuerdos, config: ConfigRecuerdos) -> String:
	if indice < 0 or indice >= stock.size():
		return "no está en el stock"
	var precio: int = precio_venta(stock[indice], config)
	if precio > credito:
		return "crédito insuficiente (%d de %d)" % [credito, precio]
	credito -= precio
	inventario.agregar_suelto(stock[indice].recuerdo)
	stock.remove_at(indice)
	return ""


func a_diccionario() -> Dictionary:
	var entradas: Array = []
	for e: Entrada in stock:
		entradas.append({"id": String(e.recuerdo.id), "recargo": e.recargo})
	return {"stock": entradas, "credito": credito}


static func desde_diccionario(datos: Dictionary, catalogo: CatalogoRecuerdos) -> Tasador:
	var tasador: Tasador = Tasador.new()
	tasador.credito = datos.get("credito", 0)
	for e: Dictionary in datos.get("stock", []):
		var recuerdo: DefinicionRecuerdo = catalogo.buscar(StringName(e.id))
		if recuerdo != null:
			tasador.agregar_al_stock(recuerdo, e.get("recargo", 0))
	return tasador

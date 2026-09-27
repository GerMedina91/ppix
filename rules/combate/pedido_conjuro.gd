class_name PedidoConjuro
extends RefCounted
## Lo que pide quien lanza: qué conjuro, sobre quién o hacia dónde, y con cuántas acciones (conjuros de
## costo variable). AccionesConjuro lo valida y lo resuelve.

const SIN_CELDA: Vector2i = Vector2i(-1000000, -1000000)

var conjuro: DefinicionConjuro
var objetivo: StringName = &""
## Movimiento incluido (Pies ágiles): destino, recorrido opcional y si es un Paso.
var destino: Vector2i = SIN_CELDA
var recorrido: Array[Vector2i] = []
var es_paso: bool = false
## Acciones elegidas en un conjuro de costo variable (0 = las de siempre).
var acciones: int = 0


func _init(conjuro_pedido: DefinicionConjuro, id_objetivo: StringName = &"", cantidad_acciones: int = 0) -> void:
	conjuro = conjuro_pedido
	objetivo = id_objetivo
	acciones = cantidad_acciones


## Acciones que cuesta (0 si es de costo variable y no se eligió una forma válida).
func costo() -> int:
	if not conjuro.es_variable():
		return conjuro.acciones
	return acciones if conjuro.variante(acciones) != null else 0


## Forma elegida (null si el conjuro no es de costo variable).
func variante() -> VarianteConjuro:
	return conjuro.variante(acciones)


func tiene(rasgo: DefinicionConjuro.Rasgo) -> bool:
	return conjuro.rasgos_con(acciones).has(rasgo)


func es_area() -> bool:
	return variante() != null and variante().es_area()

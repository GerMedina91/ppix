class_name Modificador
extends RefCounted
## Bonificador (valor > 0) o penalizador (valor < 0) con tipo (por circunstancia, de estatus, de objeto),
## para apilar según las reglas (ver SumaModificadores). Los bonificadores siempre tienen tipo; solo los
## penalizadores pueden ser sin tipo. `fuente` es para mostrar el desglose (p. ej. "Flanqueado").
## El modificador de atributo y el bonificador por competencia no son Modificadores:
## se suman aparte, siempre.

enum Tipo { SIN_TIPO, CIRCUNSTANCIA, ESTATUS, OBJETO }

var valor: int = 0
var tipo: Tipo = Tipo.SIN_TIPO
var fuente: String = ""


## Un modificador inválido (p. ej. un bonificador sin tipo) se informa con push_error y se anula (valor 0).
func _init(valor_modificador: int, tipo_modificador: Tipo, fuente_modificador: String) -> void:
	tipo = tipo_modificador
	fuente = fuente_modificador
	var error: String = error_de_datos(valor_modificador, tipo_modificador, fuente_modificador)
	if error.is_empty():
		valor = valor_modificador
	else:
		push_error(error)


## Mensaje de error si la combinación no es válida según las reglas; vacío si es válida.
static func error_de_datos(valor_modificador: int, tipo_modificador: Tipo, fuente_modificador: String) -> String:
	if tipo_modificador == Tipo.SIN_TIPO and valor_modificador > 0:
		return "Modificador: no existen bonificadores sin tipo (%s)" % fuente_modificador
	return ""


func es_bonificador() -> bool:
	return valor > 0


func es_penalizador() -> bool:
	return valor < 0


func _to_string() -> String:
	return "%+d %s (%s)" % [valor, Tipo.keys()[tipo].to_lower(), fuente]

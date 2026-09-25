class_name Modificador
extends RefCounted
## Bonificador (valor > 0) o penalizador (valor < 0) con tipo, para apilar según las reglas
## (ver SumaModificadores). Los bonificadores siempre tienen tipo; solo los penalizadores
## pueden ser sin tipo. `fuente` es para mostrar el desglose (p. ej. "Flanqueado").
## El modificador de atributo y el bonificador por competencia no son Modificadores:
## se suman aparte, siempre.

enum Tipo { SIN_TIPO, CIRCUNSTANCIA, ESTADO, OBJETO }

var valor: int = 0
var tipo: Tipo = Tipo.SIN_TIPO
var fuente: String = ""


func _init(valor_modificador: int, tipo_modificador: Tipo, fuente_modificador: String) -> void:
	assert(not (tipo_modificador == Tipo.SIN_TIPO and valor_modificador > 0),
		"Modificador: no existen bonificadores sin tipo (%s)" % fuente_modificador)
	valor = valor_modificador
	tipo = tipo_modificador
	fuente = fuente_modificador


func es_bonificador() -> bool:
	return valor > 0


func es_penalizador() -> bool:
	return valor < 0


func _to_string() -> String:
	return "%+d %s (%s)" % [valor, Tipo.keys()[tipo].to_lower(), fuente]

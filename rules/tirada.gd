class_name Tirada
extends RefCounted
## Expresión de dados del tipo "2d6+3": cantidad de dados, caras y modificador fijo.

const _PATRON: String = r"^(\d+)d(\d+)([+-]\d+)?$"

var cantidad: int = 1
var caras: int = 20
var modificador: int = 0


func _init(cantidad_dados: int, caras_dado: int, modificador_fijo: int = 0) -> void:
	assert(cantidad_dados >= 1 and caras_dado >= 1, "Tirada: cantidad y caras tienen que ser >= 1")
	cantidad = cantidad_dados
	caras = caras_dado
	modificador = modificador_fijo


## Interpreta un texto como "1d20", "2d6+3" o "1d8-1". Devuelve null si no es válido.
static func desde_texto(texto: String) -> Tirada:
	var regex: RegEx = RegEx.create_from_string(_PATRON)
	var coincidencia: RegExMatch = regex.search(texto.strip_edges().to_lower())
	if coincidencia == null:
		return null
	var cantidad_dados: int = coincidencia.get_string(1).to_int()
	var caras_dado: int = coincidencia.get_string(2).to_int()
	if cantidad_dados < 1 or caras_dado < 1:
		return null
	return Tirada.new(cantidad_dados, caras_dado, coincidencia.get_string(3).to_int())


func tirar(dados: Dados) -> ResultadoTirada:
	return ResultadoTirada.new(dados.tirar_varios(cantidad, caras), modificador)


func minimo() -> int:
	return cantidad + modificador


func maximo() -> int:
	return cantidad * caras + modificador


func _to_string() -> String:
	var texto: String = "%dd%d" % [cantidad, caras]
	if modificador != 0:
		texto += "%+d" % modificador
	return texto

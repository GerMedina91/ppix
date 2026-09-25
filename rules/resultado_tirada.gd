class_name ResultadoTirada
extends RefCounted
## Resultado de una Tirada: cada dado por separado más el modificador fijo.

var dados: Array[int] = []
var modificador: int = 0


func _init(resultados: Array[int], modificador_fijo: int) -> void:
	dados = resultados
	modificador = modificador_fijo


func total() -> int:
	var suma: int = modificador
	for valor: int in dados:
		suma += valor
	return suma

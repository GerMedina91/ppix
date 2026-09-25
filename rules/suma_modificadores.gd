class_name SumaModificadores
extends RefCounted
## Apilamiento de bonificadores y penalizadores de PF2e:
## - Del mismo tipo (por circunstancia, de estatus, de objeto) solo aplica el mayor bonificador y el peor penalizador.
## - Bonificadores y penalizadores de distinto tipo se suman.
## - Los penalizadores sin tipo se suman todos.
## - Los modificadores de valor 0 no aplican.


## Los modificadores que efectivamente aplican (para el desglose), en el orden en que llegaron.
static func aplicados(modificadores: Array[Modificador]) -> Array[Modificador]:
	var elegidos: Dictionary[Modificador, bool] = {}
	var mejor_bonificador: Dictionary[Modificador.Tipo, Modificador] = {}
	var peor_penalizador: Dictionary[Modificador.Tipo, Modificador] = {}
	for modificador: Modificador in modificadores:
		if modificador.es_penalizador() and modificador.tipo == Modificador.Tipo.SIN_TIPO:
			elegidos[modificador] = true
		elif modificador.es_bonificador():
			var actual: Modificador = mejor_bonificador.get(modificador.tipo)
			if actual == null or modificador.valor > actual.valor:
				mejor_bonificador[modificador.tipo] = modificador
		elif modificador.es_penalizador():
			var actual: Modificador = peor_penalizador.get(modificador.tipo)
			if actual == null or modificador.valor < actual.valor:
				peor_penalizador[modificador.tipo] = modificador
	for modificador: Modificador in mejor_bonificador.values() + peor_penalizador.values():
		elegidos[modificador] = true
	return modificadores.filter(func(m: Modificador) -> bool: return elegidos.has(m))


static func total(modificadores: Array[Modificador]) -> int:
	var suma: int = 0
	for modificador: Modificador in aplicados(modificadores):
		suma += modificador.valor
	return suma

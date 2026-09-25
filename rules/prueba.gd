class_name Prueba
extends RefCounted
## Prueba de PF2e: d20 + modificador de atributo + bonificador por competencia + modificadores
## apilados según las reglas (SumaModificadores), contra una CD.
##
## Fortuna: se tira dos veces y se usa el mejor resultado. Infortunio: el peor.
## Si hay fortuna e infortunio a la vez, se cancelan y se tira una sola vez.
## El valor natural que decide el ajuste por 20 o 1 es el del dado elegido.

## Una CD derivada de un modificador (p. ej. CD de Percepción o CD de clase) es 10 + ese modificador.
const BASE_CD: int = 10
const CARAS_D20: int = 20

var nombre: String = ""
var nombre_atributo: String = ""
var modificador_atributo: int = 0
var rango: Competencia.Rango = Competencia.Rango.NO_ENTRENADO
var nivel: int = 1
var modificadores: Array[Modificador] = []
var fortuna: bool = false
var infortunio: bool = false
## false en pruebas sin competencia (planas o con bonificador fijo de criatura): no se muestra en el desglose.
var usa_competencia: bool = true


func _init(nombre_prueba: String, atributo: String, valor_atributo: int, rango_competencia: Competencia.Rango, nivel_personaje: int) -> void:
	nombre = nombre_prueba
	nombre_atributo = atributo
	modificador_atributo = valor_atributo
	rango = rango_competencia
	nivel = nivel_personaje


## Prueba con un bonificador fijo en lugar de atributo + competencia (p. ej. el ataque de una criatura).
static func fija(nombre_prueba: String, fuente: String, bonificador: int) -> Prueba:
	var prueba: Prueba = Prueba.new(nombre_prueba, fuente, bonificador, Competencia.Rango.NO_ENTRENADO, 1)
	prueba.usa_competencia = false
	return prueba


## Prueba plana: solo el d20, sin modificadores (p. ej. la prueba de recuperación).
static func plana(nombre_prueba: String) -> Prueba:
	var prueba: Prueba = Prueba.new(nombre_prueba, "", 0, Competencia.Rango.NO_ENTRENADO, 1)
	prueba.usa_competencia = false
	return prueba


func bonificador_competencia() -> int:
	if not usa_competencia:
		return 0
	return Competencia.bonificador(rango, nivel)


## Todo lo que se suma al d20.
func modificador_total() -> int:
	return modificador_atributo + bonificador_competencia() + SumaModificadores.total(modificadores)


## CD que otros tienen que superar cuando esta prueba se usa como defensa (10 + modificador total).
func cd() -> int:
	return BASE_CD + modificador_total()


func resolver(dados: Dados, cd_objetivo: int) -> ResultadoPrueba:
	var resultado: ResultadoPrueba = ResultadoPrueba.new()
	resultado.tiradas.append(dados.tirar(CARAS_D20))
	if fortuna != infortunio:
		resultado.tiradas.append(dados.tirar(CARAS_D20))
	resultado.natural = _elegir(resultado.tiradas)
	resultado.desglose = desglose()
	resultado.total = resultado.natural + modificador_total()
	resultado.cd = cd_objetivo
	resultado.grado = GradoExito.calcular(resultado.total, cd_objetivo, resultado.natural)
	return resultado


## Partes que se suman al d20, para mostrarlas: atributo, competencia y modificadores que aplican.
func desglose() -> Array[Dictionary]:
	var partes: Array[Dictionary] = []
	if not nombre_atributo.is_empty():
		partes.append({"fuente": nombre_atributo, "valor": modificador_atributo})
	if usa_competencia:
		partes.append({"fuente": "competencia (%s)" % Competencia.nombre(rango), "valor": bonificador_competencia()})
	for modificador: Modificador in SumaModificadores.aplicados(modificadores):
		partes.append({"fuente": modificador.fuente, "valor": modificador.valor})
	return partes


func _elegir(tiradas: Array[int]) -> int:
	if tiradas.size() == 1:
		return tiradas[0]
	return tiradas.max() if fortuna else tiradas.min()

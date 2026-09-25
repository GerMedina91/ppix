class_name ResultadoPrueba
extends RefCounted
## Resultado de una Prueba contra una CD, con todo lo necesario para mostrar el desglose.

## Valores de d20 tirados: uno, o dos con fortuna o infortunio.
var tiradas: Array[int] = []
## El d20 elegido: es el que se suma y el que decide el ajuste por 20 o 1 natural.
var natural: int = 0
var total: int = 0
var cd: int = 0
var grado: GradoExito.Grado = GradoExito.Grado.FALLO
## Partes que se sumaron al d20: [{"fuente": String, "valor": int}], en orden.
var desglose: Array[Dictionary] = []

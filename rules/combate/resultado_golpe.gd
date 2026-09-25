class_name ResultadoGolpe
extends RefCounted
## Resultado de un Golpe. Si `motivo` no es VALIDO, el Golpe no se hizo (no gasta nada).

var motivo: Golpe.Motivo = Golpe.Motivo.VALIDO
var prueba: ResultadoPrueba
## El atacante flanqueaba al objetivo (objetivo desprevenido frente a él).
var flanqueando: bool = false
var tirada_danio: ResultadoTirada
var danio: int = 0
var critico: bool = false


func es_valido() -> bool:
	return motivo == Golpe.Motivo.VALIDO


func impacto() -> bool:
	return danio > 0

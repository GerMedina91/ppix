class_name ResultadoGolpe
extends RefCounted
## Resultado de un Golpe. Si `motivo` no es VALIDO, el Golpe no se hizo (no gasta nada).

var motivo: Golpe.Motivo = Golpe.Motivo.VALIDO
var prueba: ResultadoPrueba
## El atacante flanqueaba al objetivo (objetivo desprevenido frente a él).
var flanqueando: bool = false
var tirada_danio: ResultadoTirada
## Daño que recibió el objetivo (ya con debilidad y resistencia: puede ser 0 aunque haya acertado).
var danio: int = 0
## Tipo de daño con que golpeó (el elegido, si el arma es versátil).
var tipo_danio: DefinicionArma.TipoDanio = DefinicionArma.TipoDanio.CORTANTE
## Daño adicional de capacidades, antes de duplicar: [{"fuente": String, "tirada": ResultadoTirada}].
var danio_adicional: Array[Dictionary] = []
## Dado letal tirado en el crítico (ya sumado en `danio`; 0 si no hubo).
var danio_letal: int = 0
## Debilidad del objetivo al tipo de daño del arma, ya sumada a `danio`.
var debilidad: int = 0
## Resistencia del objetivo a ese tipo, ya restada de `danio`.
var resistencia: int = 0
## Cobertura del objetivo frente al atacante (ya sumada a la CA).
var cobertura: Cobertura.Nivel = Cobertura.Nivel.NINGUNA
var critico: bool = false
## Ataque no letal: a 0 PG deja inconsciente en vez de matar.
var no_letal: bool = false


func es_valido() -> bool:
	return motivo == Golpe.Motivo.VALIDO


## Hizo daño (para la animación).
func impacto() -> bool:
	return danio > 0


## Acertó (éxito o crítico), aunque la resistencia haya dejado el daño en 0.
func acerto() -> bool:
	return tirada_danio != null

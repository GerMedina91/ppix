class_name GradoExito
extends RefCounted
## Grados de éxito de PF2e (ver docs/GLOSARIO.md):
## - Éxito crítico: total >= CD + 10. Éxito: total >= CD. Fallo crítico: total <= CD - 10. Si no, fallo.
## - Un 20 natural mejora el resultado un grado; un 1 natural lo empeora un grado.

## Ordenados de peor a mejor: subir o bajar un grado es sumar o restar 1.
enum Grado { FALLO_CRITICO, FALLO, EXITO, EXITO_CRITICO }

const MARGEN_CRITICO: int = 10
const NATURAL_MAXIMO: int = 20
const NATURAL_MINIMO: int = 1

const _NOMBRES: Dictionary[Grado, String] = {
	Grado.FALLO_CRITICO: "fallo crítico",
	Grado.FALLO: "fallo",
	Grado.EXITO: "éxito",
	Grado.EXITO_CRITICO: "éxito crítico",
}


## `natural` es el valor del d20 que decide el ajuste (con fortuna o infortunio, el del dado elegido).
static func calcular(total: int, cd: int, natural: int) -> Grado:
	var grado: Grado = _por_total(total, cd)
	if natural == NATURAL_MAXIMO:
		grado = mejorar(grado)
	elif natural == NATURAL_MINIMO:
		grado = empeorar(grado)
	return grado


static func mejorar(grado: Grado) -> Grado:
	return mini(grado + 1, Grado.EXITO_CRITICO) as Grado


static func empeorar(grado: Grado) -> Grado:
	return maxi(grado - 1, Grado.FALLO_CRITICO) as Grado


static func nombre(grado: Grado) -> String:
	return _NOMBRES[grado]


static func _por_total(total: int, cd: int) -> Grado:
	if total >= cd + MARGEN_CRITICO:
		return Grado.EXITO_CRITICO
	if total >= cd:
		return Grado.EXITO
	if total <= cd - MARGEN_CRITICO:
		return Grado.FALLO_CRITICO
	return Grado.FALLO

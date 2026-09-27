class_name VarianteConjuro
extends Resource
## Una forma de un conjuro de costo variable según las acciones que se gastan (p. ej. Curar: 1 acción toque,
## 2 acciones 30 pies y +8, 3 acciones emanación de 30 pies; Player Core p. 335).

@export var acciones: int = 1
## Toque: alcance sin armas (casillas adyacentes). Si no, `alcance_pies`.
@export var toque: bool = false
@export var alcance_pies: int = 0
## > 0: emanación de ese radio desde el lanzador (afecta a todos los que corresponda dentro, con línea de
## efecto al lanzador); sin objetivo único.
@export var emanacion_pies: int = 0
## Rasgos que se suman con esta cantidad de acciones (p. ej. concentrar).
@export var rasgos_extra: Array[DefinicionConjuro.Rasgo] = []
@export var curacion_extra: int = 0


func es_area() -> bool:
	return emanacion_pies > 0


func errores_de_datos() -> PackedStringArray:
	var errores: PackedStringArray = PackedStringArray()
	if acciones < 1 or acciones > 3:
		errores.append("Variante de conjuro: de 1 a 3 acciones")
	if not toque and not es_area() and (alcance_pies <= 0 or alcance_pies % Medicion.PIES_POR_CASILLA != 0):
		errores.append("Variante de conjuro: necesita toque, alcance o emanación")
	return errores

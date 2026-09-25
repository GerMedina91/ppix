class_name DefinicionAscendencia
extends Resource
## Ascendencia: PG, Velocidad y mejoras de atributo (Player Core; ver docs/verificacion/c1_clases.md).
## Linaje y dote de ascendencia quedan para más adelante.

@export var id: StringName = &""
@export var nombre: String = ""
## PG que da la ascendencia (una sola vez).
@export var pg: int = 8
@export var velocidad_pies: int = 25
## Mejoras fijas (p. ej. otras ascendencias); el humano no tiene.
@export var mejoras_fijas: Array[Atributo.Tipo] = []
## Cantidad de mejoras libres (humano: 2).
@export var mejoras_libres: int = 0


func errores_de_datos() -> PackedStringArray:
	var errores: PackedStringArray = PackedStringArray()
	if pg <= 0:
		errores.append("Ascendencia %s: necesita PG" % nombre)
	if velocidad_pies <= 0 or velocidad_pies % Medicion.PIES_POR_CASILLA != 0:
		errores.append("Ascendencia %s: la Velocidad tiene que ser múltiplo de 5 pies" % nombre)
	return errores

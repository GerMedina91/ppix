class_name DefinicionAccionMiedo
extends Resource
## Acción de miedo de una criatura (rasgos auditivo, emoción, miedo y mental). Construida con el GM Core a partir del
## Gemido espantoso del Ghost Commoner (Monster Core p. 161); números y frecuencia en docs/verificacion/m5_criaturas.md.
## Cada enemigo vivo a `emanacion_pies` o menos, con línea de efecto, tira Voluntad contra `cd`: fallo, asustado
## `valor_fallo`; fallo crítico, asustado `valor_fallo_critico`. Sea cual sea el resultado, queda inmune a la acción
## de esa criatura el resto del combate (el "1 minuto" del bloque). Los inmunes a lo mental no la sufren.

@export var nombre: String = "TODO_LORE"
@export_range(1, 3) var acciones: int = 1
@export var emanacion_pies: int = 30
@export var cd: int = 18
@export var valor_fallo: int = 1
@export var valor_fallo_critico: int = 2


func errores_de_datos() -> PackedStringArray:
	var errores: PackedStringArray = PackedStringArray()
	if emanacion_pies < Medicion.PIES_POR_CASILLA or emanacion_pies % Medicion.PIES_POR_CASILLA != 0:
		errores.append("Acción de miedo %s: la emanación tiene que ser múltiplo de 5 pies" % nombre)
	if valor_fallo < 1 or valor_fallo_critico < valor_fallo:
		errores.append("Acción de miedo %s: valores de asustado no válidos" % nombre)
	return errores

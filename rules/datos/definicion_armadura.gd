class_name DefinicionArmadura
extends Resource
## Armadura: bonificador de objeto a la CA, tope de Destreza, categoría (para la competencia) y
## requisito de Fuerza con sus penalizadores (Player Core; ver docs/verificacion/c1_clases.md).

## SIN_ARMADURA se usa para la competencia "sin armadura" (no hay armaduras de esa categoría).
enum Categoria { SIN_ARMADURA, LIGERA, MEDIA, PESADA }

@export var id: StringName = &""
@export var nombre: String = "TODO_LORE"
@export var categoria: Categoria = Categoria.LIGERA
## Bonificador de objeto a la CA.
@export var bonificador_ca: int = 0
## Si es false, la armadura no limita la Destreza que se suma a la CA.
@export var tiene_tope_destreza: bool = true
@export var tope_destreza: int = 0
## Modificador de Fuerza desde el que no hay penalizador a pruebas y el de Velocidad baja 5 pies.
@export var requisito_fuerza: int = 0
## Penalizador a pruebas (número negativo o 0). Se aplica a partir de las habilidades (C1b).
@export var penalizador_pruebas: int = 0
## Penalizador a la Velocidad, en pies (número positivo o 0).
@export var penalizador_velocidad_pies: int = 0


func errores_de_datos() -> PackedStringArray:
	var errores: PackedStringArray = PackedStringArray()
	if bonificador_ca < 0:
		errores.append("Armadura %s: el bonificador de objeto a la CA no puede ser negativo (%d)" % [nombre, bonificador_ca])
	if tiene_tope_destreza and tope_destreza < 0:
		errores.append("Armadura %s: el tope de Destreza no puede ser negativo (%d)" % [nombre, tope_destreza])
	if categoria == Categoria.SIN_ARMADURA:
		errores.append("Armadura %s: SIN_ARMADURA es solo para la competencia" % nombre)
	if penalizador_pruebas > 0 or penalizador_velocidad_pies < 0 or penalizador_velocidad_pies % Medicion.PIES_POR_CASILLA != 0:
		errores.append("Armadura %s: penalizadores inválidos" % nombre)
	return errores

class_name DefinicionClase
extends Resource
## Clase a nivel 1: PG, atributo clave, competencias iniciales y habilidades (Player Core; números
## verificados en docs/verificacion/c1_clases.md). Lanzamiento y capacidades llegan en C2 a C4.

@export var id: StringName = &""
@export var nombre: String = ""
@export var pg_por_nivel: int = 8
## Opciones de atributo clave (la clase suma +1 al elegido).
@export var atributos_clave: Array[Atributo.Tipo] = []

@export_group("Competencias iniciales")
@export var percepcion: Competencia.Rango = Competencia.Rango.ENTRENADO
@export var fortaleza: Competencia.Rango = Competencia.Rango.ENTRENADO
@export var reflejos: Competencia.Rango = Competencia.Rango.ENTRENADO
@export var voluntad: Competencia.Rango = Competencia.Rango.ENTRENADO
@export var ataques: Dictionary[DefinicionArma.Categoria, Competencia.Rango] = {}
@export var defensas: Dictionary[DefinicionArmadura.Categoria, Competencia.Rango] = {}
@export var cd_clase: Competencia.Rango = Competencia.Rango.ENTRENADO
## Ataque y CD de conjuros (no entrenado en clases que no lanzan conjuros).
@export var conjuros: Competencia.Rango = Competencia.Rango.NO_ENTRENADO

@export_group("Habilidades")
## Entrenadas siempre (p. ej. Religión del clérigo, Sigilo del pícaro).
@export var habilidades_fijas: Array[Habilidad.Tipo] = []
## Hay que elegir una de estas (p. ej. Acrobacias o Atletismo del guerrero). Vacío = ninguna.
@export var habilidades_una_de: Array[Habilidad.Tipo] = []
## Habilidades libres además de las anteriores: este número + el modificador de Inteligencia.
@export var habilidades_libres_base: int = 0


func errores_de_datos() -> PackedStringArray:
	var errores: PackedStringArray = PackedStringArray()
	if pg_por_nivel <= 0:
		errores.append("Clase %s: necesita PG por nivel" % nombre)
	if atributos_clave.is_empty():
		errores.append("Clase %s: necesita al menos una opción de atributo clave" % nombre)
	if not defensas.has(DefinicionArmadura.Categoria.SIN_ARMADURA):
		errores.append("Clase %s: falta la competencia sin armadura" % nombre)
	return errores

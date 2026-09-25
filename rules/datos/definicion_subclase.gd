class_name DefinicionSubclase
extends Resource
## Base de las elecciones de clase de nivel 1 (tejemaneje, doctrina, patrón; la entidad del clérigo
## es DefinicionEntidad). En C1 solo aportan habilidades entrenadas; sus mecánicas llegan en C2 a C4.

@export var id: StringName = &""
@export var nombre: String = ""
## Habilidades que entrena (p. ej. Latrocinio del Ladrón, Ocultismo del patrón).
@export var habilidades: Array[Habilidad.Tipo] = []

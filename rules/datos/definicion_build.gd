class_name DefinicionBuild
extends Resource
## Build fijo de nivel 1 para el slice (sin elección de dotes). ArmadorPersonaje lo valida con las reglas
## de creación del Player Core y lo convierte en un DefinicionPersonaje.
## Trasfondo: solo sus 2 mejoras y 1 habilidad (su dote de habilidad queda para más adelante).

@export var id: StringName = &""
@export var nombre: String = "TODO_LORE"
@export var clase: DefinicionClase
@export var ascendencia: DefinicionAscendencia
## Tejemaneje, doctrina o patrón, según la clase (vacío si no corresponde).
@export var subclase: DefinicionSubclase
## Entidad (solo clérigo): habilidad divina y arma predilecta.
@export var entidad: DefinicionEntidad

@export_group("Mejoras de atributo")
@export var atributo_clave: Atributo.Tipo = Atributo.Tipo.FUERZA
## Mejoras libres de la ascendencia (tantas como indique).
@export var mejoras_ascendencia: Array[Atributo.Tipo] = []
## Las 2 mejoras del trasfondo.
@export var mejoras_trasfondo: Array[Atributo.Tipo] = []
## Las 4 mejoras libres finales (atributos distintos).
@export var mejoras_libres: Array[Atributo.Tipo] = []

@export_group("Habilidades")
## La elegida de `habilidades_una_de` de la clase (si la clase pide elegir).
@export var habilidad_una_de: Habilidad.Tipo = Habilidad.Tipo.ACROBACIAS
## Libres: `habilidades_libres_base` de la clase + Inteligencia.
@export var habilidades_libres: Array[Habilidad.Tipo] = []
@export var habilidad_trasfondo: Habilidad.Tipo = Habilidad.Tipo.ACROBACIAS

@export_group("Equipo")
@export var armas: Array[DefinicionArma] = []
@export var armadura: DefinicionArmadura


func errores_de_datos() -> PackedStringArray:
	return ArmadorPersonaje.validar(self)

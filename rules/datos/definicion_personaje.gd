class_name DefinicionPersonaje
extends Resource
## Números de un personaje, cargados a mano. Todavía sin clases ni ascendencias: esos Resources
## se agregan cuando se defina qué entra en el slice (ver GDD, preguntas abiertas).
## Las estadísticas derivadas (Percepción, salvaciones, CA, PG, CD de clase) se calculan en Estadisticas.

@export var nombre: String = "TODO_LORE"
@export_range(1, 20) var nivel: int = 1

@export_group("Modificadores de atributo")
@export var fuerza: int = 0
@export var destreza: int = 0
@export var constitucion: int = 0
@export var inteligencia: int = 0
@export var sabiduria: int = 0
@export var carisma: int = 0

@export_group("Competencias")
@export var percepcion: Competencia.Rango = Competencia.Rango.NO_ENTRENADO
@export var fortaleza: Competencia.Rango = Competencia.Rango.NO_ENTRENADO
@export var reflejos: Competencia.Rango = Competencia.Rango.NO_ENTRENADO
@export var voluntad: Competencia.Rango = Competencia.Rango.NO_ENTRENADO
## Competencia en la categoría de armadura que usa (o sin armadura).
@export var defensa: Competencia.Rango = Competencia.Rango.NO_ENTRENADO
@export var cd_clase: Competencia.Rango = Competencia.Rango.NO_ENTRENADO
@export var atributo_clave: Atributo.Tipo = Atributo.Tipo.FUERZA

@export_group("Puntos de Golpe")
## PG que da la ascendencia (una sola vez).
@export var pg_ascendencia: int = 0
## PG que da la clase por nivel (se les suma la Constitución).
@export var pg_clase_por_nivel: int = 0

@export_group("Equipo")
## null = sin armadura.
@export var armadura: DefinicionArmadura


func modificador(atributo: Atributo.Tipo) -> int:
	match atributo:
		Atributo.Tipo.FUERZA: return fuerza
		Atributo.Tipo.DESTREZA: return destreza
		Atributo.Tipo.CONSTITUCION: return constitucion
		Atributo.Tipo.INTELIGENCIA: return inteligencia
		Atributo.Tipo.SABIDURIA: return sabiduria
		_: return carisma

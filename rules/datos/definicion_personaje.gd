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
## Competencia en defensa por categoría de armadura (incluye SIN_ARMADURA).
@export var defensas: Dictionary[DefinicionArmadura.Categoria, Competencia.Rango] = {}
@export var cd_clase: Competencia.Rango = Competencia.Rango.NO_ENTRENADO
@export var atributo_clave: Atributo.Tipo = Atributo.Tipo.FUERZA
## Competencia en ataques por categoría de arma.
@export var ataques: Dictionary[DefinicionArma.Categoria, Competencia.Rango] = {}
## Competencia en armas específicas por id (p. ej. el arma predilecta de la entidad del clérigo).
@export var armas_con_competencia: Dictionary[StringName, Competencia.Rango] = {}

@export_group("Puntos de Golpe")
## PG que da la ascendencia (una sola vez).
@export var pg_ascendencia: int = 0
## PG que da la clase por nivel (se les suma la Constitución).
@export var pg_clase_por_nivel: int = 0

@export_group("Movimiento")
@export var velocidad_pies: int = 25

@export_group("Equipo")
## null = sin armadura.
@export var armadura: DefinicionArmadura
@export var armas: Array[DefinicionArma] = []


## Nivel mínimo y máximo de personaje en PF2e.
const NIVEL_MINIMO: int = 1
const NIVEL_MAXIMO: int = 20


func errores_de_datos() -> PackedStringArray:
	var errores: PackedStringArray = PackedStringArray()
	if nivel < NIVEL_MINIMO or nivel > NIVEL_MAXIMO:
		errores.append("Personaje %s: nivel fuera de rango (%d)" % [nombre, nivel])
	if pg_ascendencia < 0 or pg_clase_por_nivel < 0:
		errores.append("Personaje %s: los PG de ascendencia y de clase no pueden ser negativos" % nombre)
	if velocidad_pies < 0 or velocidad_pies % Medicion.PIES_POR_CASILLA != 0:
		errores.append("Personaje %s: la Velocidad tiene que ser múltiplo de 5 pies" % nombre)
	if armadura != null:
		errores.append_array(armadura.errores_de_datos())
	for arma: DefinicionArma in armas:
		errores.append_array(arma.errores_de_datos())
	return errores


func modificador(atributo: Atributo.Tipo) -> int:
	match atributo:
		Atributo.Tipo.FUERZA: return fuerza
		Atributo.Tipo.DESTREZA: return destreza
		Atributo.Tipo.CONSTITUCION: return constitucion
		Atributo.Tipo.INTELIGENCIA: return inteligencia
		Atributo.Tipo.SABIDURIA: return sabiduria
		_: return carisma

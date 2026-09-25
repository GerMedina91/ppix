class_name Combatiente
extends RefCounted
## Estado de un participante durante un combate: PG actuales, casilla, acciones del turno y condiciones.
## Sus números salen de una FuenteEstadisticas (personaje o criatura); la definición no se modifica.

enum Bando { PARTY, ENEMIGOS }

const ACCIONES_POR_TURNO: int = 3

var id: StringName = &""
var bando: Bando = Bando.PARTY
var celda: Vector2i = Vector2i.ZERO
var pg: int = 0
var acciones_restantes: int = 0
var reaccion_disponible: bool = false
## Ataques hechos en el turno actual (para el penalizador por ataque múltiple).
var ataques_en_turno: int = 0

var fuente: FuenteEstadisticas


func _init(id_combatiente: StringName, fuente_estadisticas: FuenteEstadisticas, bando_combatiente: Bando, celda_inicial: Vector2i) -> void:
	id = id_combatiente
	fuente = fuente_estadisticas
	bando = bando_combatiente
	celda = celda_inicial
	pg = fuente.pg_maximos()


static func desde_personaje(id_combatiente: StringName, personaje: DefinicionPersonaje, celda_inicial: Vector2i) -> Combatiente:
	return Combatiente.new(id_combatiente, FuentePersonaje.new(personaje), Bando.PARTY, celda_inicial)


static func desde_criatura(id_combatiente: StringName, criatura: DefinicionCriatura, celda_inicial: Vector2i) -> Combatiente:
	return Combatiente.new(id_combatiente, FuenteCriatura.new(criatura), Bando.ENEMIGOS, celda_inicial)


func nombre() -> String:
	return fuente.nombre()


func pg_maximos() -> int:
	return fuente.pg_maximos()


func es_aliado_de(otro: Combatiente) -> bool:
	return bando == otro.bando


## Arma principal (la primera de la lista).
func arma_principal() -> DefinicionArma:
	var armas: Array[DefinicionArma] = fuente.armas()
	return armas[0] if not armas.is_empty() else null


## Prepara el turno: 3 acciones, reacción disponible y contador de ataques en cero.
func empezar_turno() -> void:
	acciones_restantes = ACCIONES_POR_TURNO
	reaccion_disponible = true
	ataques_en_turno = 0


func gastar_acciones(cantidad: int) -> bool:
	if cantidad > acciones_restantes:
		return false
	acciones_restantes -= cantidad
	return true

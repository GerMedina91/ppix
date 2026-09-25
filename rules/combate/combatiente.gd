class_name Combatiente
extends RefCounted
## Estado de un participante durante un combate: PG actuales, casilla, acciones del turno y condiciones.
## Sus números salen de una FuenteEstadisticas (personaje o criatura); la definición no se modifica.

enum Bando { PARTY, ENEMIGOS }

const ACCIONES_POR_TURNO: int = 3
const PENALIZADOR_DESPREVENIDO: int = -2
const PENALIZADOR_INCONSCIENTE: int = -4
const _CAMBIO_MORIBUNDO_POR_GRADO: Dictionary[GradoExito.Grado, int] = {
	GradoExito.Grado.EXITO_CRITICO: -2,
	GradoExito.Grado.EXITO: -1,
	GradoExito.Grado.FALLO: 1,
	GradoExito.Grado.FALLO_CRITICO: 2,
}

var id: StringName = &""
var bando: Bando = Bando.PARTY
var celda: Vector2i = Vector2i.ZERO
var pg: int = 0
var acciones_restantes: int = 0
var reaccion_disponible: bool = false
## Ataques hechos en el turno actual (para el penalizador por ataque múltiple).
var ataques_en_turno: int = 0

var fuente: FuenteEstadisticas
var condiciones: Condiciones = Condiciones.new()


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


## Percepción con las condiciones aplicadas (inconsciente: -4 de estatus).
func prueba_percepcion() -> Prueba:
	var prueba: Prueba = fuente.prueba_percepcion()
	_aplicar_inconsciente(prueba)
	return prueba


## Tirada de salvación con las condiciones aplicadas (inconsciente: -4 de estatus a Reflejos).
func prueba_salvacion(salvacion: Estadisticas.Salvacion) -> Prueba:
	var prueba: Prueba = fuente.prueba_salvacion(salvacion)
	if salvacion == Estadisticas.Salvacion.REFLEJOS:
		_aplicar_inconsciente(prueba)
	return prueba


## Defensa frente a un ataque, con las condiciones del defensor. `flanqueado_por_el_atacante` lo decide
## Flanqueo (solo frente a quien flanquea).
func defensa_contra(flanqueado_por_el_atacante: bool) -> Prueba:
	var prueba: Prueba = fuente.defensa()
	if flanqueado_por_el_atacante or condiciones.desprevenido or condiciones.inconsciente:
		prueba.modificadores.append(Modificador.new(PENALIZADOR_DESPREVENIDO, Modificador.Tipo.CIRCUNSTANCIA, "desprevenido"))
	_aplicar_inconsciente(prueba)
	return prueba


## Inconsciente: -4 de estatus a CA, Percepción y Reflejos.
func _aplicar_inconsciente(prueba: Prueba) -> void:
	if condiciones.inconsciente:
		prueba.modificadores.append(Modificador.new(PENALIZADOR_INCONSCIENTE, Modificador.Tipo.ESTATUS, "inconsciente"))


## Aplica daño. Personajes: a 0 PG caen moribundos (reglas completas). Criaturas: mueren a 0 PG.
func recibir_danio(cantidad: int, por_critico: bool) -> void:
	if condiciones.muerto or cantidad <= 0:
		return
	if pg > 0:
		pg = maxi(0, pg - cantidad)
		if pg == 0:
			_caer(por_critico)
	elif condiciones.moribundo > 0:
		condiciones.moribundo += 2 if por_critico else 1
		_revisar_muerte()
	else:
		# A 0 PG estable (inconsciente sin moribundo): el daño lo vuelve a poner moribundo.
		_caer(por_critico)


## Cura PG. Con 1 PG o más, un personaje moribundo o inconsciente pierde esas condiciones
## (perder moribundo aumenta herido en 1).
func curar(cantidad: int) -> void:
	if condiciones.muerto or cantidad <= 0:
		return
	pg = mini(pg_maximos(), pg + cantidad)
	if pg > 0:
		if condiciones.moribundo > 0:
			_perder_moribundo()
		condiciones.inconsciente = false


## Prueba de recuperación: prueba plana contra CD 10 + moribundo. Éxito crítico -2, éxito -1,
## fallo +1, fallo crítico +2. Devuelve el resultado (null si no está moribundo).
func prueba_de_recuperacion(dados: Dados) -> ResultadoPrueba:
	if condiciones.moribundo <= 0 or condiciones.muerto:
		return null
	var resultado: ResultadoPrueba = Prueba.plana("prueba de recuperación").resolver(dados, Prueba.BASE_CD + condiciones.moribundo)
	condiciones.moribundo += _CAMBIO_MORIBUNDO_POR_GRADO[resultado.grado]
	if condiciones.moribundo <= 0:
		_perder_moribundo()
	else:
		_revisar_muerte()
	return resultado


func _caer(por_critico: bool) -> void:
	if not fuente.usa_reglas_de_moribundo():
		condiciones.muerto = true
		return
	condiciones.moribundo = (2 if por_critico else 1) + condiciones.herido
	condiciones.inconsciente = true
	_revisar_muerte()


func _perder_moribundo() -> void:
	condiciones.moribundo = 0
	condiciones.herido += 1


func _revisar_muerte() -> void:
	if condiciones.moribundo >= Condiciones.MORIBUNDO_MUERTE:
		condiciones.muerto = true


## Restauración completa (PG al máximo, sin condiciones). Hoy solo para depuración; a futuro, descanso.
func restaurar_por_completo() -> void:
	condiciones = Condiciones.new()
	pg = pg_maximos()


## Al terminar un combate ganado, quien sigue moribundo se estabiliza: pierde moribundo
## (herido +1) y queda inconsciente con 0 PG hasta que lo curen.
func estabilizar() -> void:
	if condiciones.moribundo > 0 and not condiciones.muerto:
		_perder_moribundo()


func gastar_acciones(cantidad: int) -> bool:
	if cantidad > acciones_restantes:
		return false
	acciones_restantes -= cantidad
	return true

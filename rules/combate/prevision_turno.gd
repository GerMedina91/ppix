class_name PrevisionTurno
extends RefCounted
## Lo que puede hacer el combatiente en turno desde el estado actual, calculado una sola vez por punto
## de decisión (inicio de turno, después de cada acción o reacción): alcance por Zancadas, plan y
## recorrido hacia cada casilla, y oponentes a los que puede dar un Golpe. El cursor solo consulta (el
## recorrido de cada casilla se reconstruye de los previos guardados la primera vez que se pide).
## `vigente()` compara una firma del estado (turno, acciones, casillas y muertes): cualquier cambio la
## invalida, aunque venga de afuera del Combate (depuración, tests).

var alcance: AlcanceZancadas
## Casilla -> Zancadas, solo las que el actor puede elegir (huyendo: las que lo alejan en cada Zancada).
var por_casilla: Dictionary[Vector2i, int] = {}
## Casilla -> recorrido completo de todas las Zancadas hasta ahí (los ya pedidos).
var _caminos: Dictionary[Vector2i, Array] = {}
## Casillas de oponentes a los que el actor puede dar un Golpe con su arma principal.
var golpeables: Dictionary[Vector2i, bool] = {}
var _actor: Combatiente
var _firma: Array


func _init(combate: Combate) -> void:
	_actor = combate.turno_actual()
	_firma = firma(combate)
	alcance = combate.alcance_de_zancadas(_actor)
	var huye: bool = _actor.condiciones.tiene(Condiciones.Tipo.HUYENDO)
	for casilla: Vector2i in alcance.por_casilla:
		if not huye or _plan_aleja(combate, casilla):
			por_casilla[casilla] = alcance.por_casilla[casilla]
	if huye:
		return  # huyendo no puede dar Golpes
	var arma: DefinicionArma = _actor.arma_principal()
	for c: Combatiente in combate.participantes:
		if Golpe.validar(_actor, c, arma, combate.vision()) == Golpe.Motivo.VALIDO:
			golpeables[c.celda] = true


## true si cada Zancada del plan hasta `casilla` termina más lejos de la fuente de la huida.
func _plan_aleja(combate: Combate, casilla: Vector2i) -> bool:
	var desde: Vector2i = _actor.celda
	for fin: Vector2i in alcance.plan(casilla):
		if not ReglasCondiciones.movimiento_permitido(combate, _actor, desde, fin):
			return false
		desde = fin
	return true


static func firma(combate: Combate) -> Array:
	var actor: Combatiente = combate.turno_actual()
	var datos: Array = [actor.id, actor.acciones_restantes, actor.condiciones.tiene(Condiciones.Tipo.HUYENDO)]
	for c: Combatiente in combate.participantes:
		datos.append_array([c.celda, c.condiciones.muerto])
	return datos


func vigente(combate: Combate) -> bool:
	return firma(combate) == _firma


## Costo en acciones de hacer click en `celda`: el Golpe, las Zancadas necesarias o 0 si no se puede.
func costo(celda: Vector2i) -> int:
	if golpeables.has(celda):
		return Combate.COSTO_GOLPE if _actor.acciones_restantes >= Combate.COSTO_GOLPE else 0
	return por_casilla.get(celda, 0) * Combate.COSTO_ZANCADA


func camino(celda: Vector2i) -> Array[Vector2i]:
	if not _caminos.has(celda):
		_caminos[celda] = alcance.camino(celda) if por_casilla.has(celda) else []
	var resultado: Array[Vector2i] = []
	resultado.assign(_caminos[celda])
	return resultado

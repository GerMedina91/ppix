class_name AccionesMovimiento
extends RefCounted
## Zancada y Paso del combate: validación, costo y avance casilla por casilla con las reacciones.
## Combate expone la API pública y delega acá. Referencia débil al Combate (como GestorReacciones),
## para no formar un ciclo.
## - Zancada: hasta la Velocidad, con diagonales alternadas (MovimientoCombate). Se procesa casilla por
##   casilla: antes de salir de cada una se ofrecen las reacciones; si el que se mueve cae, se corta ahí.
## - Paso: 1 casilla libre adyacente; no dispara reacciones de movimiento.
## - Oponentes vivos bloquean; aliados se atraviesan pero no se termina en su casilla.

var _combate_ref: WeakRef
var _movimiento: MovimientoCombate


func _init(combate: Combate, grilla: GrillaMapa) -> void:
	_combate_ref = weakref(combate)
	_movimiento = MovimientoCombate.new(grilla)


func _combate() -> Combate:
	return _combate_ref.get_ref() as Combate


# --- Consultas ---

func casillas_de_zancada(c: Combatiente) -> Dictionary[Vector2i, int]:
	return _movimiento.alcanzables(c.celda, c.fuente.velocidad_pies(), bloqueadas_para(c), de_aliados_de(c))


func camino_de_zancada(c: Combatiente, destino: Vector2i) -> Array[Vector2i]:
	return _movimiento.camino(c.celda, destino, bloqueadas_para(c), de_aliados_de(c))


func alcance_de_zancadas(c: Combatiente, zancadas_max: int) -> AlcanceZancadas:
	return _movimiento.alcance_de_zancadas(c.celda, c.fuente.velocidad_pies(), zancadas_max, bloqueadas_para(c), de_aliados_de(c))


## Casillas de oponentes que no murieron: no se pueden atravesar.
func bloqueadas_para(c: Combatiente) -> Dictionary:
	var bloqueadas: Dictionary = {}
	for otro: Combatiente in _combate().participantes:
		if not otro.es_aliado_de(c) and not otro.condiciones.muerto:
			bloqueadas[otro.celda] = true
	return bloqueadas


## Casillas de aliados (se atraviesan, no se termina ahí).
func de_aliados_de(c: Combatiente) -> Dictionary:
	var aliadas: Dictionary = {}
	for otro: Combatiente in _combate().participantes:
		if otro != c and otro.es_aliado_de(c) and not otro.condiciones.muerto:
			aliadas[otro.celda] = true
	return aliadas


# --- Acciones ---

## Zancada del actor en turno. `recorrido`: casillas por las que pasa (p. ej. el tramo previsto de un plan
## de varias Zancadas); si falta, va por el camino más barato.
func zancada(destino: Vector2i, recorrido: Array[Vector2i]) -> Array[EventoCombate]:
	var combate: Combate = _combate()
	var actor: Combatiente = combate.turno_actual()
	var invalido: EventoCombate = combate.validar_accion(actor, Combate.COSTO_ZANCADA, Combate.ACCION_ZANCADA)
	if invalido != null:
		return [invalido]
	var motivo: String = motivo_zancada_imposible(actor, destino, recorrido)
	if motivo != "":
		return [combate.invalida(actor, Combate.ACCION_ZANCADA, motivo)]
	actor.gastar_acciones(Combate.COSTO_ZANCADA)
	return mover_zancada(actor, destino, recorrido)


## Por qué no puede hacer esa Zancada ("" si puede). No mira las acciones.
func motivo_zancada_imposible(actor: Combatiente, destino: Vector2i, recorrido: Array[Vector2i]) -> String:
	var camino: Array[Vector2i] = _camino_para(actor, destino, recorrido)
	var valido: bool = _movimiento.es_camino_valido(actor.celda, camino, bloqueadas_para(actor), de_aliados_de(actor)) \
		and camino.back() == destino and MovimientoCombate.costo_de(actor.celda, camino) <= actor.fuente.velocidad_pies()
	if not valido:
		return "fuera del alcance de la Zancada"
	if not ReglasCondiciones.movimiento_permitido(_combate(), actor, actor.celda, destino):
		return Combate.MOTIVO_HUYENDO
	return ""


## Hace la Zancada ya validada y pagada (también sirve para Zancadas que vienen dentro de otra acción).
func mover_zancada(actor: Combatiente, destino: Vector2i, recorrido: Array[Vector2i]) -> Array[EventoCombate]:
	return _avanzar_zancada(actor, _camino_para(actor, destino, recorrido), 0, false)


func paso(destino: Vector2i) -> Array[EventoCombate]:
	var combate: Combate = _combate()
	var actor: Combatiente = combate.turno_actual()
	var invalido: EventoCombate = combate.validar_accion(actor, Combate.COSTO_PASO, Combate.ACCION_PASO)
	if invalido != null:
		return [invalido]
	var motivo: String = motivo_paso_imposible(actor, destino)
	if motivo != "":
		return [combate.invalida(actor, Combate.ACCION_PASO, motivo)]
	actor.gastar_acciones(Combate.COSTO_PASO)
	return mover_paso(actor, destino)


## Por qué no puede dar ese Paso ("" si puede). No mira las acciones.
func motivo_paso_imposible(actor: Combatiente, destino: Vector2i) -> String:
	var d: Vector2i = destino - actor.celda
	if absi(d.x) > 1 or absi(d.y) > 1 or d == Vector2i.ZERO or _ocupada(destino) \
			or not _combate().grilla().puede_dar_paso(actor.celda, destino):
		return "solo a una casilla libre adyacente"
	if not ReglasCondiciones.movimiento_permitido(_combate(), actor, actor.celda, destino):
		return Combate.MOTIVO_HUYENDO
	return ""


## Da el Paso ya validado y pagado.
func mover_paso(actor: Combatiente, destino: Vector2i) -> Array[EventoCombate]:
	var desde: Vector2i = actor.celda
	actor.celda = destino
	var camino: Array[Vector2i] = [destino]
	return [_combate().emitir(EventoCombate.new(EventoCombate.Tipo.MOVIMIENTO, actor.id,
		{"desde": desde, "camino": camino, "tipo": "paso"}))]


# --- Internos ---

func _camino_para(actor: Combatiente, destino: Vector2i, recorrido: Array[Vector2i]) -> Array[Vector2i]:
	return recorrido if not recorrido.is_empty() else camino_de_zancada(actor, destino)


## Avanza la Zancada casilla por casilla desde `indice`; antes de salir de cada casilla ofrece las
## reacciones (salvo `disparo_resuelto`, que evita volver a ofrecerlas en la casilla donde se retoma).
## Si el que se mueve queda fuera de combate, el movimiento se corta ahí.
func _avanzar_zancada(actor: Combatiente, camino: Array[Vector2i], indice: int, disparo_resuelto: bool) -> Array[EventoCombate]:
	var combate: Combate = _combate()
	var eventos: Array[EventoCombate] = []
	var desde: Vector2i = actor.celda
	var recorrido: Array[Vector2i] = []
	var i: int = indice
	var resuelto: bool = disparo_resuelto
	while i < camino.size() and actor.condiciones.en_pie() and combate.estado == Combate.Estado.EN_CURSO:
		if not resuelto:
			var disparo: DisparoReaccion = DisparoReaccion.sale_de_casilla(actor, actor.celda)
			if combate.reacciones.hay_candidatos(disparo):
				if not recorrido.is_empty():
					eventos.append(_evento_movimiento(actor, desde, recorrido, indice > 0 or disparo_resuelto))
				var siguiente: int = i
				eventos.append_array(combate.reacciones.procesar(disparo,
					func() -> Array[EventoCombate]: return _avanzar_zancada(actor, camino, siguiente, true)))
				return eventos
		actor.celda = camino[i]
		recorrido.append(camino[i])
		i += 1
		resuelto = false
	if not recorrido.is_empty():
		eventos.append(_evento_movimiento(actor, desde, recorrido, indice > 0 or disparo_resuelto))
	return eventos


func _evento_movimiento(actor: Combatiente, desde: Vector2i, recorrido: Array[Vector2i], continua: bool) -> EventoCombate:
	return _combate().emitir(EventoCombate.new(EventoCombate.Tipo.MOVIMIENTO, actor.id,
		{"desde": desde, "camino": recorrido.duplicate(), "tipo": "zancada", "continua": continua}))


func _ocupada(casilla: Vector2i) -> bool:
	return _combate().participantes.any(func(c: Combatiente) -> bool: return c.celda == casilla and not c.condiciones.muerto)

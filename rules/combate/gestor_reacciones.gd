class_name GestorReacciones
extends RefCounted
## Reacciones del combate. Ante un DisparoReaccion busca quién puede reaccionar (en orden de iniciativa)
## y resuelve según la política de cada uno: SIEMPRE la usa, NUNCA la ignora, PREGUNTAR detiene el
## combate con una pregunta pendiente (evento REACCION_PENDIENTE) hasta que llegue responder().
## Después sigue con la continuación de la acción que se había interrumpido.

## Referencia débil: el Combate es dueño del gestor (una referencia fuerte formaría un ciclo que no se libera).
var _combate_ref: WeakRef
## {"reactor", "capacidad", "disparo", "restantes", "continuacion"} o vacío.
var _pendiente: Dictionary = {}


func _init(combate: Combate) -> void:
	_combate_ref = weakref(combate)


func _combate() -> Combate:
	return _combate_ref.get_ref() as Combate


func hay_pendiente() -> bool:
	return not _pendiente.is_empty()


## {"reactor": Combatiente, "capacidad": CapacidadReaccion, "disparo": DisparoReaccion} o vacío.
func pregunta() -> Dictionary:
	return _pendiente


func hay_candidatos(disparo: DisparoReaccion) -> bool:
	return not _candidatos(disparo).is_empty()


## Resuelve las reacciones ante `disparo` y después ejecuta `continuacion` (salvo que quede una pregunta).
func procesar(disparo: DisparoReaccion, continuacion: Callable) -> Array[EventoCombate]:
	return _resolver(_candidatos(disparo), disparo, continuacion)


func responder(usar: bool) -> Array[EventoCombate]:
	if _pendiente.is_empty():
		return []
	var p: Dictionary = _pendiente
	_pendiente = {}
	var eventos: Array[EventoCombate] = []
	if usar:
		eventos.append_array(_usar(p.reactor, p.capacidad, p.disparo))
	eventos.append_array(_resolver(p.restantes, p.disparo, p.continuacion))
	return eventos


func _resolver(candidatos: Array, disparo: DisparoReaccion, continuacion: Callable) -> Array[EventoCombate]:
	var eventos: Array[EventoCombate] = []
	while not candidatos.is_empty():
		var candidato: Array = candidatos.pop_front()
		var reactor: Combatiente = candidato[0]
		var capacidad: CapacidadReaccion = candidato[1]
		if not _puede(reactor, capacidad, disparo):
			continue
		match reactor.politica_reacciones:
			Combatiente.PoliticaReaccion.SIEMPRE:
				eventos.append_array(_usar(reactor, capacidad, disparo))
			Combatiente.PoliticaReaccion.PREGUNTAR:
				_pendiente = {"reactor": reactor, "capacidad": capacidad, "disparo": disparo,
					"restantes": candidatos, "continuacion": continuacion}
				eventos.append(_combate().emitir(EventoCombate.new(EventoCombate.Tipo.REACCION_PENDIENTE, reactor.id,
					{"reaccion": capacidad.nombre, "disparador": disparo.actor.id})))
				return eventos
			_:
				pass
	eventos.append_array(continuacion.call())
	return eventos


func _usar(reactor: Combatiente, capacidad: CapacidadReaccion, disparo: DisparoReaccion) -> Array[EventoCombate]:
	reactor.reaccion_disponible = false
	var eventos: Array[EventoCombate] = [_combate().emitir(EventoCombate.new(EventoCombate.Tipo.REACCION, reactor.id,
		{"reaccion": capacidad.nombre, "disparador": disparo.actor.id}))]
	eventos.append_array(capacidad.ejecutar(reactor, disparo, _combate()))
	return eventos


## [reactor, capacidad] en orden de iniciativa.
func _candidatos(disparo: DisparoReaccion) -> Array:
	var lista: Array = []
	for reactor: Combatiente in _combate().orden:
		for capacidad: Capacidad in reactor.fuente.capacidades():
			if capacidad is CapacidadReaccion and _puede(reactor, capacidad, disparo):
				lista.append([reactor, capacidad])
	return lista


func _puede(reactor: Combatiente, capacidad: CapacidadReaccion, disparo: DisparoReaccion) -> bool:
	return reactor != disparo.actor and reactor.reaccion_disponible and reactor.condiciones.puede_actuar() \
		and _combate().estado == Combate.Estado.EN_CURSO and capacidad.aplica(reactor, disparo, _combate())

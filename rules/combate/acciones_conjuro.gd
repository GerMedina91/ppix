class_name AccionesConjuro
extends RefCounted
## Lanzar un conjuro y Sostener (Player Core p. 299, 302 y 419; verificado en c4_conjuros.md).
## Combate expone la API y delega acá (referencia débil al Combate, como GestorReacciones).
## Lanzar: se validan acciones, recurso (truco, espacio o foco) y objetivo; se paga todo; si tiene el
## rasgo manipular se ofrecen las reacciones (el Golpe reactivo con crítico lo interrumpe: el costo se
## pierde). Un segundo maleficio en el mismo turno falla solo, con las acciones perdidas.
## Efecto: salvación contra la CD de conjuro y condiciones según el grado; sobre uno mismo, bonificador
## de Velocidad y, si el conjuro lo permite, un Paso o una Zancada como parte del lanzamiento.

const ACCION_SOSTENER: String = "Sostener"
const COSTO_SOSTENER: int = 1
const SIN_CELDA: Vector2i = PedidoConjuro.SIN_CELDA

var sostenidos: Array[EfectoSostenido] = []
var _combate_ref: WeakRef


func _init(combate: Combate) -> void:
	_combate_ref = weakref(combate)


func _combate() -> Combate:
	return _combate_ref.get_ref() as Combate


# --- Consultas ---

## Por qué `lanzador` no puede hacer el `pedido` sobre `objetivo` ("" si puede; ver ObjetivosConjuro).
## No mira las acciones ni la regla del maleficio (ver falla_por_maleficio()).
func motivo_imposible(lanzador: Combatiente, pedido: PedidoConjuro, objetivo: Combatiente) -> String:
	return ObjetivosConjuro.motivo(_combate(), lanzador, pedido, objetivo)


## true si lanzarlo ahora fallaría por ser el segundo maleficio del turno.
func falla_por_maleficio(lanzador: Combatiente, conjuro: DefinicionConjuro) -> bool:
	return conjuro.tiene(DefinicionConjuro.Rasgo.MALEFICIO) and lanzador.maleficio_en_turno


## Criaturas sobre las que `lanzador` puede lanzar `conjuro` ahora (con esas acciones, si es variable).
func objetivos_validos(lanzador: Combatiente, conjuro: DefinicionConjuro, acciones: int = 0) -> Array[Combatiente]:
	return ObjetivosConjuro.validos(_combate(), lanzador, conjuro, acciones)


## Efectos sostenidos de `lanzador` que todavía no sostuvo en este turno.
func por_sostener(lanzador: Combatiente) -> Array[EfectoSostenido]:
	var lista: Array[EfectoSostenido] = []
	for s: EfectoSostenido in sostenidos:
		if s.lanzador == lanzador.id and not s.sostenido_en_turno:
			lista.append(s)
	return lista


# --- Acciones ---

func lanzar(pedido: PedidoConjuro) -> Array[EventoCombate]:
	var combate: Combate = _combate()
	var actor: Combatiente = combate.turno_actual()
	var conjuro: DefinicionConjuro = pedido.conjuro
	var invalido: EventoCombate = combate.validar_accion(actor, maxi(pedido.costo(), 1), conjuro.nombre)
	if invalido != null:
		return [invalido]
	var sobre_si: bool = conjuro.objetivo == DefinicionConjuro.Objetivo.UNO_MISMO or pedido.es_area()
	var objetivo: Combatiente = actor if sobre_si else combate.combatiente(pedido.objetivo)
	var motivo: String = motivo_imposible(actor, pedido, objetivo)
	if motivo != "":
		return [combate.invalida(actor, conjuro.nombre, motivo)]
	actor.gastar_acciones(pedido.costo())
	actor.conjuros.gastar(conjuro)
	var eventos: Array[EventoCombate] = [combate.emitir(EventoCombate.new(EventoCombate.Tipo.LANZAMIENTO, actor.id,
		{"conjuro": conjuro, "objetivo": objetivo.id, "acciones": pedido.costo()}))]
	if conjuro.tiene(DefinicionConjuro.Rasgo.MALEFICIO):
		if actor.maleficio_en_turno:
			eventos.append(_fallido(actor, conjuro, "ya lanzó un maleficio este turno"))
			return eventos
		actor.maleficio_en_turno = true
	# Reacciones, en orden: a la acción de manipular (Golpe reactivo) y, si es un ataque, al ser objetivo
	# (Esquiva ágil). Después, el efecto.
	var disparo: DisparoReaccion = DisparoReaccion.usa_manipular(actor)
	var al_objetivo: DisparoReaccion = DisparoReaccion.objetivo_de_ataque(actor, objetivo, null)
	var resolver: Callable = func() -> Array[EventoCombate]:
		return _resolver(actor, pedido, objetivo, disparo, al_objetivo.bonificadores_ca)
	var tras_manipular: Callable = resolver
	if conjuro.es_ataque():
		tras_manipular = func() -> Array[EventoCombate]:
			if disparo.interrumpida or not actor.condiciones.en_pie():
				return resolver.call()
			return combate.reacciones.procesar(al_objetivo, resolver)
	if pedido.tiene(DefinicionConjuro.Rasgo.MANIPULAR):
		eventos.append_array(combate.reacciones.procesar(disparo, tras_manipular))
	else:
		eventos.append_array(tras_manipular.call())
	return eventos


## Sostener (1 acción, concentrar): extiende el primer efecto sostenido que no sostuvo en este turno.
func sostener() -> Array[EventoCombate]:
	var combate: Combate = _combate()
	var actor: Combatiente = combate.turno_actual()
	var invalido: EventoCombate = combate.validar_accion(actor, COSTO_SOSTENER, ACCION_SOSTENER)
	if invalido != null:
		return [invalido]
	var pendientes: Array[EfectoSostenido] = por_sostener(actor)
	if pendientes.is_empty():
		return [combate.invalida(actor, ACCION_SOSTENER, "nada que sostener")]
	actor.gastar_acciones(COSTO_SOSTENER)
	pendientes[0].sostenido_en_turno = true
	return [combate.emitir(EventoCombate.new(EventoCombate.Tipo.SOSTENER, actor.id,
		{"conjuro": pendientes[0].conjuro, "objetivo": pendientes[0].objetivo}))]


## Al final del turno de `actor`: terminan sus efectos que no sostuvo o que llegaron al máximo.
func fin_de_turno(actor: Combatiente) -> Array[EventoCombate]:
	var eventos: Array[EventoCombate] = []
	for s: EfectoSostenido in sostenidos.duplicate():
		if s.lanzador != actor.id:
			continue
		s.turnos += 1
		if not s.sostenido_en_turno or s.turnos >= s.conjuro.sostenido_rondas_max:
			eventos.append(_terminar(s))
		else:
			s.sostenido_en_turno = false
	return eventos


## Pisos de condición de los efectos sostenidos: valen si el lanzador sigue vivo y ve al objetivo
## (Mal de ojo). Los efectos cuyo lanzador u objetivo murió terminan.
func actualizar_pisos() -> Array[EventoCombate]:
	var combate: Combate = _combate()
	var eventos: Array[EventoCombate] = []
	for s: EfectoSostenido in sostenidos.duplicate():
		var lanzador: Combatiente = combate.combatiente(s.lanzador)
		var objetivo: Combatiente = combate.combatiente(s.objetivo)
		if lanzador.condiciones.muerto or objetivo.condiciones.muerto:
			eventos.append(_terminar(s))
			continue
		if s.conjuro.piso_mientras_dura <= 0:
			continue
		var ve: bool = combate.vision().hay_linea(lanzador.celda, objetivo.celda)
		for efecto: EfectoPorGrado in s.conjuro.efectos:
			if ve:
				objetivo.condiciones.fijar_piso(efecto.condicion, s.clave(), s.conjuro.piso_mientras_dura)
			else:
				objetivo.condiciones.quitar_piso(efecto.condicion, s.clave())
	return eventos


# --- Internos ---

func _resolver(actor: Combatiente, pedido: PedidoConjuro, objetivo: Combatiente, disparo: DisparoReaccion,
		bonificadores_ca: Array[Modificador]) -> Array[EventoCombate]:
	var combate: Combate = _combate()
	var conjuro: DefinicionConjuro = pedido.conjuro
	if combate.estado != Combate.Estado.EN_CURSO or not actor.condiciones.en_pie():
		return []
	if disparo.interrumpida:
		return [_fallido(actor, conjuro, "interrumpido")]
	if conjuro.cura():
		var objetivos: Array[Combatiente] = [objetivo]
		if pedido.es_area():
			objetivos = ObjetivosConjuro.afectados_por_area(combate, actor, pedido)
		return EfectosConjuro.curar(combate, actor, pedido, objetivos)
	if conjuro.objetivo == DefinicionConjuro.Objetivo.UNO_MISMO:
		return _sobre_uno_mismo(actor, pedido)
	if objetivo.condiciones.muerto:
		return []  # murió por una reacción antes del efecto
	var efecto: Dictionary = EfectosConjuro.sobre_criatura(combate, actor, conjuro, objetivo, bonificadores_ca)
	if conjuro.es_sostenido() and efecto.aplicadas > 0:
		sostenidos.append(EfectoSostenido.new(actor.id, conjuro, objetivo.id))
		actualizar_pisos()
	return efecto.eventos


func _sobre_uno_mismo(actor: Combatiente, pedido: PedidoConjuro) -> Array[EventoCombate]:
	var combate: Combate = _combate()
	# Bonificadores de estatus: no se suman, vale el mayor.
	actor.bonificador_velocidad = maxi(actor.bonificador_velocidad, pedido.conjuro.bonificador_velocidad)
	var eventos: Array[EventoCombate] = [combate.emitir(EventoCombate.new(EventoCombate.Tipo.EFECTO_CONJURO, actor.id,
		{"conjuro": pedido.conjuro, "objetivo": actor.id, "resultado": null}))]
	if pedido.destino == PedidoConjuro.SIN_CELDA:
		return eventos
	if pedido.es_paso:
		eventos.append_array(combate.movimiento.mover_paso(actor, pedido.destino))
	else:
		eventos.append_array(combate.movimiento.mover_zancada(actor, pedido.destino, pedido.recorrido))
	return eventos


func _fallido(actor: Combatiente, conjuro: DefinicionConjuro, motivo: String) -> EventoCombate:
	return _combate().emitir(EventoCombate.new(EventoCombate.Tipo.CONJURO_FALLIDO, actor.id, {"conjuro": conjuro, "motivo": motivo}))


func _terminar(s: EfectoSostenido) -> EventoCombate:
	sostenidos.erase(s)
	var objetivo: Combatiente = _combate().combatiente(s.objetivo)
	for efecto: EfectoPorGrado in s.conjuro.efectos:
		objetivo.condiciones.quitar_piso(efecto.condicion, s.clave())
	return _combate().emitir(EventoCombate.new(EventoCombate.Tipo.FIN_CONJURO, s.lanzador, {"conjuro": s.conjuro, "objetivo": s.objetivo}))

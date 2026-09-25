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
const SIN_CELDA: Vector2i = Vector2i(-1000000, -1000000)

var sostenidos: Array[EfectoSostenido] = []
var _combate_ref: WeakRef


func _init(combate: Combate) -> void:
	_combate_ref = weakref(combate)


func _combate() -> Combate:
	return _combate_ref.get_ref() as Combate


# --- Consultas ---

## Por qué `lanzador` no puede lanzar `conjuro` sobre `objetivo` / hacia `destino` ("" si puede).
## No mira las acciones ni la regla del maleficio (ver falla_por_maleficio()).
func motivo_imposible(lanzador: Combatiente, conjuro: DefinicionConjuro, objetivo: Combatiente,
		destino: Vector2i = SIN_CELDA, recorrido: Array[Vector2i] = [], es_paso: bool = false) -> String:
	if not lanzador.conjuros.conocidos().has(conjuro):
		return "no conoce ese conjuro"
	if not lanzador.conjuros.puede_lanzar(conjuro):
		return "sin puntos de foco" if conjuro.tipo == DefinicionConjuro.Tipo.FOCO else "sin espacios"
	if conjuro.objetivo == DefinicionConjuro.Objetivo.UNO_MISMO:
		return _motivo_movimiento(lanzador, conjuro, destino, recorrido, es_paso)
	if objetivo == null or objetivo.condiciones.muerto or objetivo == lanzador:
		return "sin objetivo"
	if Medicion.pies_entre(lanzador.celda, objetivo.celda) > conjuro.alcance_pies:
		return "fuera de alcance"
	if not _combate().vision().hay_linea(lanzador.celda, objetivo.celda):
		return "sin línea de visión"
	return ""


## true si lanzarlo ahora fallaría por ser el segundo maleficio del turno.
func falla_por_maleficio(lanzador: Combatiente, conjuro: DefinicionConjuro) -> bool:
	return conjuro.tiene(DefinicionConjuro.Rasgo.MALEFICIO) and lanzador.maleficio_en_turno


## Criaturas sobre las que `lanzador` puede lanzar `conjuro` ahora.
func objetivos_validos(lanzador: Combatiente, conjuro: DefinicionConjuro) -> Array[Combatiente]:
	var lista: Array[Combatiente] = []
	for c: Combatiente in _combate().participantes:
		if motivo_imposible(lanzador, conjuro, c) == "":
			lista.append(c)
	return lista


## Efectos sostenidos de `lanzador` que todavía no sostuvo en este turno.
func por_sostener(lanzador: Combatiente) -> Array[EfectoSostenido]:
	var lista: Array[EfectoSostenido] = []
	for s: EfectoSostenido in sostenidos:
		if s.lanzador == lanzador.id and not s.sostenido_en_turno:
			lista.append(s)
	return lista


# --- Acciones ---

func lanzar(conjuro: DefinicionConjuro, id_objetivo: StringName, destino: Vector2i, recorrido: Array[Vector2i], es_paso: bool) -> Array[EventoCombate]:
	var combate: Combate = _combate()
	var actor: Combatiente = combate.turno_actual()
	var invalido: EventoCombate = combate.validar_accion(actor, conjuro.acciones, conjuro.nombre)
	if invalido != null:
		return [invalido]
	var objetivo: Combatiente = combate.combatiente(id_objetivo) if conjuro.objetivo == DefinicionConjuro.Objetivo.UNA_CRIATURA else actor
	var motivo: String = motivo_imposible(actor, conjuro, objetivo, destino, recorrido, es_paso)
	if motivo != "":
		return [combate.invalida(actor, conjuro.nombre, motivo)]
	actor.gastar_acciones(conjuro.acciones)
	actor.conjuros.gastar(conjuro)
	var eventos: Array[EventoCombate] = [combate.emitir(EventoCombate.new(EventoCombate.Tipo.LANZAMIENTO, actor.id,
		{"conjuro": conjuro, "objetivo": objetivo.id}))]
	if conjuro.tiene(DefinicionConjuro.Rasgo.MALEFICIO):
		if actor.maleficio_en_turno:
			eventos.append(_fallido(actor, conjuro, "ya lanzó un maleficio este turno"))
			return eventos
		actor.maleficio_en_turno = true
	var disparo: DisparoReaccion = DisparoReaccion.usa_manipular(actor)
	var resolver: Callable = func() -> Array[EventoCombate]:
		return _resolver(actor, conjuro, objetivo, destino, recorrido, es_paso, disparo)
	if conjuro.tiene(DefinicionConjuro.Rasgo.MANIPULAR):
		eventos.append_array(combate.reacciones.procesar(disparo, resolver))
	else:
		eventos.append_array(resolver.call())
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

func _resolver(actor: Combatiente, conjuro: DefinicionConjuro, objetivo: Combatiente, destino: Vector2i,
		recorrido: Array[Vector2i], es_paso: bool, disparo: DisparoReaccion) -> Array[EventoCombate]:
	var combate: Combate = _combate()
	if combate.estado != Combate.Estado.EN_CURSO or not actor.condiciones.en_pie():
		return []
	if disparo.interrumpida:
		return [_fallido(actor, conjuro, "interrumpido")]
	if conjuro.objetivo == DefinicionConjuro.Objetivo.UNO_MISMO:
		return _sobre_uno_mismo(actor, conjuro, destino, recorrido, es_paso)
	var antes: Dictionary = ReglasCondiciones.valores(combate)
	var resultado: ResultadoPrueba = null
	var aplicados: int = 0
	if conjuro.pide_salvacion():
		resultado = objetivo.prueba_salvacion(conjuro.salvacion()).resolver(combate.dados(), actor.prueba_conjuro().cd())
		for efecto: EfectoPorGrado in conjuro.efectos_de(resultado.grado):
			var condicion: EfectoCondicion = EfectoCondicion.new(efecto.condicion, efecto.valor, resultado.cd, actor.id)
			if efecto.rondas > 0:
				condicion.con_duracion(actor.id, efecto.rondas, true)
			objetivo.condiciones.aplicar(condicion)
			aplicados += 1
	var eventos: Array[EventoCombate] = [combate.emitir(EventoCombate.new(EventoCombate.Tipo.EFECTO_CONJURO, actor.id,
		{"conjuro": conjuro, "objetivo": objetivo.id, "resultado": resultado}))]
	if conjuro.es_sostenido() and aplicados > 0:
		sostenidos.append(EfectoSostenido.new(actor.id, conjuro, objetivo.id))
		actualizar_pisos()
	eventos.append_array(ReglasCondiciones.cambios_desde(combate, antes))
	return eventos


func _sobre_uno_mismo(actor: Combatiente, conjuro: DefinicionConjuro, destino: Vector2i, recorrido: Array[Vector2i], es_paso: bool) -> Array[EventoCombate]:
	var combate: Combate = _combate()
	# Bonificadores de estatus: no se suman, vale el mayor.
	actor.bonificador_velocidad = maxi(actor.bonificador_velocidad, conjuro.bonificador_velocidad)
	var eventos: Array[EventoCombate] = [combate.emitir(EventoCombate.new(EventoCombate.Tipo.EFECTO_CONJURO, actor.id,
		{"conjuro": conjuro, "objetivo": actor.id, "resultado": null}))]
	if destino == SIN_CELDA:
		return eventos
	if es_paso:
		eventos.append_array(combate.movimiento.mover_paso(actor, destino))
	else:
		eventos.append_array(combate.movimiento.mover_zancada(actor, destino, recorrido))
	return eventos


## Validación del movimiento incluido (con el bonificador de Velocidad del conjuro ya puesto).
func _motivo_movimiento(lanzador: Combatiente, conjuro: DefinicionConjuro, destino: Vector2i, recorrido: Array[Vector2i], es_paso: bool) -> String:
	if destino == SIN_CELDA:
		return ""
	if not conjuro.permite_moverse:
		return "no permite moverse"
	var anterior: int = lanzador.bonificador_velocidad
	lanzador.bonificador_velocidad = maxi(anterior, conjuro.bonificador_velocidad)
	var movimiento: AccionesMovimiento = _combate().movimiento
	var motivo: String = movimiento.motivo_paso_imposible(lanzador, destino) if es_paso \
		else movimiento.motivo_zancada_imposible(lanzador, destino, recorrido)
	lanzador.bonificador_velocidad = anterior
	return motivo


func _fallido(actor: Combatiente, conjuro: DefinicionConjuro, motivo: String) -> EventoCombate:
	return _combate().emitir(EventoCombate.new(EventoCombate.Tipo.CONJURO_FALLIDO, actor.id, {"conjuro": conjuro, "motivo": motivo}))


func _terminar(s: EfectoSostenido) -> EventoCombate:
	sostenidos.erase(s)
	var objetivo: Combatiente = _combate().combatiente(s.objetivo)
	for efecto: EfectoPorGrado in s.conjuro.efectos:
		objetivo.condiciones.quitar_piso(efecto.condicion, s.clave())
	return _combate().emitir(EventoCombate.new(EventoCombate.Tipo.FIN_CONJURO, s.lanzador, {"conjuro": s.conjuro, "objetivo": s.objetivo}))

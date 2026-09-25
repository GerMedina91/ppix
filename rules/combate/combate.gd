class_name Combate
extends RefCounted
## Máquina de estados de un combate de PF2e. Lógica pura: las escenas envían intenciones
## (zancada, paso, golpe, terminar_turno) y reciben eventos para mostrar.
## - Iniciativa: prueba de Percepción. Empate: primero los enemigos; si no, el orden de entrada.
## - Turno: 3 acciones. Zancada, Paso y Golpe cuestan 1. Moribundo: prueba de recuperación al empezar.
##   Quien no puede actuar (inconsciente o muerto) pierde el turno.
## - Fin: victoria si todos los enemigos murieron; derrota si toda la party está fuera de combate.
## - Reacciones (GestorReacciones): la Zancada se procesa casilla por casilla y el Golpe avisa antes de
##   tirar; si una reacción necesita la decisión del jugador, el combate queda en pausa con una pregunta
##   pendiente hasta responder_reaccion().
## Reproducible: con la misma semilla en Dados y las mismas intenciones, el registro es idéntico.

enum Estado { SIN_INICIAR, EN_CURSO, VICTORIA, DERROTA }

const COSTO_ZANCADA: int = 1
const COSTO_PASO: int = 1
const COSTO_GOLPE: int = 1
## Nombres de las acciones para los eventos de acción imposible (según docs/GLOSARIO.md).
const ACCION_ZANCADA: String = "Zancada"
const ACCION_PASO: String = "Paso"
const ACCION_GOLPE: String = "Golpe"

var participantes: Array[Combatiente] = []
var orden: Array[Combatiente] = []
var estado: Estado = Estado.SIN_INICIAR
var ronda: int = 0
var registro: Array[EventoCombate] = []
var reacciones: GestorReacciones = GestorReacciones.new(self)

var _indice_turno: int = 0
var _dados: Dados
var _grilla: GrillaMapa
var _vision: LineaVision
var _movimiento: MovimientoCombate


func _init(combatientes: Array[Combatiente], grilla: GrillaMapa, dados: Dados) -> void:
	participantes = combatientes
	_grilla = grilla
	_dados = dados
	_vision = LineaVision.new(grilla)
	_movimiento = MovimientoCombate.new(grilla)


func iniciar() -> Array[EventoCombate]:
	var eventos: Array[EventoCombate] = []
	var tiradas: Dictionary[Combatiente, int] = {}
	for c: Combatiente in participantes:
		var resultado: ResultadoPrueba = c.prueba_percepcion().resolver(_dados, 0)
		tiradas[c] = resultado.total
		eventos.append(_emitir(EventoCombate.new(EventoCombate.Tipo.INICIATIVA, c.id, {"total": resultado.total, "prueba": resultado})))
	orden = participantes.duplicate()
	orden.sort_custom(func(a: Combatiente, b: Combatiente) -> bool: return _va_antes(a, b, tiradas))
	estado = Estado.EN_CURSO
	ronda = 1
	_indice_turno = 0
	eventos.append(_emitir(EventoCombate.new(EventoCombate.Tipo.INICIO_RONDA, &"", {"ronda": ronda})))
	eventos.append_array(_empezar_turno())
	return eventos


func turno_actual() -> Combatiente:
	return orden[_indice_turno] if estado == Estado.EN_CURSO else null


func combatiente(id: StringName) -> Combatiente:
	for c: Combatiente in participantes:
		if c.id == id:
			return c
	return null


func vision() -> LineaVision:
	return _vision


func hay_reaccion_pendiente() -> bool:
	return reacciones.hay_pendiente()


## {"reactor", "capacidad", "disparo"} de la reacción que espera respuesta, o vacío.
func pregunta_de_reaccion() -> Dictionary:
	return reacciones.pregunta()


func responder_reaccion(usar: bool) -> Array[EventoCombate]:
	return reacciones.responder(usar)


func grilla() -> GrillaMapa:
	return _grilla


# --- Consultas para la presentación ---

## Casillas donde puede terminar una Zancada del combatiente, con su costo en pies.
func casillas_de_zancada(c: Combatiente) -> Dictionary[Vector2i, int]:
	return _movimiento.alcanzables(c.celda, c.fuente.velocidad_pies(), _bloqueadas_para(c), _de_aliados_de(c))


func camino_de_zancada(c: Combatiente, destino: Vector2i) -> Array[Vector2i]:
	return camino_de_zancada_desde(c, c.celda, destino)


## Camino de una Zancada de `c` que empieza en `desde` (para previsualizar planes de varias Zancadas).
func camino_de_zancada_desde(c: Combatiente, desde: Vector2i, destino: Vector2i) -> Array[Vector2i]:
	return _movimiento.camino(desde, destino, _bloqueadas_para(c), _de_aliados_de(c))


## Cantidad mínima de Zancadas para cada casilla, con las acciones que le quedan a `c`.
func alcance_de_zancadas(c: Combatiente) -> Dictionary[Vector2i, int]:
	return _movimiento.alcance_por_zancadas(c.celda, c.fuente.velocidad_pies(), c.acciones_restantes / COSTO_ZANCADA,
		_bloqueadas_para(c), _de_aliados_de(c))


## Dónde termina cada Zancada para llegar a `destino` (vacío si no le alcanzan las acciones).
## Cada Zancada se hace por separado con zancada(): son acciones distintas.
func plan_de_zancadas(c: Combatiente, destino: Vector2i) -> Array[Vector2i]:
	return _movimiento.plan_de_zancadas(c.celda, destino, c.fuente.velocidad_pies(), c.acciones_restantes / COSTO_ZANCADA,
		_bloqueadas_para(c), _de_aliados_de(c))


# --- Acciones (intenciones) ---

func zancada(destino: Vector2i) -> Array[EventoCombate]:
	var actor: Combatiente = turno_actual()
	var invalido: EventoCombate = _validar_accion(actor, COSTO_ZANCADA, ACCION_ZANCADA)
	if invalido != null:
		return [invalido]
	var camino: Array[Vector2i] = camino_de_zancada(actor, destino)
	if camino.is_empty() or MovimientoCombate.costo_de(actor.celda, camino) > actor.fuente.velocidad_pies():
		return [_invalida(actor, ACCION_ZANCADA, "fuera del alcance de la Zancada")]
	actor.gastar_acciones(COSTO_ZANCADA)
	return _avanzar_zancada(actor, camino, 0, false)


func paso(destino: Vector2i) -> Array[EventoCombate]:
	var actor: Combatiente = turno_actual()
	var invalido: EventoCombate = _validar_accion(actor, COSTO_PASO, ACCION_PASO)
	if invalido != null:
		return [invalido]
	var d: Vector2i = destino - actor.celda
	if absi(d.x) > 1 or absi(d.y) > 1 or d == Vector2i.ZERO or _ocupada(destino) or not _grilla.puede_dar_paso(actor.celda, destino):
		return [_invalida(actor, ACCION_PASO, "solo a una casilla libre adyacente")]
	actor.gastar_acciones(COSTO_PASO)
	var camino: Array[Vector2i] = [destino]
	return _mover(actor, camino, "paso")


func golpe(id_objetivo: StringName, arma: DefinicionArma = null) -> Array[EventoCombate]:
	var actor: Combatiente = turno_actual()
	var invalido: EventoCombate = _validar_accion(actor, COSTO_GOLPE, ACCION_GOLPE)
	if invalido != null:
		return [invalido]
	var objetivo: Combatiente = combatiente(id_objetivo)
	if objetivo == null:
		return [_invalida(actor, ACCION_GOLPE, "objetivo inexistente")]
	var arma_usada: DefinicionArma = arma if arma != null else actor.arma_principal()
	var motivo: Golpe.Motivo = Golpe.validar(actor, objetivo, arma_usada, _vision)
	if motivo != Golpe.Motivo.VALIDO:
		return [_golpe_invalido(actor, motivo)]
	actor.gastar_acciones(COSTO_GOLPE)
	# Antes de tirar: reacciones al ataque a distancia (p. ej. Golpe reactivo) y al ser objetivo (Esquiva ágil).
	var al_objetivo: DisparoReaccion = DisparoReaccion.objetivo_de_ataque(actor, objetivo, arma_usada)
	var tirar: Callable = func() -> Array[EventoCombate]: return _tirar_golpe(actor, objetivo, arma_usada, al_objetivo)
	var avisar_objetivo: Callable = func() -> Array[EventoCombate]: return reacciones.procesar(al_objetivo, tirar)
	if arma_usada.a_distancia:
		return reacciones.procesar(DisparoReaccion.ataque_a_distancia(actor, arma_usada), avisar_objetivo)
	return avisar_objetivo.call()


## Golpe de una reacción (Golpe reactivo): no gasta acciones ni cuenta para el penalizador por ataque múltiple.
func golpe_de_reaccion(reactor: Combatiente, objetivo: Combatiente, arma: DefinicionArma) -> Array[EventoCombate]:
	var estaba_en_pie: bool = objetivo.condiciones.puede_actuar()
	var resultado: ResultadoGolpe = Golpe.resolver(reactor, objetivo, arma, _dados, participantes, _vision, [], false)
	if not resultado.es_valido():
		return []
	var eventos: Array[EventoCombate] = [emitir(EventoCombate.new(EventoCombate.Tipo.GOLPE, reactor.id,
		{"objetivo": objetivo.id, "resultado": resultado, "reaccion": true}))]
	eventos.append_array(_eventos_de_estado(objetivo, estaba_en_pie))
	eventos.append_array(_verificar_fin())
	return eventos


func terminar_turno() -> Array[EventoCombate]:
	var actor: Combatiente = turno_actual()
	if actor == null or hay_reaccion_pendiente():
		return []
	var eventos: Array[EventoCombate] = [_emitir(EventoCombate.new(EventoCombate.Tipo.FIN_TURNO, actor.id))]
	eventos.append_array(_avanzar_turno())
	return eventos


# --- Internos ---

func _empezar_turno() -> Array[EventoCombate]:
	var eventos: Array[EventoCombate] = []
	var actor: Combatiente = turno_actual()
	actor.empezar_turno()
	eventos.append(_emitir(EventoCombate.new(EventoCombate.Tipo.INICIO_TURNO, actor.id, {"ronda": ronda})))
	if actor.condiciones.moribundo > 0:
		var resultado: ResultadoPrueba = actor.prueba_de_recuperacion(_dados)
		eventos.append(_emitir(EventoCombate.new(EventoCombate.Tipo.RECUPERACION, actor.id,
			{"resultado": resultado, "moribundo": actor.condiciones.moribundo})))
		if actor.condiciones.muerto:
			eventos.append(_emitir(EventoCombate.new(EventoCombate.Tipo.MUERTE, actor.id)))
			eventos.append_array(_verificar_fin())
	if estado == Estado.EN_CURSO and not actor.condiciones.puede_actuar():
		eventos.append(_emitir(EventoCombate.new(EventoCombate.Tipo.TURNO_PERDIDO, actor.id)))
		eventos.append_array(_avanzar_turno())
	return eventos


func _avanzar_turno() -> Array[EventoCombate]:
	if estado != Estado.EN_CURSO:
		return []
	var eventos: Array[EventoCombate] = []
	# Los muertos no tienen turno; los inconscientes sí (prueba de recuperación).
	for i in orden.size():
		_indice_turno += 1
		if _indice_turno >= orden.size():
			_indice_turno = 0
			ronda += 1
			eventos.append(_emitir(EventoCombate.new(EventoCombate.Tipo.INICIO_RONDA, &"", {"ronda": ronda})))
		if not orden[_indice_turno].condiciones.muerto:
			break
	eventos.append_array(_empezar_turno())
	return eventos


## Avanza la Zancada casilla por casilla desde `indice`; antes de salir de cada casilla ofrece las
## reacciones (salvo `disparo_resuelto`, que evita volver a ofrecerlas en la casilla donde se retoma).
## Si el que se mueve queda fuera de combate, el movimiento se corta ahí.
func _avanzar_zancada(actor: Combatiente, camino: Array[Vector2i], indice: int, disparo_resuelto: bool) -> Array[EventoCombate]:
	var eventos: Array[EventoCombate] = []
	var desde: Vector2i = actor.celda
	var recorrido: Array[Vector2i] = []
	var i: int = indice
	var resuelto: bool = disparo_resuelto
	while i < camino.size() and actor.condiciones.puede_actuar() and estado == Estado.EN_CURSO:
		if not resuelto:
			var disparo: DisparoReaccion = DisparoReaccion.sale_de_casilla(actor, actor.celda)
			if reacciones.hay_candidatos(disparo):
				if not recorrido.is_empty():
					eventos.append(_evento_movimiento(actor, desde, recorrido, indice > 0 or disparo_resuelto))
				var siguiente: int = i
				eventos.append_array(reacciones.procesar(disparo,
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
	return emitir(EventoCombate.new(EventoCombate.Tipo.MOVIMIENTO, actor.id,
		{"desde": desde, "camino": recorrido.duplicate(), "tipo": "zancada", "continua": continua}))


## Tira el Golpe si el atacante sigue en pie después de las reacciones (si cayó, el ataque se pierde).
func _tirar_golpe(actor: Combatiente, objetivo: Combatiente, arma: DefinicionArma, disparo: DisparoReaccion) -> Array[EventoCombate]:
	if estado != Estado.EN_CURSO or not actor.condiciones.puede_actuar() or objetivo.condiciones.muerto:
		return []
	var estaba_en_pie: bool = objetivo.condiciones.puede_actuar()
	var resultado: ResultadoGolpe = Golpe.resolver(actor, objetivo, arma, _dados, participantes, _vision, disparo.bonificadores_ca)
	if not resultado.es_valido():
		return [_golpe_invalido(actor, resultado.motivo)]
	var eventos: Array[EventoCombate] = [emitir(EventoCombate.new(EventoCombate.Tipo.GOLPE, actor.id,
		{"objetivo": objetivo.id, "resultado": resultado}))]
	eventos.append_array(_eventos_de_estado(objetivo, estaba_en_pie))
	eventos.append_array(_verificar_fin())
	return eventos


func _mover(actor: Combatiente, camino: Array[Vector2i], tipo: String) -> Array[EventoCombate]:
	var desde: Vector2i = actor.celda
	actor.celda = camino.back()
	return [_emitir(EventoCombate.new(EventoCombate.Tipo.MOVIMIENTO, actor.id,
		{"desde": desde, "camino": camino, "tipo": tipo}))]


func _eventos_de_estado(objetivo: Combatiente, estaba_en_pie: bool) -> Array[EventoCombate]:
	var eventos: Array[EventoCombate] = []
	if objetivo.condiciones.muerto:
		eventos.append(_emitir(EventoCombate.new(EventoCombate.Tipo.MUERTE, objetivo.id)))
	elif estaba_en_pie and not objetivo.condiciones.puede_actuar():
		eventos.append(_emitir(EventoCombate.new(EventoCombate.Tipo.CAIDO, objetivo.id, {"moribundo": objetivo.condiciones.moribundo})))
	return eventos


func _verificar_fin() -> Array[EventoCombate]:
	if estado != Estado.EN_CURSO:
		return []
	var enemigos_vivos: bool = participantes.any(func(c: Combatiente) -> bool:
		return c.bando == Combatiente.Bando.ENEMIGOS and not c.condiciones.muerto)
	var party_en_pie: bool = participantes.any(func(c: Combatiente) -> bool:
		return c.bando == Combatiente.Bando.PARTY and c.condiciones.puede_actuar())
	if not enemigos_vivos:
		estado = Estado.VICTORIA
	elif not party_en_pie:
		estado = Estado.DERROTA
	else:
		return []
	return [_emitir(EventoCombate.new(EventoCombate.Tipo.FIN_COMBATE, &"", {"estado": estado}))]


func _validar_accion(actor: Combatiente, costo: int, accion: String) -> EventoCombate:
	if estado != Estado.EN_CURSO or actor == null:
		return EventoCombate.new(EventoCombate.Tipo.ACCION_INVALIDA, &"", {"accion": accion, "motivo": "el combate no está en curso"})
	if hay_reaccion_pendiente():
		return _invalida(actor, accion, "esperando una reacción")
	if not actor.condiciones.puede_actuar():
		return _invalida(actor, accion, "no puede actuar")
	if actor.acciones_restantes < costo:
		if accion == ACCION_GOLPE:
			return _golpe_invalido(actor, Golpe.Motivo.SIN_ACCIONES)
		return _invalida(actor, accion, Golpe.texto_motivo(Golpe.Motivo.SIN_ACCIONES))
	return null


## Acción imposible: {"accion": "Golpe" | "Zancada" | "Paso", "motivo": texto para mostrar}.
func _invalida(actor: Combatiente, accion: String, motivo: String) -> EventoCombate:
	return EventoCombate.new(EventoCombate.Tipo.ACCION_INVALIDA, actor.id, {"accion": accion, "motivo": motivo})


## Golpe imposible: además del texto, el Golpe.Motivo.
func _golpe_invalido(actor: Combatiente, motivo: Golpe.Motivo) -> EventoCombate:
	var evento: EventoCombate = _invalida(actor, ACCION_GOLPE, Golpe.texto_motivo(motivo))
	evento.datos["motivo_golpe"] = motivo
	return evento


## Casillas de oponentes que no murieron: no se pueden atravesar.
func _bloqueadas_para(c: Combatiente) -> Dictionary:
	var bloqueadas: Dictionary = {}
	for otro: Combatiente in participantes:
		if not otro.es_aliado_de(c) and not otro.condiciones.muerto:
			bloqueadas[otro.celda] = true
	return bloqueadas


## Casillas de aliados (se atraviesan, no se termina ahí).
func _de_aliados_de(c: Combatiente) -> Dictionary:
	var aliadas: Dictionary = {}
	for otro: Combatiente in participantes:
		if otro != c and otro.es_aliado_de(c) and not otro.condiciones.muerto:
			aliadas[otro.celda] = true
	return aliadas


func _ocupada(casilla: Vector2i) -> bool:
	return participantes.any(func(c: Combatiente) -> bool: return c.celda == casilla and not c.condiciones.muerto)


func _va_antes(a: Combatiente, b: Combatiente, tiradas: Dictionary[Combatiente, int]) -> bool:
	if tiradas[a] != tiradas[b]:
		return tiradas[a] > tiradas[b]
	if a.bando != b.bando:
		return a.bando == Combatiente.Bando.ENEMIGOS
	return participantes.find(a) < participantes.find(b)


## Registra el evento (también lo usa el GestorReacciones).
func emitir(evento: EventoCombate) -> EventoCombate:
	registro.append(evento)
	return evento


func _emitir(evento: EventoCombate) -> EventoCombate:
	return emitir(evento)

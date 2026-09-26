class_name Combate
extends RefCounted
## Máquina de estados de un combate de PF2e. Lógica pura: las escenas envían intenciones
## (zancada, paso, golpe, terminar_turno) y reciben eventos para mostrar.
## - Iniciativa: prueba de Percepción. Empate: primero los enemigos; si no, el orden de entrada.
## - Turno: 3 acciones. Zancada, Paso, Golpe y Arcadas cuestan 1. Moribundo: prueba de recuperación al
##   empezar. Quien no puede actuar (inconsciente, muerto o aturdido sin acciones) pierde el turno.
## - Condiciones con valor (duraciones, asustado, aturdido, huyendo): ver ReglasCondiciones.
## - Movimiento (Zancada, Paso): AccionesMovimiento. Golpe: AccionesGolpe. Conjuros (lanzar, Sostener):
##   AccionesConjuro. Inicio y fin de turno: CicloTurno. Arcadas y condiciones: ReglasCondiciones.
## - Fin: victoria si todos los enemigos murieron; derrota si toda la party está fuera de combate.
## - Reacciones (GestorReacciones): la Zancada se procesa casilla por casilla y el Golpe avisa antes de
##   tirar; si una reacción necesita la decisión del jugador, el combate queda en pausa con una pregunta
##   pendiente hasta responder_reaccion().
## Reproducible: con la misma semilla en Dados y las mismas intenciones, el registro es idéntico.

enum Estado { SIN_INICIAR, EN_CURSO, VICTORIA, DERROTA }

const COSTO_ZANCADA: int = 1
const COSTO_PASO: int = 1
const COSTO_GOLPE: int = 1
const COSTO_ARCADAS: int = 1
## Nombres de las acciones para los eventos de acción imposible (según docs/GLOSARIO.md).
const ACCION_ZANCADA: String = "Zancada"
const ACCION_PASO: String = "Paso"
const ACCION_GOLPE: String = "Golpe"
const ACCION_ARCADAS: String = "Arcadas"
const MOTIVO_HUYENDO: String = "huyendo: solo puede alejarse"

var participantes: Array[Combatiente] = []
var orden: Array[Combatiente] = []
var estado: Estado = Estado.SIN_INICIAR
var ronda: int = 0
var registro: Array[EventoCombate] = []
var reacciones: GestorReacciones = GestorReacciones.new(self)
## Zancada y Paso (se crea con la grilla).
var movimiento: AccionesMovimiento
var conjuros: AccionesConjuro = AccionesConjuro.new(self)
var golpes: AccionesGolpe = AccionesGolpe.new(self)
## La presentación lo activa: después de usar una reacción, la acción interrumpida no sigue sola; espera
## continuar(), así se puede animar la reacción con el estado del combate en ese punto.
var pausar_tras_reacciones: bool = false
## Si todos tienen su reacción desde que empieza el combate, antes de su primer turno (Player Core p. 436:
## lo decide el DJ; nuestra decisión: sí). Se fija antes de iniciar().
var reacciones_antes_del_primer_turno: bool = true

var _indice_turno: int = 0
var _dados: Dados
var _grilla: GrillaMapa
var _vision: LineaVision


func _init(combatientes: Array[Combatiente], grilla: GrillaMapa, dados: Dados) -> void:
	participantes = combatientes
	_grilla = grilla
	_dados = dados
	_vision = LineaVision.new(grilla)
	movimiento = AccionesMovimiento.new(self, grilla)


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
	for c: Combatiente in participantes:
		c.reaccion_disponible = reacciones_antes_del_primer_turno
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


## true si una acción quedó a mitad de camino tras una reacción (con pausar_tras_reacciones).
func hay_continuacion() -> bool:
	return reacciones.hay_continuacion()


func continuar() -> Array[EventoCombate]:
	return reacciones.continuar()


func grilla() -> GrillaMapa:
	return _grilla


func dados() -> Dados:
	return _dados


# --- Consultas para la presentación ---

## Casillas donde puede terminar una Zancada del combatiente, con su costo en pies.
func casillas_de_zancada(c: Combatiente) -> Dictionary[Vector2i, int]:
	return movimiento.casillas_de_zancada(c)


func camino_de_zancada(c: Combatiente, destino: Vector2i) -> Array[Vector2i]:
	return movimiento.camino_de_zancada(c, destino)


## Alcance de `c` con las Zancadas que le permiten sus acciones: casillas, plan y recorrido de cada una.
func alcance_de_zancadas(c: Combatiente) -> AlcanceZancadas:
	return movimiento.alcance_de_zancadas(c, c.acciones_restantes / COSTO_ZANCADA)


# --- Acciones (intenciones) ---

## `recorrido`: casillas por las que pasa (p. ej. el tramo previsto de un plan de varias Zancadas);
## si falta, va por el camino más barato.
func zancada(destino: Vector2i, recorrido: Array[Vector2i] = []) -> Array[EventoCombate]:
	return movimiento.zancada(destino, recorrido)


func paso(destino: Vector2i) -> Array[EventoCombate]:
	return movimiento.paso(destino)


## Lanza `conjuro`: sobre `id_objetivo`, o sobre sí mismo (con `destino` si incluye un Paso o una Zancada).
func lanzar_conjuro(conjuro: DefinicionConjuro, id_objetivo: StringName = &"", destino: Vector2i = AccionesConjuro.SIN_CELDA,
		recorrido: Array[Vector2i] = [], es_paso: bool = false) -> Array[EventoCombate]:
	return conjuros.lanzar(conjuro, id_objetivo, destino, recorrido, es_paso)


func sostener() -> Array[EventoCombate]:
	return conjuros.sostener()


func golpe(id_objetivo: StringName, arma: DefinicionArma = null) -> Array[EventoCombate]:
	return golpes.golpe(id_objetivo, arma)


## Golpe de una reacción (Golpe reactivo): no gasta acciones ni cuenta para el penalizador por ataque múltiple.
func golpe_de_reaccion(reactor: Combatiente, objetivo: Combatiente, arma: DefinicionArma) -> Array[EventoCombate]:
	return golpes.golpe_de_reaccion(reactor, objetivo, arma)


## Arcadas: 1 acción para intentar bajar indispuesto (ReglasCondiciones).
func arcadas() -> Array[EventoCombate]:
	return ReglasCondiciones.accion_arcadas(self)


func terminar_turno() -> Array[EventoCombate]:
	var actor: Combatiente = turno_actual()
	if actor == null or hay_reaccion_pendiente() or hay_continuacion():
		return []
	var eventos: Array[EventoCombate] = CicloTurno.fin(self, actor)
	eventos.append(_emitir(EventoCombate.new(EventoCombate.Tipo.FIN_TURNO, actor.id)))
	eventos.append_array(_avanzar_turno())
	return eventos


# --- Internos ---

func _empezar_turno() -> Array[EventoCombate]:
	var actor: Combatiente = turno_actual()
	var eventos: Array[EventoCombate] = CicloTurno.inicio(self, actor)
	if estado == Estado.EN_CURSO and CicloTurno.pierde_el_turno(actor):
		eventos.append(_emitir(EventoCombate.new(EventoCombate.Tipo.TURNO_PERDIDO, actor.id)))
		eventos.append_array(CicloTurno.fin(self, actor))
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


## MUERTE o CAIDO del objetivo si corresponde (también lo usan los conjuros con daño).
func eventos_de_estado(objetivo: Combatiente, estaba_en_pie: bool) -> Array[EventoCombate]:
	var eventos: Array[EventoCombate] = []
	if objetivo.condiciones.muerto:
		eventos.append(_emitir(EventoCombate.new(EventoCombate.Tipo.MUERTE, objetivo.id)))
	elif estaba_en_pie and not objetivo.condiciones.en_pie():
		eventos.append(_emitir(EventoCombate.new(EventoCombate.Tipo.CAIDO, objetivo.id, {"moribundo": objetivo.condiciones.moribundo})))
	return eventos


## Victoria o derrota si corresponde (FIN_COMBATE); vacío si el combate sigue.
func verificar_fin() -> Array[EventoCombate]:
	if estado != Estado.EN_CURSO:
		return []
	var enemigos_vivos: bool = participantes.any(func(c: Combatiente) -> bool:
		return c.bando == Combatiente.Bando.ENEMIGOS and not c.condiciones.muerto)
	var party_en_pie: bool = participantes.any(func(c: Combatiente) -> bool:
		return c.bando == Combatiente.Bando.PARTY and c.condiciones.en_pie())
	if not enemigos_vivos:
		estado = Estado.VICTORIA
	elif not party_en_pie:
		estado = Estado.DERROTA
	else:
		return []
	return [_emitir(EventoCombate.new(EventoCombate.Tipo.FIN_COMBATE, &"", {"estado": estado}))]


## Evento de acción imposible si `actor` no puede usar ahora una acción de `costo` (null si puede).
## También lo usan las clases de acciones (AccionesMovimiento).
func validar_accion(actor: Combatiente, costo: int, accion: String) -> EventoCombate:
	if estado != Estado.EN_CURSO or actor == null:
		return EventoCombate.new(EventoCombate.Tipo.ACCION_INVALIDA, &"", {"accion": accion, "motivo": "el combate no está en curso"})
	if hay_reaccion_pendiente() or hay_continuacion():
		return invalida(actor, accion, "esperando una reacción")
	if not actor.condiciones.puede_actuar():
		return invalida(actor, accion, "no puede actuar")
	if actor.condiciones.tiene(Condiciones.Tipo.HUYENDO) and accion != ACCION_ZANCADA and accion != ACCION_PASO:
		return invalida(actor, accion, MOTIVO_HUYENDO)
	if actor.acciones_restantes < costo:
		if accion == ACCION_GOLPE:
			return golpes.invalido_por(actor, Golpe.Motivo.SIN_ACCIONES)
		return invalida(actor, accion, Golpe.texto_motivo(Golpe.Motivo.SIN_ACCIONES))
	return null


## Acción imposible: {"accion": "Golpe" | "Zancada" | "Paso", "motivo": texto para mostrar}.
func invalida(actor: Combatiente, accion: String, motivo: String) -> EventoCombate:
	return EventoCombate.new(EventoCombate.Tipo.ACCION_INVALIDA, actor.id, {"accion": accion, "motivo": motivo})


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

class_name AccionesGolpe
extends RefCounted
## Golpe (1 acción, rasgo ataque) y Golpe de una reacción. Combate expone la API y delega acá (referencia
## débil al Combate, como GestorReacciones). Antes de tirar se ofrecen las reacciones al ataque a distancia
## (Golpe reactivo) y al ser objetivo (Esquiva ágil); si el atacante cae antes, el ataque se pierde.

var _combate_ref: WeakRef


func _init(combate: Combate) -> void:
	_combate_ref = weakref(combate)


func _combate() -> Combate:
	return _combate_ref.get_ref() as Combate


func golpe(id_objetivo: StringName, arma: DefinicionArma) -> Array[EventoCombate]:
	var combate: Combate = _combate()
	var actor: Combatiente = combate.turno_actual()
	var invalido: EventoCombate = combate.validar_accion(actor, Combate.COSTO_GOLPE, Combate.ACCION_GOLPE)
	if invalido != null:
		return [invalido]
	var objetivo: Combatiente = combate.combatiente(id_objetivo)
	if objetivo == null:
		return [combate.invalida(actor, Combate.ACCION_GOLPE, "objetivo inexistente")]
	var arma_usada: DefinicionArma = arma if arma != null else actor.arma_principal()
	var motivo: Golpe.Motivo = Golpe.validar(actor, objetivo, arma_usada, combate.vision())
	if motivo != Golpe.Motivo.VALIDO:
		return [invalido_por(actor, motivo)]
	actor.gastar_acciones(Combate.COSTO_GOLPE)
	var al_objetivo: DisparoReaccion = DisparoReaccion.objetivo_de_ataque(actor, objetivo, arma_usada)
	var tirar: Callable = func() -> Array[EventoCombate]: return _tirar(actor, objetivo, arma_usada, al_objetivo)
	var avisar_objetivo: Callable = func() -> Array[EventoCombate]: return combate.reacciones.procesar(al_objetivo, tirar)
	if arma_usada.a_distancia:
		return combate.reacciones.procesar(DisparoReaccion.ataque_a_distancia(actor, arma_usada), avisar_objetivo)
	return avisar_objetivo.call()


## Golpe de una reacción (Golpe reactivo): no gasta acciones ni cuenta para el penalizador por ataque múltiple.
func golpe_de_reaccion(reactor: Combatiente, objetivo: Combatiente, arma: DefinicionArma) -> Array[EventoCombate]:
	var combate: Combate = _combate()
	var estaba_en_pie: bool = objetivo.condiciones.en_pie()
	var resultado: ResultadoGolpe = Golpe.resolver(reactor, objetivo, arma, combate.dados(), combate.participantes, combate.vision(), [], false)
	if not resultado.es_valido():
		return []
	var eventos: Array[EventoCombate] = [combate.emitir(EventoCombate.new(EventoCombate.Tipo.GOLPE, reactor.id,
		{"objetivo": objetivo.id, "resultado": resultado, "reaccion": true}))]
	eventos.append_array(combate.eventos_de_estado(objetivo, estaba_en_pie))
	eventos.append_array(combate.verificar_fin())
	return eventos


## Golpe imposible: además del texto, el Golpe.Motivo.
func invalido_por(actor: Combatiente, motivo: Golpe.Motivo) -> EventoCombate:
	var evento: EventoCombate = _combate().invalida(actor, Combate.ACCION_GOLPE, Golpe.texto_motivo(motivo))
	evento.datos["motivo_golpe"] = motivo
	return evento


## Tira el Golpe si el atacante sigue en pie después de las reacciones (si cayó, el ataque se pierde).
func _tirar(actor: Combatiente, objetivo: Combatiente, arma: DefinicionArma, disparo: DisparoReaccion) -> Array[EventoCombate]:
	var combate: Combate = _combate()
	if combate.estado != Combate.Estado.EN_CURSO or not actor.condiciones.puede_actuar() or objetivo.condiciones.muerto:
		return []
	var estaba_en_pie: bool = objetivo.condiciones.en_pie()
	var resultado: ResultadoGolpe = Golpe.resolver(actor, objetivo, arma, combate.dados(), combate.participantes, combate.vision(), disparo.bonificadores_ca)
	if not resultado.es_valido():
		return [invalido_por(actor, resultado.motivo)]
	var eventos: Array[EventoCombate] = [combate.emitir(EventoCombate.new(EventoCombate.Tipo.GOLPE, actor.id,
		{"objetivo": objetivo.id, "resultado": resultado}))]
	eventos.append_array(combate.eventos_de_estado(objetivo, estaba_en_pie))
	eventos.append_array(combate.verificar_fin())
	return eventos

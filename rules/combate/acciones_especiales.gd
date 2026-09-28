class_name AccionesEspeciales
extends RefCounted
## Acciones que vienen de dotes y habilidades (M4b; verificadas en c4_conjuros.md y m4_recuerdos.md). Combate
## las expone en `especiales` (referencia débil al Combate, como GestorReacciones).
## - Tomar cobertura (acción básica, 1 acción; Player Core p. 418): requiere estar junto a una pared (en cruz) o
##   tener cobertura normal frente a algún enemigo. Da cobertura mayor donde ya había normal y normal en el resto
##   (Cobertura), hasta moverse, atacar o quedar inconsciente.
## - Carga repentina (guerrero, 2 acciones, floritura): dos Zancadas y, si termina a alcance cuerpo a cuerpo
##   del enemigo, un Golpe cuerpo a cuerpo contra él. Se elige el enemigo y se va a la casilla más cercana
##   desde la que se lo alcanza.

const CARGA_REPENTINA: StringName = &"carga_repentina"
const ACCION_TOMAR_COBERTURA: String = "Tomar cobertura"
const VECINAS_EN_CRUZ: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
const COSTO_CARGA: int = 2
const ZANCADAS_CARGA: int = 2

var _combate_ref: WeakRef


func _init(combate: Combate) -> void:
	_combate_ref = weakref(combate)


func _combate() -> Combate:
	return _combate_ref.get_ref() as Combate


## true si el combatiente tiene la capacidad con ese id (dote o recuerdo integrado).
static func tiene(c: Combatiente, id: StringName) -> bool:
	return c.fuente.capacidades().any(func(capacidad: Capacidad) -> bool: return capacidad.id == id)


# --- Tomar cobertura ---

func motivo_tomar_cobertura_imposible(actor: Combatiente) -> String:
	if actor.tomando_cobertura:
		return "ya está a cubierto"
	var combate: Combate = _combate()
	var vision: LineaVision = combate.vision()
	if VECINAS_EN_CRUZ.any(func(d: Vector2i) -> bool: return vision.es_opaca(actor.celda + d)):
		return ""
	for c: Combatiente in combate.participantes:
		if not c.es_aliado_de(actor) and not c.condiciones.muerto and vision.tapa_la_recta_central(c.celda, actor.celda):
			return ""
	return "no hay dónde cubrirse"


func tomar_cobertura() -> Array[EventoCombate]:
	var combate: Combate = _combate()
	var actor: Combatiente = combate.turno_actual()
	var invalido: EventoCombate = combate.validar_accion(actor, 1, ACCION_TOMAR_COBERTURA)
	if invalido != null:
		return [invalido]
	var motivo: String = motivo_tomar_cobertura_imposible(actor)
	if motivo != "":
		return [combate.invalida(actor, ACCION_TOMAR_COBERTURA, motivo)]
	actor.gastar_acciones(1)
	actor.tomando_cobertura = true
	return [combate.emitir(EventoCombate.new(EventoCombate.Tipo.ACCION_ESPECIAL, actor.id, {"accion": ACCION_TOMAR_COBERTURA}))]


# --- Carga repentina ---

## Casilla donde terminaría la Carga repentina contra `objetivo` (null si no llega): la de menos Zancadas;
## si ya lo alcanza, no se mueve (Vector2i de su casilla).
func destino_de_carga(actor: Combatiente, objetivo: Combatiente) -> Variant:
	var arma: DefinicionArma = _arma_cuerpo_a_cuerpo(actor)
	if arma == null or objetivo == null or objetivo.es_aliado_de(actor) or objetivo.condiciones.muerto:
		return null
	var combate: Combate = _combate()
	if Golpe.validar(actor, objetivo, arma, combate.vision()) == Golpe.Motivo.VALIDO:
		return actor.celda
	var alcance: AlcanceZancadas = combate.movimiento.alcance_de_zancadas(actor, ZANCADAS_CARGA)
	var original: Vector2i = actor.celda
	var mejor: Variant = null
	var claves: Array = alcance.por_casilla.keys()
	claves.sort()
	for casilla: Vector2i in claves:
		actor.celda = casilla
		var alcanza: bool = Golpe.validar(actor, objetivo, arma, combate.vision()) == Golpe.Motivo.VALIDO
		if alcanza and (mejor == null or alcance.por_casilla[casilla] < alcance.por_casilla[mejor]):
			mejor = casilla
	actor.celda = original
	return mejor


func motivo_carga_imposible(actor: Combatiente, objetivo: Combatiente) -> String:
	if not tiene(actor, CARGA_REPENTINA):
		return "no tiene esa dote"
	if actor.floritura_en_turno:
		return "ya usó una floritura este turno"
	if _arma_cuerpo_a_cuerpo(actor) == null:
		return "sin arma cuerpo a cuerpo"
	if destino_de_carga(actor, objetivo) == null:
		return "no llega"
	return ""


func carga_repentina(id_objetivo: StringName) -> Array[EventoCombate]:
	var combate: Combate = _combate()
	var actor: Combatiente = combate.turno_actual()
	var invalido: EventoCombate = combate.validar_accion(actor, COSTO_CARGA, "Carga repentina")
	if invalido != null:
		return [invalido]
	var objetivo: Combatiente = combate.combatiente(id_objetivo)
	var motivo: String = motivo_carga_imposible(actor, objetivo)
	if motivo != "":
		return [combate.invalida(actor, "Carga repentina", motivo)]
	var destino: Vector2i = destino_de_carga(actor, objetivo)
	var tramos: Array[Array] = []
	if destino != actor.celda:
		tramos = combate.movimiento.alcance_de_zancadas(actor, ZANCADAS_CARGA).tramos(destino)
	actor.gastar_acciones(COSTO_CARGA)
	actor.floritura_en_turno = true
	var eventos: Array[EventoCombate] = [combate.emitir(EventoCombate.new(EventoCombate.Tipo.ACCION_ESPECIAL, actor.id,
		{"accion": "Carga repentina", "objetivo": objetivo.id}))]
	eventos.append_array(_tramo_de_carga(actor, objetivo, tramos))
	return eventos


## Hace el siguiente tramo de la carga y, al terminar todos, el Golpe (si sigue en pie y lo alcanza).
func _tramo_de_carga(actor: Combatiente, objetivo: Combatiente, tramos: Array[Array]) -> Array[EventoCombate]:
	var combate: Combate = _combate()
	if combate.estado != Combate.Estado.EN_CURSO or not actor.condiciones.puede_actuar():
		return []
	if tramos.is_empty():
		var arma: DefinicionArma = _arma_cuerpo_a_cuerpo(actor)
		if objetivo.condiciones.muerto or Golpe.validar(actor, objetivo, arma, combate.vision()) != Golpe.Motivo.VALIDO:
			return []
		return combate.golpes.golpe_incluido(actor, objetivo, arma)
	var tramo: Array[Vector2i] = []
	tramo.assign(tramos[0])
	var resto: Array[Array] = []
	resto.assign(tramos.slice(1))
	return combate.movimiento.mover_zancada(actor, tramo.back(), tramo,
		func() -> Array[EventoCombate]: return _tramo_de_carga(actor, objetivo, resto))


static func _arma_cuerpo_a_cuerpo(c: Combatiente) -> DefinicionArma:
	for arma: DefinicionArma in c.fuente.armas():
		if not arma.a_distancia:
			return arma
	return null

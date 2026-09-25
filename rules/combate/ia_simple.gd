class_name IASimple
extends RefCounted
## IA simple para enemigos. Juega el turno del combatiente actual y lo termina.
## Mientras tenga acciones:
## 1. Si puede golpear a un oponente en pie (alcance + línea de visión), golpea al más cercano (empate: menos PG).
## 2. Si no, Zancada: cuerpo a cuerpo, a una casilla desde la que llegue al objetivo más cercano;
##    a distancia, a una casilla desde la que pueda disparar. Si no llega, se acerca lo más posible.
## 3. A distancia: si empieza pegado a un oponente, primero se aleja con un Paso (si hay dónde).
## Caídos (inconscientes): solo los ataca si su perfil de IA tiene `remata_caidos` (por defecto no).
## Huyendo: Zancada a la casilla más lejana de la fuente (si lo aleja); si no puede, termina el turno.

## Tope de seguridad de decisiones por turno (cada una gasta al menos una acción o termina).
const _DECISIONES_MAXIMAS: int = 6


## Juega el turno entero del combatiente actual (varias acciones y terminar turno).
static func jugar_turno(combate: Combate) -> Array[EventoCombate]:
	var eventos: Array[EventoCombate] = []
	var actor: Combatiente = combate.turno_actual()
	for i in _DECISIONES_MAXIMAS + 1:
		if actor == null or combate.turno_actual() != actor:
			break
		eventos.append_array(jugar_accion(combate))
	return eventos


## Resuelve UNA decisión del combatiente actual: un Paso, un Golpe o una Zancada; si no le queda
## nada útil que hacer, termina el turno. La presentación anima cada decisión antes de pedir la
## siguiente, así el estado del Combate y lo que se ve en el mapa avanzan juntos.
static func jugar_accion(combate: Combate) -> Array[EventoCombate]:
	var actor: Combatiente = combate.turno_actual()
	if actor == null:
		return []
	var arma: DefinicionArma = actor.arma_principal()
	if actor.acciones_restantes <= 0:
		return combate.terminar_turno()
	var huida: Combatiente = ReglasCondiciones.fuente_de_huida(combate, actor)
	if huida != null:
		return _huir(combate, actor, huida)
	if arma == null:
		return combate.terminar_turno()
	if arma.a_distancia and actor.acciones_restantes == Combatiente.ACCIONES_POR_TURNO:
		var alejarse: Array[EventoCombate] = _alejarse_si_esta_pegado(combate, actor)
		if not alejarse.is_empty():
			return alejarse
	var objetivo: Combatiente = _objetivo_golpeable(combate, actor, arma)
	if objetivo != null:
		return combate.golpe(objetivo.id, arma)
	var destino: Variant = _mejor_destino(combate, actor, arma)
	if destino != null:
		var movimiento: Array[EventoCombate] = combate.zancada(destino)
		if movimiento.back().tipo != EventoCombate.Tipo.ACCION_INVALIDA:
			return movimiento
	return combate.terminar_turno()


static func _huir(combate: Combate, actor: Combatiente, fuente: Combatiente) -> Array[EventoCombate]:
	var mejor: Vector2i = actor.celda
	for casilla: Vector2i in combate.casillas_de_zancada(actor):
		if Medicion.pies_entre(casilla, fuente.celda) > Medicion.pies_entre(mejor, fuente.celda):
			mejor = casilla
	if mejor == actor.celda:
		return combate.terminar_turno()
	return combate.zancada(mejor)


## Oponentes vivos que la IA considera: en pie, o también caídos si su perfil remata caídos.
static func _oponentes(combate: Combate, actor: Combatiente) -> Array[Combatiente]:
	var lista: Array[Combatiente] = []
	for c: Combatiente in combate.participantes:
		if c.es_aliado_de(actor) or c.condiciones.muerto:
			continue
		if c.condiciones.en_pie() or actor.fuente.remata_caidos():
			lista.append(c)
	return lista


static func _objetivo_golpeable(combate: Combate, actor: Combatiente, arma: DefinicionArma) -> Combatiente:
	var candidatos: Array[Combatiente] = _oponentes(combate, actor).filter(func(c: Combatiente) -> bool:
		return Golpe.validar(actor, c, arma, combate.vision()) == Golpe.Motivo.VALIDO)
	if candidatos.is_empty():
		return null
	candidatos.sort_custom(func(a: Combatiente, b: Combatiente) -> bool: return _mas_prioritario(actor, a, b))
	return candidatos[0]


## Casilla de Zancada: la más barata desde la que pueda golpear; si no hay, la más cercana a un oponente.
static func _mejor_destino(combate: Combate, actor: Combatiente, arma: DefinicionArma) -> Variant:
	var oponentes: Array[Combatiente] = _oponentes(combate, actor)
	if oponentes.is_empty():
		return null
	var casillas: Dictionary[Vector2i, int] = combate.casillas_de_zancada(actor)
	var mejor: Variant = null
	var mejor_costo: int = 0
	var celda_original: Vector2i = actor.celda
	for casilla: Vector2i in casillas:
		actor.celda = casilla
		var puede: bool = oponentes.any(func(o: Combatiente) -> bool:
			return Golpe.validar(actor, o, arma, combate.vision()) == Golpe.Motivo.VALIDO)
		if puede and (mejor == null or casillas[casilla] < mejor_costo or (casillas[casilla] == mejor_costo and _antes(casilla, mejor))):
			mejor = casilla
			mejor_costo = casillas[casilla]
	actor.celda = celda_original
	if mejor != null:
		return mejor
	var distancia_actual: int = _distancia_al_mas_cercano(celda_original, oponentes)
	var mejor_distancia: int = distancia_actual
	for casilla: Vector2i in casillas:
		var distancia: int = _distancia_al_mas_cercano(casilla, oponentes)
		if distancia < mejor_distancia or (distancia == mejor_distancia and mejor != null and _antes(casilla, mejor)):
			mejor = casilla
			mejor_distancia = distancia
	return mejor if mejor_distancia < distancia_actual else null


static func _alejarse_si_esta_pegado(combate: Combate, actor: Combatiente) -> Array[EventoCombate]:
	var oponentes: Array[Combatiente] = _oponentes(combate, actor)
	if not oponentes.any(func(o: Combatiente) -> bool: return Medicion.en_alcance(actor.celda, o.celda, Medicion.PIES_POR_CASILLA)):
		return []
	for dx: int in [-1, 0, 1]:
		for dy: int in [-1, 0, 1]:
			var casilla: Vector2i = actor.celda + Vector2i(dx, dy)
			if casilla == actor.celda:
				continue
			var pegada: bool = oponentes.any(func(o: Combatiente) -> bool: return o.celda == casilla or Medicion.en_alcance(casilla, o.celda, Medicion.PIES_POR_CASILLA))
			if not pegada:
				var eventos: Array[EventoCombate] = combate.paso(casilla)
				if eventos.back().tipo == EventoCombate.Tipo.MOVIMIENTO:
					return eventos
	return []


static func _mas_prioritario(actor: Combatiente, a: Combatiente, b: Combatiente) -> bool:
	var da: int = Medicion.pies_entre(actor.celda, a.celda)
	var db: int = Medicion.pies_entre(actor.celda, b.celda)
	if da != db:
		return da < db
	if a.pg != b.pg:
		return a.pg < b.pg
	return String(a.id) < String(b.id)


static func _distancia_al_mas_cercano(casilla: Vector2i, oponentes: Array[Combatiente]) -> int:
	var minima: int = 1 << 30
	for o: Combatiente in oponentes:
		minima = mini(minima, Medicion.pies_entre(casilla, o.celda))
	return minima


## Desempate determinista entre casillas.
static func _antes(a: Vector2i, b: Vector2i) -> bool:
	return a.y < b.y or (a.y == b.y and a.x < b.x)

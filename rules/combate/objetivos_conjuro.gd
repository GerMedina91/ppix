class_name ObjetivosConjuro
extends RefCounted
## Quién o qué puede elegir un conjuro (Player Core p. 300 y 426; c4_conjuros.md y c5_curar.md). Sin estado.
## - Recursos: truco, espacio sin usar o punto de foco; en costo variable, una forma válida.
## - Una criatura: viva (no muerta), dentro del alcance o del toque (alcance sin armas: adyacente) y con
##   línea de visión. No uno mismo, salvo la curación.
## - Moribunda (Estabilizar): además, con moribundo.
## - Curación a una criatura: un ser vivo que acepte (aliado o uno mismo; los enemigos no aceptan) o un
##   muerto viviente de cualquier bando.
## - Emanación: sin objetivo único; afecta a todos los que están dentro con línea de efecto al lanzador
##   (el lanzador elige incluirse: se incluye).
## - Sobre uno mismo con movimiento incluido: el movimiento se valida con el bonificador del conjuro puesto.

const ALCANCE_TOQUE_PIES: int = 5


static func motivo(combate: Combate, lanzador: Combatiente, pedido: PedidoConjuro, objetivo: Combatiente) -> String:
	var conjuro: DefinicionConjuro = pedido.conjuro
	if not lanzador.conjuros.conocidos().has(conjuro):
		return "no conoce ese conjuro"
	if not lanzador.conjuros.puede_lanzar(conjuro):
		return "sin puntos de foco" if conjuro.tipo == DefinicionConjuro.Tipo.FOCO else "sin espacios"
	if pedido.costo() == 0:
		return "elegí cuántas acciones"
	if conjuro.objetivo == DefinicionConjuro.Objetivo.UNO_MISMO:
		return _motivo_movimiento(combate, lanzador, pedido)
	if pedido.es_area():
		return ""
	if objetivo == null or objetivo.condiciones.muerto or (objetivo == lanzador and not conjuro.cura()):
		return "sin objetivo"
	if conjuro.objetivo == DefinicionConjuro.Objetivo.UNA_CRIATURA_MORIBUNDA and objetivo.condiciones.moribundo <= 0:
		return "el objetivo no está moribundo"
	if conjuro.cura() and not objetivo.es_aliado_de(lanzador) and not objetivo.fuente.es_muerto_viviente():
		return "solo aliados o muertos vivientes"
	if not _al_alcance(lanzador, pedido, objetivo):
		return "fuera de alcance"
	if not combate.vision().hay_linea(lanzador.celda, objetivo.celda):
		return "sin línea de visión"
	return ""


## Criaturas que puede elegir con `conjuro` (y esas acciones, si es de costo variable).
static func validos(combate: Combate, lanzador: Combatiente, conjuro: DefinicionConjuro, acciones: int = 0) -> Array[Combatiente]:
	var lista: Array[Combatiente] = []
	for c: Combatiente in combate.participantes:
		if motivo(combate, lanzador, PedidoConjuro.new(conjuro, c.id, acciones), c) == "":
			lista.append(c)
	return lista


## Criaturas dentro de la emanación del pedido, con línea de efecto al lanzador (incluido él).
static func afectados_por_area(combate: Combate, lanzador: Combatiente, pedido: PedidoConjuro) -> Array[Combatiente]:
	var lista: Array[Combatiente] = []
	var radio: int = pedido.variante().emanacion_pies
	for c: Combatiente in combate.participantes:
		if c.condiciones.muerto or Medicion.pies_entre(lanzador.celda, c.celda) > radio:
			continue
		if c == lanzador or combate.vision().hay_linea(lanzador.celda, c.celda):
			lista.append(c)
	return lista


## Casillas dentro de la emanación (para dibujarla).
static func casillas_de_area(combate: Combate, lanzador: Combatiente, radio_pies: int) -> Array[Vector2i]:
	var casillas: Array[Vector2i] = []
	var radio: int = radio_pies / Medicion.PIES_POR_CASILLA
	for dx in range(-radio, radio + 1):
		for dy in range(-radio, radio + 1):
			var celda: Vector2i = lanzador.celda + Vector2i(dx, dy)
			if combate.grilla().es_transitable(celda) and Medicion.pies_entre(lanzador.celda, celda) <= radio_pies \
					and combate.vision().hay_linea(lanzador.celda, celda):
				casillas.append(celda)
	return casillas


static func _al_alcance(lanzador: Combatiente, pedido: PedidoConjuro, objetivo: Combatiente) -> bool:
	var variante: VarianteConjuro = pedido.variante()
	if variante != null and variante.toque:
		return objetivo == lanzador or Medicion.en_alcance(lanzador.celda, objetivo.celda, ALCANCE_TOQUE_PIES)
	var alcance: int = variante.alcance_pies if variante != null else pedido.conjuro.alcance_pies
	return Medicion.pies_entre(lanzador.celda, objetivo.celda) <= alcance


static func _motivo_movimiento(combate: Combate, lanzador: Combatiente, pedido: PedidoConjuro) -> String:
	if pedido.destino == PedidoConjuro.SIN_CELDA:
		return ""
	if not pedido.conjuro.permite_moverse:
		return "no permite moverse"
	var anterior: int = lanzador.bonificador_velocidad
	lanzador.bonificador_velocidad = maxi(anterior, pedido.conjuro.bonificador_velocidad)
	var movimiento: AccionesMovimiento = combate.movimiento
	var texto: String = movimiento.motivo_paso_imposible(lanzador, pedido.destino) if pedido.es_paso \
		else movimiento.motivo_zancada_imposible(lanzador, pedido.destino, pedido.recorrido)
	lanzador.bonificador_velocidad = anterior
	return texto

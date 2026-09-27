class_name ModoAccion
extends RefCounted
## Acciones del jugador además de moverse y golpear (placeholder hasta la barra del HUD de C6): lista
## numerada con los conjuros que puede lanzar ahora, las acciones con objetivo (AccionesConObjetivo: Golpe
## no letal, Carga repentina, Medicina en batalla, Recordar conocimiento), Sostener y Arcadas. Teclas 1-9 eligen; Esc o
## click derecho cancelan. Con un conjuro elegido, el click va al objetivo; Pies ágiles: click en el
## propio personaje (sin moverse), en una casilla de su Zancada, o Shift + click para el Paso.
## Costo variable (Curar): después de elegirlo, 1-3 eligen cuántas acciones; la emanación se confirma
## con click en la propia casilla.
## Solo arma intenciones: el Combate valida y resuelve.

enum Tipo { CONJURO, ACCION, SOSTENER, ARCADAS }

const _PIP: String = "◆"

## Conjuro elegido esperando objetivo (null si no hay ninguno).
var elegido: DefinicionConjuro
## Acción con objetivo elegida (id de AccionesConObjetivo; vacío si no hay ninguna).
var accion: StringName = &""
## Acciones elegidas para un conjuro de costo variable (0 = todavía no).
var acciones: int = 0
## Emanación: el lanzador no se incluye (se alterna con `alternar_incluirse`).
var excluirse: bool = false
## Pies ágiles: casillas de su Zancada con el bonificador ya puesto.
var casillas_movimiento: Dictionary[Vector2i, int] = {}


## Opciones del actor en turno: [{"tipo", "texto", "conjuro"}], en el orden de las teclas.
static func opciones(combate: Combate, actor: Combatiente) -> Array[Dictionary]:
	var lista: Array[Dictionary] = []
	for conjuro: DefinicionConjuro in actor.conjuros.conocidos():
		if actor.conjuros.puede_lanzar(conjuro) and not combate.conjuros.falla_por_maleficio(actor, conjuro) \
				and actor.acciones_restantes >= conjuro.acciones_posibles().min():
			lista.append({"tipo": Tipo.CONJURO, "conjuro": conjuro, "texto": _texto_conjuro(actor, conjuro),
				"motivo": SinObjetivos.de_conjuro(combate, actor, conjuro)})
	for id: StringName in AccionesConObjetivo.disponibles(actor):
		lista.append({"tipo": Tipo.ACCION, "accion": id, "texto": AccionesConObjetivo.texto(id),
			"motivo": SinObjetivos.de_accion(combate, actor, id)})
	if not combate.conjuros.por_sostener(actor).is_empty() and actor.acciones_restantes >= AccionesConjuro.COSTO_SOSTENER:
		var sostenido: EfectoSostenido = combate.conjuros.por_sostener(actor)[0]
		lista.append({"tipo": Tipo.SOSTENER, "texto": "Sostener %s ◆" % sostenido.conjuro.nombre})
	if actor.condiciones.tiene(Condiciones.Tipo.INDISPUESTO) and actor.acciones_restantes >= Combate.COSTO_ARCADAS:
		lista.append({"tipo": Tipo.ARCADAS, "texto": "Arcadas ◆"})
	return lista


static func _texto_conjuro(actor: Combatiente, conjuro: DefinicionConjuro) -> String:
	var posibles: Array[int] = conjuro.acciones_posibles()
	var costo: String = _PIP.repeat(posibles.min())
	if posibles.size() > 1:
		costo = "%s–%s" % [_PIP.repeat(posibles.min()), _PIP.repeat(posibles.max())]
	var texto: String = "%s %s" % [conjuro.nombre, costo]
	var restantes: int = actor.conjuros.restantes(conjuro)
	return texto if restantes < 0 else "%s (%d)" % [texto, restantes]


## Texto de la lista para el HUD ("1 Mal de ojo ◆ · 2 Debilitar ◆◆ (1)"), o la instrucción del elegido.
func texto(combate: Combate, actor: Combatiente) -> String:
	if accion != &"":
		return "%s: click en el objetivo · Esc cancela" % AccionesConObjetivo.NOMBRES[accion]
	if elegido != null:
		if pide_acciones():
			return "%s: %s · Esc cancela" % [elegido.nombre, " · ".join(_formas(actor))]
		if es_area():
			return "%s %s: click en tu casilla para lanzarlo · E: %s · Esc cancela" % [elegido.nombre,
				_PIP.repeat(acciones), "no te incluye" if excluirse else "te incluye"]
		if elegido.objetivo == DefinicionConjuro.Objetivo.UNO_MISMO:
			return "%s: click en tu casilla o donde moverte (Shift: Paso) · Esc cancela" % elegido.nombre
		return "%s: click en el objetivo · Esc cancela" % elegido.nombre
	var partes: PackedStringArray = PackedStringArray()
	var lista: Array[Dictionary] = opciones(combate, actor)
	for i in lista.size():
		partes.append("%d %s" % [i + 1, lista[i].texto])
	return " · ".join(partes)


## Formas del conjuro elegido que le alcanzan con sus acciones: [{"acciones", "texto"}] (selector de costo).
func formas(actor: Combatiente) -> Array[Dictionary]:
	var lista: Array[Dictionary] = []
	if not pide_acciones():
		return lista
	for texto_forma: String in _formas(actor):
		lista.append({"acciones": int(texto_forma.get_slice(" ", 0)), "texto": texto_forma})
	return lista


## "1 ◆ toque", "2 ◆◆ 30 pies (+8)", "3 ◆◆◆ emanación de 30 pies" (las que le alcanzan).
func _formas(actor: Combatiente) -> PackedStringArray:
	var partes: PackedStringArray = PackedStringArray()
	for v: VarianteConjuro in elegido.variantes:
		if v.acciones > actor.acciones_restantes:
			continue
		var detalle: String = "%d pies" % v.alcance_pies
		if v.toque:
			detalle = "toque"
		elif v.es_area():
			detalle = "emanación de %d pies" % v.emanacion_pies
		if v.curacion_extra > 0:
			detalle += " (+%d)" % v.curacion_extra
		partes.append("%d %s %s" % [v.acciones, _PIP.repeat(v.acciones), detalle])
	return partes


## true si hay un conjuro o una acción con objetivo elegidos (el click va a eso).
func hay_eleccion() -> bool:
	return elegido != null or accion != &""


## true si el conjuro elegido es de costo variable y todavía falta elegir las acciones.
func pide_acciones() -> bool:
	return elegido != null and elegido.es_variable() and acciones == 0


func es_area() -> bool:
	return elegido != null and elegido.variante(acciones) != null and elegido.variante(acciones).es_area()


## Elige la opción `indice` (desde 0). Sostener y Arcadas no piden objetivo: devuelve su intención ya
## lista para ejecutar. Con un conjuro, queda elegido y devuelve un Callable vacío. Si falta elegir las
## acciones de un conjuro de costo variable, `indice` + 1 son las acciones.
func elegir(combate: Combate, actor: Combatiente, indice: int) -> Callable:
	if pide_acciones():
		var forma: VarianteConjuro = elegido.variante(indice + 1)
		if forma != null and forma.acciones <= actor.acciones_restantes:
			acciones = forma.acciones
		return Callable()
	var lista: Array[Dictionary] = opciones(combate, actor)
	if indice < 0 or indice >= lista.size() or lista[indice].get("motivo", "") != "":
		return Callable()  # sin objetivos válidos: la barra la muestra deshabilitada
	match lista[indice].tipo:
		Tipo.SOSTENER:
			return combate.sostener
		Tipo.ARCADAS:
			return combate.arcadas
		Tipo.ACCION:
			accion = lista[indice].accion
			return Callable()
	elegido = lista[indice].conjuro
	acciones = 0
	casillas_movimiento.clear()
	if elegido.permite_moverse:
		var anterior: int = actor.bonificador_velocidad
		actor.bonificador_velocidad = maxi(anterior, elegido.bonificador_velocidad)
		casillas_movimiento = combate.casillas_de_zancada(actor)
		actor.bonificador_velocidad = anterior
	return Callable()


func cancelar() -> void:
	elegido = null
	accion = &""
	acciones = 0
	excluirse = false
	casillas_movimiento.clear()


## Criaturas que puede elegir con el conjuro elegido (aliados incluidos, como permiten las reglas); con una
## emanación, las que quedan dentro. Sobre uno mismo: solo el actor.
func objetivos(combate: Combate, actor: Combatiente) -> Array[Combatiente]:
	var lista: Array[Combatiente] = []
	if accion != &"":
		return AccionesConObjetivo.objetivos(combate, actor, accion)
	if elegido == null or pide_acciones():
		return lista
	if es_area():
		return ObjetivosConjuro.afectados_por_area(combate, actor, _pedido(&""))
	if elegido.objetivo == DefinicionConjuro.Objetivo.UNO_MISMO:
		lista.append(actor)
		return lista
	return combate.conjuros.objetivos_validos(actor, elegido, acciones)


## Pedido del conjuro elegido con las acciones y la opción de excluirse.
func _pedido(objetivo: StringName) -> PedidoConjuro:
	var pedido: PedidoConjuro = PedidoConjuro.new(elegido, objetivo, acciones)
	pedido.excluir_lanzador = excluirse
	return pedido


## Casillas de la emanación elegida (vacío si no es de área).
func casillas_area(combate: Combate, actor: Combatiente) -> Array[Vector2i]:
	var casillas: Array[Vector2i] = []
	if es_area():
		casillas = ObjetivosConjuro.casillas_de_area(combate, actor, elegido.variante(acciones).emanacion_pies)
	return casillas


## Intención del click en `celda` con el conjuro elegido (el Combate avisa si es imposible). Callable vacío
## si todavía falta elegir las acciones.
func al_click(combate: Combate, actor: Combatiente, celda: Vector2i, es_paso: bool) -> Callable:
	if pide_acciones():
		return Callable()
	if accion != &"":
		var id: StringName = accion
		cancelar()
		return AccionesConObjetivo.intencion(combate, id, _vivo_en(combate, celda))
	var conjuro: DefinicionConjuro = elegido
	var cantidad: int = acciones
	var area: bool = es_area()
	var pedido_area: PedidoConjuro = _pedido(&"")
	cancelar()
	var recorrido: Array[Vector2i] = []
	if area:
		return combate.lanzar_pedido.bind(pedido_area)
	if conjuro.objetivo == DefinicionConjuro.Objetivo.UNO_MISMO:
		if celda == actor.celda:
			return combate.lanzar_conjuro.bind(conjuro)
		return combate.lanzar_conjuro.bind(conjuro, &"", celda, recorrido, es_paso)
	var objetivo: StringName = &""
	for c: Combatiente in combate.participantes:
		if c.celda == celda and not c.condiciones.muerto:
			objetivo = c.id
	return combate.lanzar_conjuro.bind(conjuro, objetivo, AccionesConjuro.SIN_CELDA, recorrido, false, cantidad)


static func _vivo_en(combate: Combate, celda: Vector2i) -> StringName:
	for c: Combatiente in combate.participantes:
		if c.celda == celda and not c.condiciones.muerto:
			return c.id
	return &""

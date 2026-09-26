class_name ModoAccion
extends RefCounted
## Acciones del jugador además de moverse y golpear (placeholder hasta la barra del HUD de C6): lista
## numerada con los conjuros que puede lanzar ahora, Sostener y Arcadas. Teclas 1-9 eligen; Esc o
## click derecho cancelan. Con un conjuro elegido, el click va al objetivo; Pies ágiles: click en el
## propio personaje (sin moverse), en una casilla de su Zancada, o Shift + click para el Paso.
## Solo arma intenciones: el Combate valida y resuelve.

enum Tipo { CONJURO, SOSTENER, ARCADAS }

## Conjuro elegido esperando objetivo (null si no hay ninguno).
var elegido: DefinicionConjuro
## Pies ágiles: casillas de su Zancada con el bonificador ya puesto.
var casillas_movimiento: Dictionary[Vector2i, int] = {}


## Opciones del actor en turno: [{"tipo", "texto", "conjuro"}], en el orden de las teclas.
static func opciones(combate: Combate, actor: Combatiente) -> Array[Dictionary]:
	var lista: Array[Dictionary] = []
	for conjuro: DefinicionConjuro in actor.conjuros.conocidos():
		if actor.conjuros.puede_lanzar(conjuro) and not combate.conjuros.falla_por_maleficio(actor, conjuro) \
				and actor.acciones_restantes >= conjuro.acciones:
			lista.append({"tipo": Tipo.CONJURO, "conjuro": conjuro, "texto": _texto_conjuro(actor, conjuro)})
	if not combate.conjuros.por_sostener(actor).is_empty() and actor.acciones_restantes >= AccionesConjuro.COSTO_SOSTENER:
		var sostenido: EfectoSostenido = combate.conjuros.por_sostener(actor)[0]
		lista.append({"tipo": Tipo.SOSTENER, "texto": "Sostener %s ◆" % sostenido.conjuro.nombre})
	if actor.condiciones.tiene(Condiciones.Tipo.INDISPUESTO) and actor.acciones_restantes >= Combate.COSTO_ARCADAS:
		lista.append({"tipo": Tipo.ARCADAS, "texto": "Arcadas ◆"})
	return lista


static func _texto_conjuro(actor: Combatiente, conjuro: DefinicionConjuro) -> String:
	var texto: String = "%s %s" % [conjuro.nombre, "◆".repeat(conjuro.acciones)]
	var restantes: int = actor.conjuros.restantes(conjuro)
	return texto if restantes < 0 else "%s (%d)" % [texto, restantes]


## Texto de la lista para el HUD ("1 Mal de ojo ◆ · 2 Debilitar ◆◆ (1)"), o la instrucción del elegido.
func texto(combate: Combate, actor: Combatiente) -> String:
	if elegido != null:
		if elegido.objetivo == DefinicionConjuro.Objetivo.UNO_MISMO:
			return "%s: click en tu casilla o donde moverte (Shift: Paso) · Esc cancela" % elegido.nombre
		return "%s: click en el objetivo · Esc cancela" % elegido.nombre
	var partes: PackedStringArray = PackedStringArray()
	var lista: Array[Dictionary] = opciones(combate, actor)
	for i in lista.size():
		partes.append("%d %s" % [i + 1, lista[i].texto])
	return " · ".join(partes)


## Elige la opción `indice` (desde 0). Sostener y Arcadas no piden objetivo: devuelve su intención ya
## lista para ejecutar. Con un conjuro, queda elegido y devuelve un Callable vacío.
func elegir(combate: Combate, actor: Combatiente, indice: int) -> Callable:
	var lista: Array[Dictionary] = opciones(combate, actor)
	if indice < 0 or indice >= lista.size():
		return Callable()
	match lista[indice].tipo:
		Tipo.SOSTENER:
			return combate.sostener
		Tipo.ARCADAS:
			return combate.arcadas
	elegido = lista[indice].conjuro
	casillas_movimiento.clear()
	if elegido.permite_moverse:
		var anterior: int = actor.bonificador_velocidad
		actor.bonificador_velocidad = maxi(anterior, elegido.bonificador_velocidad)
		casillas_movimiento = combate.casillas_de_zancada(actor)
		actor.bonificador_velocidad = anterior
	return Callable()


func cancelar() -> void:
	elegido = null
	casillas_movimiento.clear()


## Criaturas que puede elegir con el conjuro elegido (aliados incluidos, como permiten las reglas).
## Sobre uno mismo: solo el actor (el movimiento posible está en casillas_movimiento).
func objetivos(combate: Combate, actor: Combatiente) -> Array[Combatiente]:
	var lista: Array[Combatiente] = []
	if elegido == null:
		return lista
	if elegido.objetivo == DefinicionConjuro.Objetivo.UNO_MISMO:
		lista.append(actor)
		return lista
	return combate.conjuros.objetivos_validos(actor, elegido)


## Intención del click en `celda` con el conjuro elegido (el Combate avisa si es imposible).
func al_click(combate: Combate, actor: Combatiente, celda: Vector2i, es_paso: bool) -> Callable:
	var conjuro: DefinicionConjuro = elegido
	cancelar()
	if conjuro.objetivo == DefinicionConjuro.Objetivo.UNO_MISMO:
		if celda == actor.celda:
			return combate.lanzar_conjuro.bind(conjuro)
		var recorrido: Array[Vector2i] = []
		return combate.lanzar_conjuro.bind(conjuro, &"", celda, recorrido, es_paso)
	var objetivo: StringName = &""
	for c: Combatiente in combate.participantes:
		if c.celda == celda and not c.condiciones.muerto:
			objetivo = c.id
	return combate.lanzar_conjuro.bind(conjuro, objetivo)

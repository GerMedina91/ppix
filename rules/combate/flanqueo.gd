class_name Flanqueo
extends RefCounted
## Flanqueo de PF2e: un atacante flanquea a un objetivo si él y un aliado pueden actuar, tienen al
## objetivo al alcance de un arma cuerpo a cuerpo, y la recta entre los centros de sus casillas
## cruza lados opuestos (o esquinas opuestas) de la casilla del objetivo.
## El flanqueado queda desprevenido SOLO frente a las criaturas que lo flanquean.

const _EPSILON: float = 0.0001


## true si `atacante` flanquea a `objetivo` junto con algún aliado de `participantes`.
static func atacante_flanquea(atacante: Combatiente, objetivo: Combatiente, participantes: Array[Combatiente]) -> bool:
	if not puede_flanquear(atacante, objetivo):
		return false
	for aliado: Combatiente in participantes:
		if aliado == atacante or aliado == objetivo or not aliado.es_aliado_de(atacante):
			continue
		if puede_flanquear(aliado, objetivo) and lados_opuestos(atacante.celda, aliado.celda, objetivo.celda):
			return true
	return false


## Puede actuar y tiene al objetivo al alcance de un arma cuerpo a cuerpo.
static func puede_flanquear(combatiente: Combatiente, objetivo: Combatiente) -> bool:
	if not combatiente.condiciones.puede_actuar() or combatiente.es_aliado_de(objetivo):
		return false
	for arma: DefinicionArma in combatiente.fuente.armas():
		if not arma.a_distancia and Medicion.en_alcance(combatiente.celda, objetivo.celda, arma.alcance_pies):
			return true
	return false


## true si la recta entre los centros de `a` y `b` entra y sale de la casilla `objetivo` por lados
## opuestos (izquierda/derecha o arriba/abajo); una esquina cuenta como sus dos lados.
static func lados_opuestos(a: Vector2i, b: Vector2i, objetivo: Vector2i) -> bool:
	var p0: Vector2 = Vector2(a - objetivo)
	var d: Vector2 = Vector2(b - a)
	# Recorte de Liang-Barsky contra el cuadrado [-0.5, 0.5]².
	var t_entrada: float = 0.0
	var t_salida: float = 1.0
	for eje: int in [0, 1]:
		if absf(d[eje]) < _EPSILON:
			if absf(p0[eje]) > 0.5:
				return false
			continue
		var t1: float = (-0.5 - p0[eje]) / d[eje]
		var t2: float = (0.5 - p0[eje]) / d[eje]
		t_entrada = maxf(t_entrada, minf(t1, t2))
		t_salida = minf(t_salida, maxf(t1, t2))
	if t_salida - t_entrada < _EPSILON:
		return false
	var lados_entrada: Array[String] = _lados(p0 + d * t_entrada)
	var lados_salida: Array[String] = _lados(p0 + d * t_salida)
	return (lados_entrada.has("izq") and lados_salida.has("der")) or (lados_entrada.has("der") and lados_salida.has("izq")) \
		or (lados_entrada.has("arr") and lados_salida.has("aba")) or (lados_entrada.has("aba") and lados_salida.has("arr"))


static func _lados(punto: Vector2) -> Array[String]:
	var lados: Array[String] = []
	if absf(punto.x + 0.5) < _EPSILON: lados.append("izq")
	if absf(punto.x - 0.5) < _EPSILON: lados.append("der")
	if absf(punto.y + 0.5) < _EPSILON: lados.append("arr")
	if absf(punto.y - 0.5) < _EPSILON: lados.append("aba")
	return lados

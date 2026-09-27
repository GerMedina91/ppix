class_name FormatoRegistro
extends RefCounted
## Texto del registro de combate a partir de los eventos (términos según docs/GLOSARIO.md).
## Devuelve "" para los eventos que no se muestran en el registro. Los combatientes se muestran por su nombre
## (Irsa, el Eco...); la línea empieza con mayúscula.


static func texto(evento: EventoCombate, combate: Combate) -> String:
	return capitalizar(_texto(evento, combate))


## Al empezar una línea, el artículo de un nombre va en mayúscula: "el Eco cae" -> "El Eco cae".
static func capitalizar(linea: String) -> String:
	return "E" + linea.substr(1) if linea.begins_with("el ") else linea


## Nombre del combatiente `id` (el id si no está en el combate).
static func nombre(combate: Combate, id: Variant) -> String:
	var c: Combatiente = combate.combatiente(StringName(id)) if combate != null else null
	return c.nombre_visible if c != null else String(id)


## "de" + nombre, con la contracción: "de Irsa", "del Eco".
static func _de(quien: String) -> String:
	return "del %s" % quien.substr(3) if quien.begins_with("el ") else "de %s" % quien


static func _texto(evento: EventoCombate, combate: Combate) -> String:
	var actor: String = nombre(combate, evento.actor)
	match evento.tipo:
		EventoCombate.Tipo.INICIATIVA:
			return "%s: iniciativa %d" % [actor, evento.datos.total]
		EventoCombate.Tipo.INICIO_RONDA:
			return "— Ronda %d —" % evento.datos.ronda
		EventoCombate.Tipo.MOVIMIENTO:
			var pies: int = MovimientoCombate.costo_de(evento.datos.desde, evento.datos.camino)
			var accion: String = "Paso" if evento.datos.tipo == "paso" else "Zancada"
			if evento.datos.get("continua", false):
				return "%s: sigue la %s (%d pies)" % [actor, accion, pies]
			return "%s: %s (%d pies)" % [actor, accion, pies]
		EventoCombate.Tipo.REACCION_PENDIENTE:
			return "%s puede usar %s contra %s" % [actor, evento.datos.reaccion, nombre(combate, evento.datos.disparador)]
		EventoCombate.Tipo.REACCION:
			return "%s usa %s (reacción)" % [actor, evento.datos.reaccion]
		EventoCombate.Tipo.GOLPE:
			return _golpe(actor, nombre(combate, evento.datos.objetivo), evento.datos.resultado)
		EventoCombate.Tipo.CAIDO:
			if evento.datos.moribundo == 0:
				return "%s queda inconsciente" % actor
			return "%s cae (moribundo %d)" % [actor, evento.datos.moribundo]
		EventoCombate.Tipo.MUERTE:
			return "%s muere" % actor
		EventoCombate.Tipo.RECUPERACION:
			var r: ResultadoPrueba = evento.datos.resultado
			return "%s: prueba de recuperación %d contra CD %d: %s (moribundo %d)" % [
				actor, r.total, r.cd, GradoExito.nombre(r.grado), evento.datos.moribundo]
		EventoCombate.Tipo.TURNO_PERDIDO:
			return "%s pierde el turno" % actor
		EventoCombate.Tipo.FIN_COMBATE:
			return "Victoria" if evento.datos.estado == Combate.Estado.VICTORIA else "Derrota"
		EventoCombate.Tipo.ACCION_INVALIDA:
			return "%s: %s imposible (%s)" % [actor, evento.datos.get("accion", "acción"), evento.datos.motivo]
		EventoCombate.Tipo.CONDICION:
			if evento.datos.valor == 0:
				return "%s ya no está %s" % [actor, Condiciones.nombre(evento.datos.condicion)]
			return "%s: %s" % [actor, condicion(evento.datos.condicion, evento.datos.valor)]
		EventoCombate.Tipo.ACCIONES_PERDIDAS:
			return "%s pierde %d %s por %s" % [actor, evento.datos.cantidad,
				"acción" if evento.datos.cantidad == 1 else "acciones", Condiciones.nombre(evento.datos.condicion)]
		EventoCombate.Tipo.LANZAMIENTO:
			var conjuro: DefinicionConjuro = evento.datos.conjuro
			var nombre_conjuro: String = conjuro.nombre
			if conjuro.es_variable():
				nombre_conjuro = "%s (%s)" % [nombre_conjuro, "◆".repeat(evento.datos.get("acciones", 0))]
			if evento.datos.objetivo == evento.actor:
				return "%s lanza %s" % [actor, nombre_conjuro]
			return "%s lanza %s sobre %s" % [actor, nombre_conjuro, nombre(combate, evento.datos.objetivo)]
		EventoCombate.Tipo.EFECTO_CONJURO:
			return _efecto_conjuro(evento, combate)
		EventoCombate.Tipo.CONJURO_FALLIDO:
			return "%s %s no tiene efecto (%s)" % [(evento.datos.conjuro as DefinicionConjuro).nombre, _de(actor), evento.datos.motivo]
		EventoCombate.Tipo.SOSTENER:
			return "%s sostiene %s" % [actor, (evento.datos.conjuro as DefinicionConjuro).nombre]
		EventoCombate.Tipo.FIN_CONJURO:
			return "Termina %s %s" % [(evento.datos.conjuro as DefinicionConjuro).nombre, _de(actor)]
		EventoCombate.Tipo.RESULTADO_ESPECIAL:
			return _resultado_especial(evento, combate)
		EventoCombate.Tipo.ACCION_ESPECIAL:
			return "%s usa %s sobre %s" % [actor, evento.datos.accion, nombre(combate, evento.datos.objetivo)]
		EventoCombate.Tipo.ARCADAS:
			var a: ResultadoPrueba = evento.datos.resultado
			return "%s: Arcadas, Fortaleza %d contra CD %d: %s (indispuesto %d)" % [
				actor, a.total, a.cd, GradoExito.nombre(a.grado), evento.datos.valor]
	return ""


const _NOMBRE_DANIO: Dictionary[DefinicionArma.TipoDanio, String] = {
	DefinicionArma.TipoDanio.CORTANTE: "cortante", DefinicionArma.TipoDanio.PERFORANTE: "perforante",
	DefinicionArma.TipoDanio.CONTUNDENTE: "contundente", DefinicionArma.TipoDanio.ESPIRITU: "de espíritu",
	DefinicionArma.TipoDanio.MENTAL: "mental", DefinicionArma.TipoDanio.VITALIDAD: "de vitalidad",
}


## Ataque: "pj → e (Lanza divina): 14 (+4 Sabiduría, ...) = 21 contra CA 16: éxito, 5 de daño de espíritu".
## Salvación: "e: Voluntad 12 contra CD 17: fallo, 3 de daño mental". Estabilizar: "e se estabiliza".
## Sobre uno mismo: el bonificador que da.
static func _efecto_conjuro(evento: EventoCombate, combate: Combate) -> String:
	var actor: String = nombre(combate, evento.actor)
	var objetivo: String = nombre(combate, evento.datos.get("objetivo", ""))
	var conjuro: DefinicionConjuro = evento.datos.conjuro
	var r: ResultadoPrueba = evento.datos.resultado
	var texto: String = ""
	if conjuro.estabiliza:
		return "%s se estabiliza" % objetivo
	if evento.datos.get("curacion", 0) > 0:
		var levanta: String = " y se levanta" if evento.datos.get("levanta", false) else ""
		return "%s recupera %d PG%s" % [objetivo, evento.datos.curacion, levanta]
	if r != null and conjuro.es_ataque():
		texto = "%s → %s (%s): %s = %d contra CA %d: %s" % [actor, objetivo, conjuro.nombre,
			_tirada_con_desglose(r), r.total, r.cd, GradoExito.nombre(r.grado)]
	elif r != null:
		texto = "%s: %s %d contra CD %d: %s" % [objetivo, Estadisticas.nombre_salvacion(evento.datos.salvacion),
			r.total, r.cd, GradoExito.nombre(r.grado)]
	elif conjuro.bonificador_velocidad > 0:
		return "%s: +%d pies de Velocidad hasta el final del turno" % [actor, conjuro.bonificador_velocidad]
	if evento.datos.get("danio", 0) > 0:
		texto += ", %d de daño %s" % [evento.datos.danio, _NOMBRE_DANIO[conjuro.tipo_danio]]
	return texto


static func _tirada_con_desglose(r: ResultadoPrueba) -> String:
	var partes: PackedStringArray = PackedStringArray()
	for parte: Dictionary in r.desglose:
		partes.append("%+d %s" % [parte.valor, parte.fuente])
	return "%d (%s)" % [r.natural, ", ".join(partes)]


## "g: Medicina 17 contra CD 15: éxito, p recupera 9 PG"; Recordar conocimiento (secreto): sin la tirada.
static func _resultado_especial(evento: EventoCombate, combate: Combate) -> String:
	var actor: String = nombre(combate, evento.actor)
	var objetivo: String = nombre(combate, evento.datos.get("objetivo", ""))
	if evento.datos.get("secreto", false):
		if evento.datos.recordo:
			return "%s recuerda algo sobre %s (%s)" % [actor, objetivo, Habilidad.nombre(evento.datos.habilidad)]
		return "%s no recuerda nada sobre %s" % [actor, objetivo]
	var r: ResultadoPrueba = evento.datos.resultado
	var texto: String = "%s: %s %d contra CD %d: %s" % [actor, evento.datos.accion, r.total, r.cd, GradoExito.nombre(r.grado)]
	if evento.datos.curacion > 0:
		texto += ", %s recupera %d PG" % [objetivo, evento.datos.curacion]
	elif evento.datos.danio > 0:
		texto += ", %s recibe %d de daño" % [objetivo, evento.datos.danio]
	return texto


## Texto del aviso de reacción: "El Eco: ¿usar Golpe reactivo contra X?".
static func pregunta_reaccion(pregunta: Dictionary) -> String:
	return capitalizar("%s: ¿usar %s contra %s?" % [pregunta.reactor.nombre_visible, (pregunta.capacidad as Capacidad).nombre, pregunta.disparo.actor.nombre_visible])


## Condiciones de un combatiente: "moribundo 1, herido 1, asustado 2" ("" si no tiene ninguna).
static func condiciones_de(c: Combatiente) -> String:
	var partes: PackedStringArray = PackedStringArray()
	if c.condiciones.moribundo > 0:
		partes.append("moribundo %d" % c.condiciones.moribundo)
	if c.condiciones.herido > 0:
		partes.append("herido %d" % c.condiciones.herido)
	if c.condiciones.inconsciente:
		partes.append("inconsciente")
	var valores: Dictionary[Condiciones.Tipo, int] = c.condiciones.valores()
	for tipo: Condiciones.Tipo in valores:
		if valores[tipo] > 0:
			partes.append(condicion(tipo, valores[tipo]))
	return ", ".join(partes)


## "asustado 2"; las condiciones sin valor (huyendo), solo el nombre.
static func condicion(tipo: Condiciones.Tipo, valor: int) -> String:
	if tipo == Condiciones.Tipo.HUYENDO:
		return Condiciones.nombre(tipo)
	return "%s %d" % [Condiciones.nombre(tipo), valor]


## "A → B: 12 (+4 Destreza, +3 competencia (entrenado)) = 19 contra CA 16: éxito, 9 de daño"
static func _golpe(atacante: String, objetivo: String, resultado: ResultadoGolpe) -> String:
	var r: ResultadoPrueba = resultado.prueba
	var partes: PackedStringArray = PackedStringArray()
	for parte: Dictionary in r.desglose:
		partes.append("%+d %s" % [parte.valor, parte.fuente])
	var texto_tirada: String = str(r.natural)
	if r.tiradas.size() > 1:
		texto_tirada = "%s (de %s)" % [r.natural, ", ".join(r.tiradas.map(func(t: int) -> String: return str(t)))]
	var texto: String = "%s → %s: %s (%s) = %d contra CA %d: %s" % [
		atacante, objetivo, texto_tirada, ", ".join(partes), r.total, r.cd, GradoExito.nombre(r.grado)]
	if resultado.flanqueando:
		texto += " [flanqueo]"
	if resultado.no_letal:
		texto += " [no letal]"
	if resultado.impacto():
		texto += ", %d de daño" % resultado.danio
		for adicional: Dictionary in resultado.danio_adicional:
			texto += " (+%d %s)" % [(adicional.tirada as ResultadoTirada).total(), adicional.fuente]
	return texto

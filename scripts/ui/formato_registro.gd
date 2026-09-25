class_name FormatoRegistro
extends RefCounted
## Texto del registro de combate a partir de los eventos (términos según docs/GLOSARIO.md).
## Devuelve "" para los eventos que no se muestran en el registro.


static func texto(evento: EventoCombate, combate: Combate) -> String:
	var actor: String = String(evento.actor)
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
			return "%s puede usar %s contra %s" % [actor, evento.datos.reaccion, evento.datos.disparador]
		EventoCombate.Tipo.REACCION:
			return "%s usa %s (reacción)" % [actor, evento.datos.reaccion]
		EventoCombate.Tipo.GOLPE:
			return _golpe(actor, String(evento.datos.objetivo), evento.datos.resultado)
		EventoCombate.Tipo.CAIDO:
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
		EventoCombate.Tipo.ARCADAS:
			var a: ResultadoPrueba = evento.datos.resultado
			return "%s: Arcadas, Fortaleza %d contra CD %d: %s (indispuesto %d)" % [
				actor, a.total, a.cd, GradoExito.nombre(a.grado), evento.datos.valor]
	return ""


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
	if resultado.impacto():
		texto += ", %d de daño" % resultado.danio
		for adicional: Dictionary in resultado.danio_adicional:
			texto += " (+%d %s)" % [(adicional.tirada as ResultadoTirada).total(), adicional.fuente]
	return texto

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
			return "%s: %s (%d pies)" % [actor, accion, pies]
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
			return "%s: no se puede (%s)" % [actor, evento.datos.motivo]
	return ""


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
	return texto

class_name SinObjetivos
extends RefCounted
## Por qué una opción de la barra no tiene ahora ningún objetivo válido ("" si tiene alguno o no pide
## objetivo). La barra la muestra deshabilitada con este motivo (GDD, M4f). Sin estado.
## El motivo es el más repetido entre los candidatos (p. ej. "fuera de alcance"), sin contar "sin objetivo".


static func de_accion(combate: Combate, actor: Combatiente, id: StringName) -> String:
	var motivos: Array[String] = []
	for c: Combatiente in combate.participantes:
		var motivo: String = AccionesConObjetivo.motivo(combate, actor, id, c)
		if motivo == "":
			return ""
		motivos.append(motivo)
	return _mas_repetido(motivos)


static func de_conjuro(combate: Combate, actor: Combatiente, conjuro: DefinicionConjuro) -> String:
	if conjuro.objetivo == DefinicionConjuro.Objetivo.UNO_MISMO:
		return ""
	if conjuro.variantes.any(func(v: VarianteConjuro) -> bool: return v.es_area()):
		return ""
	var acciones: int = conjuro.acciones_posibles().min() if conjuro.es_variable() else 0
	var motivos: Array[String] = []
	for c: Combatiente in combate.participantes:
		var motivo: String = ObjetivosConjuro.motivo(combate, actor, PedidoConjuro.new(conjuro, c.id, acciones), c)
		if motivo == "":
			return ""
		motivos.append(motivo)
	return _mas_repetido(motivos)


static func _mas_repetido(motivos: Array[String]) -> String:
	var cuenta: Dictionary[String, int] = {}
	for motivo: String in motivos:
		if motivo != "sin objetivo":
			cuenta[motivo] = cuenta.get(motivo, 0) + 1
	var mejor: String = "sin objetivo"
	for motivo: String in cuenta:
		if mejor == "sin objetivo" or cuenta[motivo] > cuenta[mejor]:
			mejor = motivo
	return mejor

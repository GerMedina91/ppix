class_name AccionesHabilidad
extends RefCounted
## Acciones de habilidad en combate (M4b; verificadas en docs/verificacion/m4_recuerdos.md). Combate las expone
## en `habilidades` (referencia débil al Combate, como GestorReacciones).
## - Medicina en batalla (dote; 1 acción, manipular): Medicina contra CD 15 sobre una criatura viva adyacente
##   (o uno mismo); éxito 2d8 PG, éxito crítico 4d8, fallo crítico 1d8 de daño. No quita herido. El objetivo
##   queda inmune a la Medicina en batalla de ese sanador hasta descansar. [pendiente: botiquín de sanador]
## - Recordar conocimiento (1 acción, concentrar, secreto): la mejor habilidad del personaje para el rasgo de
##   la criatura contra la CD por nivel y rareza. Éxito: la ficha muestra la salvación más débil; fallo
##   crítico: muestra otra como si lo fuera; fallo: nada. El jugador no ve la tirada.

const MEDICINA_EN_BATALLA: StringName = &"medicina_en_batalla"
const ACCION_MEDICINA: String = "Medicina en batalla"
const ACCION_RECORDAR: String = "Recordar conocimiento"
const CD_MEDICINA: int = 15
const ALCANCE_TOQUE_PIES: int = 5
const _DADOS_MEDICINA: Dictionary[GradoExito.Grado, int] = {
	GradoExito.Grado.EXITO_CRITICO: 4, GradoExito.Grado.EXITO: 2, GradoExito.Grado.FALLO: 0, GradoExito.Grado.FALLO_CRITICO: 0,
}
const CARAS_MEDICINA: int = 8
const _SALVACIONES: Array[Estadisticas.Salvacion] = [
	Estadisticas.Salvacion.FORTALEZA, Estadisticas.Salvacion.REFLEJOS, Estadisticas.Salvacion.VOLUNTAD]

var _combate_ref: WeakRef


func _init(combate: Combate) -> void:
	_combate_ref = weakref(combate)


func _combate() -> Combate:
	return _combate_ref.get_ref() as Combate


# --- Medicina en batalla ---

func motivo_medicina_imposible(actor: Combatiente, objetivo: Combatiente) -> String:
	if not AccionesEspeciales.tiene(actor, MEDICINA_EN_BATALLA):
		return "no tiene esa dote"
	if objetivo == null or objetivo.condiciones.muerto or objetivo.fuente.es_muerto_viviente():
		return "sin objetivo"
	if objetivo != actor and not Medicion.en_alcance(actor.celda, objetivo.celda, ALCANCE_TOQUE_PIES):
		return "tiene que estar al lado"
	if objetivo.pg >= objetivo.pg_maximos():
		return "no está herido"
	if objetivo.inmune_medicina_de.has(actor.id):
		return "ya lo atendió (inmune hasta descansar)"
	return ""


func medicina_en_batalla(id_objetivo: StringName) -> Array[EventoCombate]:
	var combate: Combate = _combate()
	var actor: Combatiente = combate.turno_actual()
	var invalido: EventoCombate = combate.validar_accion(actor, 1, ACCION_MEDICINA)
	if invalido != null:
		return [invalido]
	var objetivo: Combatiente = combate.combatiente(id_objetivo)
	var motivo: String = motivo_medicina_imposible(actor, objetivo)
	if motivo != "":
		return [combate.invalida(actor, ACCION_MEDICINA, motivo)]
	actor.gastar_acciones(1)
	objetivo.inmune_medicina_de[actor.id] = true
	var eventos: Array[EventoCombate] = [combate.emitir(EventoCombate.new(EventoCombate.Tipo.ACCION_ESPECIAL, actor.id,
		{"accion": ACCION_MEDICINA, "objetivo": objetivo.id}))]
	# Manipular: puede disparar el Golpe reactivo, que con crítico la interrumpe.
	var disparo: DisparoReaccion = DisparoReaccion.usa_manipular(actor)
	eventos.append_array(combate.reacciones.procesar(disparo, func() -> Array[EventoCombate]:
		return _resolver_medicina(actor, objetivo, disparo)))
	return eventos


func _resolver_medicina(actor: Combatiente, objetivo: Combatiente, disparo: DisparoReaccion) -> Array[EventoCombate]:
	var combate: Combate = _combate()
	if combate.estado != Combate.Estado.EN_CURSO or not actor.condiciones.en_pie() or disparo.interrumpida:
		return []
	var resultado: ResultadoPrueba = actor.prueba_habilidad(Habilidad.Tipo.MEDICINA).resolver(combate.dados(), CD_MEDICINA)
	var estaba_en_pie: bool = objetivo.condiciones.en_pie()
	var datos: Dictionary = {"accion": ACCION_MEDICINA, "objetivo": objetivo.id, "resultado": resultado, "curacion": 0, "danio": 0}
	var dados: int = _DADOS_MEDICINA[resultado.grado]
	if dados > 0:
		var pg_antes: int = objetivo.pg
		objetivo.curar(Tirada.new(dados, CARAS_MEDICINA).tirar(combate.dados()).total())
		datos.curacion = objetivo.pg - pg_antes
		datos["levanta"] = not estaba_en_pie and objetivo.condiciones.en_pie()
	elif resultado.grado == GradoExito.Grado.FALLO_CRITICO:
		datos.danio = Tirada.new(1, CARAS_MEDICINA).tirar(combate.dados()).total()
		objetivo.recibir_danio(datos.danio, false)
	var eventos: Array[EventoCombate] = [combate.emitir(EventoCombate.new(EventoCombate.Tipo.RESULTADO_ESPECIAL, actor.id, datos))]
	eventos.append_array(combate.eventos_de_estado(objetivo, estaba_en_pie))
	eventos.append_array(combate.verificar_fin())
	return eventos


# --- Recordar conocimiento ---

## Mejor habilidad del actor para el rasgo de la criatura (la de mayor modificador).
static func habilidad_para(actor: Combatiente, objetivo: Combatiente) -> Habilidad.Tipo:
	var mejor: Habilidad.Tipo = RasgoCriatura.habilidades_de(objetivo.fuente.rasgo())[0]
	for habilidad: Habilidad.Tipo in RasgoCriatura.habilidades_de(objetivo.fuente.rasgo()):
		if actor.prueba_habilidad(habilidad).modificador_total() > actor.prueba_habilidad(mejor).modificador_total():
			mejor = habilidad
	return mejor


## Salvación más débil de verdad (la de menor modificador; empate: Fortaleza, Reflejos, Voluntad).
static func salvacion_mas_debil(c: Combatiente) -> Estadisticas.Salvacion:
	var debil: Estadisticas.Salvacion = _SALVACIONES[0]
	for s: Estadisticas.Salvacion in _SALVACIONES:
		if c.fuente.prueba_salvacion(s).modificador_total() < c.fuente.prueba_salvacion(debil).modificador_total():
			debil = s
	return debil


func motivo_recordar_imposible(actor: Combatiente, objetivo: Combatiente) -> String:
	if objetivo == null or objetivo.condiciones.muerto or objetivo.es_aliado_de(actor):
		return "sin objetivo"
	return ""


func recordar_conocimiento(id_objetivo: StringName) -> Array[EventoCombate]:
	var combate: Combate = _combate()
	var actor: Combatiente = combate.turno_actual()
	var invalido: EventoCombate = combate.validar_accion(actor, 1, ACCION_RECORDAR)
	if invalido != null:
		return [invalido]
	var objetivo: Combatiente = combate.combatiente(id_objetivo)
	var motivo: String = motivo_recordar_imposible(actor, objetivo)
	if motivo != "":
		return [combate.invalida(actor, ACCION_RECORDAR, motivo)]
	actor.gastar_acciones(1)
	var habilidad: Habilidad.Tipo = habilidad_para(actor, objetivo)
	var resultado: ResultadoPrueba = actor.prueba_habilidad(habilidad).resolver(combate.dados(), objetivo.fuente.cd_recordar())
	var revelada: Variant = null
	match resultado.grado:
		GradoExito.Grado.EXITO, GradoExito.Grado.EXITO_CRITICO:
			revelada = salvacion_mas_debil(objetivo)
		GradoExito.Grado.FALLO_CRITICO:
			revelada = _otra_salvacion(objetivo)
	if revelada != null:
		objetivo.conocimiento = {"salvacion_debil": revelada, "segun": actor.id}
	# Rasgo secreto: el evento no lleva la tirada, solo si recordó algo (verdadero o no).
	return [combate.emitir(EventoCombate.new(EventoCombate.Tipo.RESULTADO_ESPECIAL, actor.id,
		{"accion": ACCION_RECORDAR, "objetivo": objetivo.id, "secreto": true, "recordo": revelada != null,
		"habilidad": habilidad}))]


## Una salvación que no es la más débil (la más fuerte): lo que "recuerda" con un fallo crítico.
static func _otra_salvacion(c: Combatiente) -> Estadisticas.Salvacion:
	var fuerte: Estadisticas.Salvacion = _SALVACIONES[0]
	for s: Estadisticas.Salvacion in _SALVACIONES:
		if c.fuente.prueba_salvacion(s).modificador_total() > c.fuente.prueba_salvacion(fuerte).modificador_total():
			fuerte = s
	if fuerte == salvacion_mas_debil(c):
		fuerte = _SALVACIONES[(_SALVACIONES.find(fuerte) + 1) % _SALVACIONES.size()]
	return fuerte

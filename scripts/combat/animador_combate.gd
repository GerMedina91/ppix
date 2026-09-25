class_name AnimadorCombate
extends RefCounted
## Anima un EventoCombate sobre los actores del mapa: pasos por casilla, embestida del Golpe,
## textos flotantes (daño, grado, motivo de una acción imposible) y estado visual (caído, muerto).
## No toca reglas: solo muestra lo que ya pasó en el Combate.

const COLOR_DANIO: Color = Color(1.0, 0.4, 0.3)
const COLOR_FALLO: Color = Color(0.8, 0.8, 0.8)
const COLOR_INFO: Color = Color(0.7, 0.85, 1.0)
const COLOR_INVALIDA: Color = Color(1.0, 0.8, 0.4)
const COLOR_CONJURO: Color = Color(0.85, 0.6, 1.0)
## Fracción del camino hacia el objetivo que recorre la embestida de un Golpe.
const FRACCION_EMBESTIDA: float = 0.3

var config: ConfigCombate
var _mapa: Mapa
## Nodo donde se crean los textos flotantes y que da acceso al árbol (timers).
var _padre: Node
var _camara: CamaraMundo


func _init(config_combate: ConfigCombate, mapa: Mapa, padre: Node, camara: CamaraMundo) -> void:
	config = config_combate
	_mapa = mapa
	_padre = padre
	_camara = camara


func animar(evento: EventoCombate, actores: Dictionary[StringName, ActorMapa]) -> void:
	var actor: ActorMapa = actores.get(evento.actor)
	match evento.tipo:
		EventoCombate.Tipo.INICIO_TURNO:
			_camara.objetivo = actor
		EventoCombate.Tipo.MOVIMIENTO:
			await _movimiento(actor, evento.datos.camino)
		EventoCombate.Tipo.GOLPE:
			await _golpe(actor, actores[evento.datos.objetivo], evento.datos.resultado)
		EventoCombate.Tipo.CAIDO:
			actor.mostrar_estado(ActorMapa.EstadoVisual.CAIDO)
			await _texto(actor, "caído", COLOR_DANIO)
		EventoCombate.Tipo.MUERTE:
			actor.mostrar_estado(ActorMapa.EstadoVisual.MUERTO)
			await _texto(actor, "muerto", COLOR_DANIO)
		EventoCombate.Tipo.RECUPERACION:
			await _texto(actor, "recuperación: moribundo %d" % evento.datos.moribundo, COLOR_INFO)
		EventoCombate.Tipo.REACCION:
			await _texto(actor, "%s!" % evento.datos.reaccion, COLOR_INFO)
		EventoCombate.Tipo.TURNO_PERDIDO:
			await _texto(actor, "pierde el turno", COLOR_INFO)
		EventoCombate.Tipo.ACCION_INVALIDA:
			if actor != null:
				await _texto(actor, evento.datos.motivo, COLOR_INVALIDA)
		EventoCombate.Tipo.CONDICION:
			var texto: String = FormatoRegistro.condicion(evento.datos.condicion, evento.datos.valor)
			if evento.datos.valor == 0:
				texto = "sin %s" % Condiciones.nombre(evento.datos.condicion)
			await _texto(actor, texto, COLOR_INFO)
		EventoCombate.Tipo.ACCIONES_PERDIDAS:
			await _texto(actor, "%s: -%d ◆" % [Condiciones.nombre(evento.datos.condicion), evento.datos.cantidad], COLOR_INFO)
		EventoCombate.Tipo.LANZAMIENTO:
			await _texto(actor, (evento.datos.conjuro as DefinicionConjuro).nombre, COLOR_CONJURO)
		EventoCombate.Tipo.EFECTO_CONJURO:
			var r: ResultadoPrueba = evento.datos.resultado
			if r != null:
				await _texto(actores[evento.datos.objetivo], GradoExito.nombre(r.grado), COLOR_CONJURO)
		EventoCombate.Tipo.CONJURO_FALLIDO:
			await _texto(actor, "sin efecto: %s" % evento.datos.motivo, COLOR_INVALIDA)
		EventoCombate.Tipo.FIN_CONJURO:
			await _texto(actor, "termina %s" % (evento.datos.conjuro as DefinicionConjuro).nombre, COLOR_INFO)
		EventoCombate.Tipo.ARCADAS:
			await _texto(actor, "Arcadas: indispuesto %d" % evento.datos.valor, COLOR_INFO)
		_:
			pass


func _movimiento(actor: ActorMapa, camino: Array) -> void:
	for casilla: Vector2i in camino:
		var duracion: float = ControlParty.duracion_de_paso(actor.celda, casilla, config.segundos_por_celda)
		actor.dar_paso(casilla, _mapa.celda_a_posicion(casilla), duracion)
		await actor.paso_terminado


func _golpe(atacante: ActorMapa, objetivo: ActorMapa, resultado: ResultadoGolpe) -> void:
	var origen: Vector2 = atacante.global_position
	var embestida: Vector2 = origen.lerp(objetivo.global_position, FRACCION_EMBESTIDA)
	var tween: Tween = atacante.create_tween()
	tween.tween_property(atacante, "global_position", embestida, config.segundos_golpe / 2.0)
	tween.tween_property(atacante, "global_position", origen, config.segundos_golpe / 2.0)
	await tween.finished
	if resultado.impacto():
		await _texto(objetivo, ("¡%d!" if resultado.critico else "%d") % resultado.danio, COLOR_DANIO)
	else:
		await _texto(objetivo, GradoExito.nombre(resultado.prueba.grado), COLOR_FALLO)


func _texto(actor: ActorMapa, texto: String, color: Color) -> void:
	TextoFlotante.mostrar(_padre, actor.global_position, texto, color, config.segundos_texto_flotante)
	await _padre.get_tree().create_timer(config.pausa_entre_eventos).timeout

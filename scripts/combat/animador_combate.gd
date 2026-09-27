class_name AnimadorCombate
extends RefCounted
## Anima un EventoCombate sobre los actores del mapa: pasos por casilla, embestida del Golpe,
## textos flotantes (daño, grado, motivo de una acción imposible) y estado visual (caído, muerto).
## No toca reglas: solo muestra lo que ya pasó en el Combate.

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
			await _texto(actor, "caído", _estilo().flotante_danio)
		EventoCombate.Tipo.MUERTE:
			actor.mostrar_estado(ActorMapa.EstadoVisual.MUERTO)
			await _texto(actor, "muerto", _estilo().flotante_danio)
		EventoCombate.Tipo.RECUPERACION:
			await _texto(actor, "recuperación: moribundo %d" % evento.datos.moribundo, _estilo().flotante_info)
		EventoCombate.Tipo.REACCION:
			await _texto(actor, "%s!" % evento.datos.reaccion, _estilo().flotante_info)
		EventoCombate.Tipo.TURNO_PERDIDO:
			await _texto(actor, "pierde el turno", _estilo().flotante_info)
		EventoCombate.Tipo.ACCION_INVALIDA:
			if actor != null:
				await _texto(actor, evento.datos.motivo, _estilo().flotante_invalida)
		EventoCombate.Tipo.CONDICION:
			var texto: String = FormatoRegistro.condicion(evento.datos.condicion, evento.datos.valor)
			if evento.datos.valor == 0:
				texto = "sin %s" % Condiciones.nombre(evento.datos.condicion)
			await _texto(actor, texto, _estilo().flotante_info)
		EventoCombate.Tipo.ACCIONES_PERDIDAS:
			await _texto(actor, "%s: -%d ◆" % [Condiciones.nombre(evento.datos.condicion), evento.datos.cantidad], _estilo().flotante_info)
		EventoCombate.Tipo.LANZAMIENTO:
			await _texto(actor, (evento.datos.conjuro as DefinicionConjuro).nombre, _estilo().flotante_conjuro)
		EventoCombate.Tipo.EFECTO_CONJURO:
			var r: ResultadoPrueba = evento.datos.resultado
			var objetivo: ActorMapa = actores[evento.datos.objetivo]
			if evento.datos.get("curacion", 0) > 0:
				if evento.datos.get("levanta", false):
					objetivo.mostrar_estado(ActorMapa.EstadoVisual.NORMAL)
				await _texto(objetivo, "+%d" % evento.datos.curacion, _estilo().flotante_curacion)
			elif evento.datos.get("danio", 0) > 0:
				await _texto(objetivo, str(evento.datos.danio), _estilo().flotante_danio)
			elif r != null:
				await _texto(objetivo, GradoExito.nombre(r.grado), _estilo().flotante_conjuro)
			elif (evento.datos.conjuro as DefinicionConjuro).estabiliza:
				await _texto(objetivo, "estable", _estilo().flotante_info)
		EventoCombate.Tipo.CONJURO_FALLIDO:
			await _texto(actor, "sin efecto: %s" % evento.datos.motivo, _estilo().flotante_invalida)
		EventoCombate.Tipo.FIN_CONJURO:
			await _texto(actor, "termina %s" % (evento.datos.conjuro as DefinicionConjuro).nombre, _estilo().flotante_info)
		EventoCombate.Tipo.ARCADAS:
			await _texto(actor, "Arcadas: indispuesto %d" % evento.datos.valor, _estilo().flotante_info)
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
		await _texto(objetivo, ("¡%d!" if resultado.critico else "%d") % resultado.danio, _estilo().flotante_danio)
	else:
		await _texto(objetivo, GradoExito.nombre(resultado.prueba.grado), _estilo().flotante_fallo)


func _estilo() -> EstiloHud:
	return config.estilo_efectivo()


func _texto(actor: ActorMapa, texto: String, color: Color) -> void:
	TextoFlotante.mostrar(_padre, actor.global_position, texto, color, config.segundos_texto_flotante, _estilo())
	await _padre.get_tree().create_timer(config.pausa_entre_eventos).timeout

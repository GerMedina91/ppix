extends Node2D
## Raíz del mundo: carga el mapa actual como hijo y ubica a la party.
## La party y la cámara persisten entre mapas; solo se reemplaza el mapa.
## Al pisar una salida hace la transición con fundido y avisa por EventBus.mapa_cambiado.
##
## Y-sort: Mundo, MapaActual, cada Mapa, su capa Paredes y Party tienen y_sort_enabled,
## así las paredes y los miembros de la party se ordenan juntos por la posición de su base.

@export var catalogo: CatalogoMapas
@export var config: ConfigExploracion
@export var id_mapa_inicial: StringName = &""
@export var id_entrada_inicial: StringName = &""

## Se emite con el Encuentro que se disparó (lo toma el controlador de combate).
signal encuentro_disparado(encuentro: Encuentro)

var _mapa: Mapa
var _ultima_entrada: StringName = &""
var _id_encuentro_actual: StringName = &""

@onready var _contenedor_mapa: Node2D = $MapaActual
@onready var _combate: ControladorCombate = $ControladorCombate
@onready var _party: ControlParty = $Party
@onready var _camara: CamaraMundo = $Camara
@onready var _fundido: Fundido = $Fundido


func _ready() -> void:
	_party.lider_llego_a.connect(_al_llegar_lider)
	encuentro_disparado.connect(_iniciar_combate)
	_combate.combate_terminado.connect(_al_terminar_combate)
	_cargar_mapa(id_mapa_inicial, id_entrada_inicial)


func _al_llegar_lider(celda: Vector2i) -> void:
	var salida: SalidaMapa = _mapa.salida_en(celda)
	if salida != null:
		_transicionar(salida.id_mapa_destino, salida.id_entrada_destino)
		return
	_revisar_encuentros()


func _iniciar_combate(encuentro: Encuentro) -> void:
	_id_encuentro_actual = encuentro.id
	_combate.iniciar(encuentro, _mapa, _party, _camara)


func _al_terminar_combate(victoria: bool) -> void:
	var id_encuentro: StringName = _id_encuentro_actual
	if not victoria:
		# Placeholder hasta M4 (muerte del Eco): la party se cura y vuelve a la última entrada.
		GameState.estado_party.clear()
		for miembro: MiembroParty in _party.miembros():
			miembro.mostrar_estado(ActorMapa.EstadoVisual.NORMAL)
		EventBus.encuentro_terminado.emit(id_encuentro, false)
		_transicionar(GameState.id_mapa_actual, _ultima_entrada)
		return
	var grilla: GrillaMapa = _grilla_exploracion()
	_party.set_grilla(grilla)
	_party.reagrupar(Formacion.cadena(grilla, _party.celda_lider(), _party.miembros().size(), []) + _relleno())
	_camara.objetivo = _party.lider()
	_party.bloqueado = false
	EventBus.encuentro_terminado.emit(id_encuentro, true)


## Si la formación no alcanza para todos, los que faltan van a la última casilla.
func _relleno() -> Array[Vector2i]:
	var relleno: Array[Vector2i] = []
	for i in _party.miembros().size():
		relleno.append(_party.celda_lider())
	return relleno


## Grilla de exploración: la del mapa, sin poder atravesar a los enemigos que siguen en pie.
func _grilla_exploracion() -> GrillaMapa:
	var grilla: GrillaMapa = _mapa.construir_grilla()
	for encuentro: Encuentro in _mapa.encuentros():
		for enemigo: EnemigoEnMapa in encuentro.enemigos():
			if not enemigo.is_queued_for_deletion():
				grilla.set_transitable(enemigo.celda, false)
	return grilla


## Dispara el primer encuentro sin resolver cuyo disparador se active con las casillas de la party.
func _revisar_encuentros() -> void:
	var celdas: Array[Vector2i] = []
	for miembro: MiembroParty in _party.miembros():
		celdas.append(miembro.celda)
	if _combate.en_curso():
		return
	for encuentro: Encuentro in _mapa.encuentros():
		if encuentro.evaluar(celdas):
			encuentro_disparado.emit(encuentro)
			EventBus.encuentro_iniciado.emit(encuentro.id)
			return


## Bloquea a la party, funde a negro, cambia de mapa y vuelve a aclarar.
func _transicionar(id_mapa: StringName, id_entrada: StringName) -> void:
	_party.bloqueado = true
	await _fundido.fundir_a_negro(config.segundos_fundido)
	_cargar_mapa(id_mapa, id_entrada)
	EventBus.mapa_cambiado.emit(id_mapa)
	await _fundido.aclarar(config.segundos_fundido)
	_party.bloqueado = false


func _cargar_mapa(id_mapa: StringName, id_entrada: StringName) -> void:
	var definicion: DefinicionMapa = catalogo.buscar(id_mapa)
	if definicion == null:
		push_error("Mundo: el mapa '%s' no está en el catálogo" % id_mapa)
		return
	if _mapa != null:
		_contenedor_mapa.remove_child(_mapa)
		_mapa.queue_free()
	_mapa = (load(definicion.ruta_escena) as PackedScene).instantiate()
	_contenedor_mapa.add_child(_mapa)
	_mapa.configurar_transparencia(config.alfa_pared_transparente)
	_ultima_entrada = id_entrada
	# En exploración no se camina a través de los enemigos (en combate lo decide MovimientoCombate).
	var grilla: GrillaMapa = _grilla_exploracion()
	_party.entrar_a_mapa(_mapa, grilla, _mapa.celdas_de_formacion(id_entrada, _party.miembros().size(), grilla))
	_camara.objetivo = _party.lider()
	_camara.ajustar_a_mapa(_mapa.rect_global())
	GameState.id_mapa_actual = id_mapa

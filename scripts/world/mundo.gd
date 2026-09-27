extends Node2D
## Raíz del mundo: carga el mapa actual como hijo y ubica a la party.
## La party y la cámara persisten entre mapas; solo se reemplaza el mapa.
## Al pisar una salida hace la transición con fundido y avisa por EventBus.mapa_cambiado.
##
## Y-sort: Mundo, MapaActual, cada Mapa, su capa Paredes y Party tienen y_sort_enabled,
## así las paredes y los miembros de la party se ordenan juntos por la posición de su base.

@export var catalogo: CatalogoMapas
@export var config: ConfigExploracion
## Sueños al descansar en un punto estable.
@export var suenos: CatalogoSuenos
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
@onready var _panel_punto: PanelPuntoEstable = $PanelPuntoEstable
@onready var _muerte: GestorMuerte = $GestorMuerte


func _ready() -> void:
	_party.lider_llego_a.connect(_al_llegar_lider)
	encuentro_disparado.connect(_iniciar_combate)
	_combate.combate_terminado.connect(_al_terminar_combate)
	_party.interaccion_alcanzada.connect(_al_interactuar)
	_panel_punto.descanso_pedido.connect(_descansar)
	_panel_punto.cerrado.connect(func() -> void: _party.bloqueado = false)
	if _party.eco() != null:
		_party.eco().paso_terminado.connect(_al_pasar_eco)
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


func _al_terminar_combate(resultado: ResultadoCombate) -> void:
	var id_encuentro: StringName = _id_encuentro_actual
	if not resultado.victoria:
		await _al_morir_el_eco(resultado, id_encuentro)
		return
	_party.fijar_retirados(GestorMuerte.companeros_muertos())
	_muerte.colocar_cuerpos(_mapa, GameState.id_mapa_actual)
	var grilla: GrillaMapa = _grilla_exploracion()
	_party.set_grilla(grilla)
	_party.reagrupar(Formacion.cadena(grilla, _party.celda_lider(), _party.miembros().size(), []) + _relleno())
	_camara.objetivo = _party.lider()
	_party.salir_de_combate()
	EventBus.encuentro_terminado.emit(id_encuentro, true)


## Muerte del Eco (GDD 4.3): residuo donde cayó, la party (ya rearmada por ArmadoCombate) reaparece en el
## último punto estable (sin punto: en la última entrada del mapa) y el jugador elige el integrado que pierde.
func _al_morir_el_eco(resultado: ResultadoCombate, id_encuentro: StringName) -> void:
	_muerte.registrar_muerte(resultado)
	EventBus.encuentro_terminado.emit(id_encuentro, false)
	_party.salir_de_combate()
	if GameState.id_ultimo_punto_estable == &"":
		await _transicionar(GameState.id_mapa_actual, _ultima_entrada)
	else:
		await _transicionar(GameState.id_mapa_ultimo_punto_estable, &"", GameState.id_ultimo_punto_estable)
	_party.bloqueado = true
	await _muerte.elegir_perdida()
	_party.bloqueado = false


func _al_pasar_eco(celda: Vector2i) -> void:
	if _party.modo() == ControlParty.Modo.EXPLORACION:
		_muerte.al_pasar_eco(celda)


## Aspecto de cada miembro según su estado persistente (muerto, caído a 0 PG o normal).
func _mostrar_estado_party() -> void:
	for miembro: MiembroParty in _party.miembros():
		var guardado: Dictionary = GameState.estado_party.get(StringName(miembro.name), {})
		var estado: ActorMapa.EstadoVisual = ActorMapa.EstadoVisual.NORMAL
		if guardado.get("muerto", false):
			estado = ActorMapa.EstadoVisual.MUERTO
		elif guardado.get("pg", 1) == 0:
			estado = ActorMapa.EstadoVisual.CAIDO
		miembro.mostrar_estado(estado)


## La party llegó al lado de un objeto: se abre según su tipo (la party queda quieta mientras tanto).
func _al_interactuar(objeto: Interactuable) -> void:
	if objeto is PuntoEstable:
		_party.bloqueado = true
		_panel_punto.abrir(objeto)


## Descanso en un punto estable (GDD 4.3): recupera a la party y lo registra como punto de reaparición.
func _descansar(punto: PuntoEstable) -> void:
	Descanso.descansar(GameState.estado_party)
	_mostrar_estado_party()
	GameState.id_ultimo_punto_estable = punto.id
	GameState.id_mapa_ultimo_punto_estable = GameState.id_mapa_actual
	EventBus.punto_estable_activado.emit(punto.id)
	_panel_punto.mostrar_descansado(_sonar())


## El próximo sueño sin ver (o ninguno): queda visto y se avisa por EventBus.
func _sonar() -> DefinicionSueno:
	var sueno: DefinicionSueno = suenos.proximo(GameState.suenos_vistos) if suenos != null else null
	if sueno != null:
		GameState.suenos_vistos.append(sueno.id)
		EventBus.sueno_en_descanso.emit(sueno.id)
	return sueno


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


## Bloquea a la party, funde a negro, cambia de mapa y vuelve a aclarar. Con `id_punto`, la party aparece al
## lado de ese punto estable en vez de en una entrada.
func _transicionar(id_mapa: StringName, id_entrada: StringName, id_punto: StringName = &"") -> void:
	_party.bloqueado = true
	await _fundido.fundir_a_negro(config.segundos_fundido)
	_cargar_mapa(id_mapa, id_entrada, id_punto)
	EventBus.mapa_cambiado.emit(id_mapa)
	await _fundido.aclarar(config.segundos_fundido)
	_party.bloqueado = false


func _cargar_mapa(id_mapa: StringName, id_entrada: StringName, id_punto: StringName = &"") -> void:
	var definicion: DefinicionMapa = catalogo.buscar(id_mapa)
	if definicion == null:
		push_error("Mundo: el mapa '%s' no está en el catálogo" % id_mapa)
		return
	if _mapa != null:
		_contenedor_mapa.remove_child(_mapa)
		_mapa.queue_free()
	_mapa = (load(definicion.ruta_escena) as PackedScene).instantiate()
	_contenedor_mapa.add_child(_mapa)
	_mapa.aplicar_estado(GameState.mundo, id_mapa)
	_muerte.al_cargar_mapa(_mapa, id_mapa)
	_party.fijar_retirados(GestorMuerte.companeros_muertos())
	_mapa.configurar_transparencia(config.alfa_pared_transparente)
	if id_entrada != &"":
		_ultima_entrada = id_entrada
	# En exploración no se camina a través de los enemigos (en combate lo decide MovimientoCombate).
	var grilla: GrillaMapa = _grilla_exploracion()
	var cantidad: int = _party.miembros().size()
	var celdas: Array[Vector2i] = []
	if id_punto != &"":
		celdas = _mapa.celdas_junto_a_punto(id_punto, cantidad, grilla)
	else:
		celdas = _mapa.celdas_de_formacion(id_entrada, cantidad, grilla)
	_party.entrar_a_mapa(_mapa, grilla, celdas)
	_mostrar_estado_party()
	_camara.objetivo = _party.lider()
	_camara.ajustar_a_mapa(_mapa.rect_global())
	GameState.id_mapa_actual = id_mapa

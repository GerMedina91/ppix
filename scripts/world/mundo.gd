class_name Mundo
extends Node2D
## Raíz del mundo: carga el mapa actual como hijo y ubica a la party.
## La party y la cámara persisten entre mapas; solo se reemplaza el mapa.
## Al pisar una salida hace la transición con fundido y avisa por EventBus.mapa_cambiado. Las interacciones
## con objetos del mapa están en InteraccionesMundo; la muerte del Eco, en GestorMuerte.
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
var _encuentro_actual: Encuentro

@onready var _contenedor_mapa: Node2D = $MapaActual
@onready var _combate: ControladorCombate = $ControladorCombate
@onready var _party: ControlParty = $Party
@onready var _camara: CamaraMundo = $Camara
@onready var _fundido: Fundido = $Fundido
@onready var _muerte: GestorMuerte = $GestorMuerte
@onready var _fuentes: FuentesRecuerdos = $FuentesRecuerdos
@onready var _posicionamiento: PosicionamientoPrevio = $PosicionamientoPrevio


func _ready() -> void:
	_party.lider_llego_a.connect(_al_llegar_lider)
	encuentro_disparado.connect(_iniciar_combate)
	_combate.combate_terminado.connect(_al_terminar_combate)
	if _party.eco() != null:
		_party.eco().paso_terminado.connect(_al_pasar_eco)
	EventBus.antes_de_guardar.connect(_anotar_ubicacion)
	if GameState.recien_cargada:
		GameState.recien_cargada = false
		_continuar_partida.call_deferred()
	else:
		_cargar_mapa(id_mapa_inicial, id_entrada_inicial)
		EventBus.cambio_irreversible.emit("partida nueva")


## Partida cargada: la party vuelve a sus casillas; si quedó pendiente la pérdida del Eco, se pregunta, y si
## se cerró en medio de un combate, ese combate vuelve a empezar (SaveSystem).
func _continuar_partida() -> void:
	_cargar_mapa(GameState.id_mapa_actual, GameState.ubicacion.get("entrada", &""), &"", GameState.ubicacion.celdas)
	if GameState.perdida_pendiente:
		await _elegir_perdida()
	if GameState.combate_pendiente != &"":
		for encuentro: Encuentro in _mapa.encuentros():
			if encuentro.id == GameState.combate_pendiente and not encuentro.resuelto:
				encuentro_disparado.emit(encuentro)
				return
		GameState.combate_pendiente = &""


## Lo que SaveSystem necesita del mundo al guardar: las casillas de la party y la última entrada.
func _anotar_ubicacion() -> void:
	var celdas: Dictionary[StringName, Vector2i] = {}
	for miembro: MiembroParty in _party.miembros():
		celdas[StringName(miembro.name)] = miembro.celda
	GameState.ubicacion = {"celdas": celdas, "entrada": _ultima_entrada}


func _al_llegar_lider(celda: Vector2i) -> void:
	var salida: SalidaMapa = _mapa.salida_en(celda)
	if salida != null:
		_transicionar(salida.id_mapa_destino, salida.id_entrada_destino)
		return
	_revisar_encuentros()


func _iniciar_combate(encuentro: Encuentro) -> void:
	_id_encuentro_actual = encuentro.id
	_encuentro_actual = encuentro
	# Se guarda al dispararse (si se cierra durante el posicionamiento, se vuelve a posicionar) y después del
	# posicionamiento, el estado previo al primer turno: si se cierra en medio, el combate vuelve a empezar.
	GameState.combate_pendiente = encuentro.id
	EventBus.cambio_irreversible.emit("encuentro disparado")
	_party.entrar_en_combate()
	await _posicionamiento.posicionar(encuentro, _mapa, _party)
	EventBus.cambio_irreversible.emit("inicio de combate")
	_combate.iniciar(encuentro, _mapa, _party, _camara)


func _al_terminar_combate(resultado: ResultadoCombate) -> void:
	var id_encuentro: StringName = _id_encuentro_actual
	GameState.combate_pendiente = &""
	if not resultado.victoria:
		await _al_morir_el_eco(resultado, id_encuentro)
		return
	_party.fijar_retirados(GestorMuerte.companeros_muertos())
	mostrar_estado_party()  # los inconscientes estables ya despertaron (EstadoPartyCombate)
	_muerte.colocar_cuerpos(_mapa, GameState.id_mapa_actual)
	await _fuentes.resolver_inconscientes(resultado, _encuentro_actual)
	var grilla: GrillaMapa = grilla_exploracion()
	_party.set_grilla(grilla)
	_party.reagrupar(Formacion.cadena(grilla, _party.celda_lider(), _party.miembros().size(), []) + _relleno())
	_camara.objetivo = _party.lider()
	_party.salir_de_combate()
	EventBus.encuentro_terminado.emit(id_encuentro, true)
	EventBus.cambio_irreversible.emit("fin de combate")


## Muerte del Eco (GDD 4.3): residuo donde cayó, la party (ya rearmada por ArmadoCombate) reaparece en el
## último punto estable (sin punto: en la última entrada del mapa) y el jugador elige el integrado que pierde.
func _al_morir_el_eco(resultado: ResultadoCombate, id_encuentro: StringName) -> void:
	_muerte.registrar_muerte(resultado)
	# La pérdida queda pendiente desde ya: el cambio de mapa autoguarda y cerrar antes de elegir no la evita.
	GameState.perdida_pendiente = not GameState.recuerdos.inventario.integrados.is_empty()
	EventBus.encuentro_terminado.emit(id_encuentro, false)
	_party.salir_de_combate()
	if GameState.id_ultimo_punto_estable == &"":
		await _transicionar(GameState.id_mapa_actual, _ultima_entrada)
	else:
		await _transicionar(GameState.id_mapa_ultimo_punto_estable, &"", GameState.id_ultimo_punto_estable)
	EventBus.cambio_irreversible.emit("rearmado del Eco")
	await _elegir_perdida()


## El jugador elige el integrado que pierde el Eco (si le queda alguno); después se guarda.
func _elegir_perdida() -> void:
	_party.bloqueado = true
	await _muerte.elegir_perdida()
	GameState.perdida_pendiente = false
	EventBus.cambio_irreversible.emit("recuerdo perdido")
	_party.bloqueado = false


func _al_pasar_eco(celda: Vector2i) -> void:
	if _party.modo() == ControlParty.Modo.EXPLORACION:
		_muerte.al_pasar_eco(celda)


func mapa() -> Mapa:
	return _mapa


## Aspecto de cada miembro según su estado persistente (muerto, caído a 0 PG o normal).
func mostrar_estado_party() -> void:
	for miembro: MiembroParty in _party.miembros():
		var guardado: Dictionary = GameState.estado_party.get(StringName(miembro.name), {})
		var estado: ActorMapa.EstadoVisual = ActorMapa.EstadoVisual.NORMAL
		if guardado.get("muerto", false):
			estado = ActorMapa.EstadoVisual.MUERTO
		elif guardado.get("pg", 1) == 0:
			estado = ActorMapa.EstadoVisual.CAIDO
		miembro.mostrar_estado(estado)


## Si la formación no alcanza para todos, los que faltan van a la última casilla.
func _relleno() -> Array[Vector2i]:
	var relleno: Array[Vector2i] = []
	for i in _party.miembros().size():
		relleno.append(_party.celda_lider())
	return relleno


## Grilla de exploración: la del mapa, sin poder atravesar a los enemigos que siguen en pie.
func grilla_exploracion() -> GrillaMapa:
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


## La party entra por `id_entrada`, al lado del punto estable `id_punto` o, al cargar una partida, en sus
## `celdas_guardadas` (id del miembro -> casilla).
func _cargar_mapa(id_mapa: StringName, id_entrada: StringName, id_punto: StringName = &"",
		celdas_guardadas: Dictionary = {}) -> void:
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
	var grilla: GrillaMapa = grilla_exploracion()
	var cantidad: int = _party.miembros().size()
	var celdas: Array[Vector2i] = []
	if not celdas_guardadas.is_empty():
		for miembro: MiembroParty in _party.miembros():
			celdas.append(celdas_guardadas.get(StringName(miembro.name), celdas_guardadas.values()[0]))
	elif id_punto != &"":
		celdas = _mapa.celdas_junto_a_punto(id_punto, cantidad, grilla)
	else:
		celdas = _mapa.celdas_de_formacion(id_entrada, cantidad, grilla)
	_party.entrar_a_mapa(_mapa, grilla, celdas)
	mostrar_estado_party()
	_camara.objetivo = _party.lider()
	_camara.ajustar_a_mapa(_mapa.rect_global())
	GameState.id_mapa_actual = id_mapa

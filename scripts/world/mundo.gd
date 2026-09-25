extends Node2D
## Raíz del mundo: carga el mapa actual como hijo y ubica a la party.
## La party y la cámara persisten entre mapas; solo se reemplaza el mapa.
## Al pisar una salida hace la transición con fundido y avisa por EventBus.mapa_cambiado.

@export var catalogo: CatalogoMapas
@export var config: ConfigExploracion
@export var id_mapa_inicial: StringName = &""
@export var id_entrada_inicial: StringName = &""

var _mapa: Mapa

@onready var _contenedor_mapa: Node2D = $MapaActual
@onready var _party: ControlParty = $Party
@onready var _camara: CamaraMundo = $Camara
@onready var _fundido: Fundido = $Fundido


func _ready() -> void:
	_party.lider_llego_a.connect(_al_llegar_lider)
	_cargar_mapa(id_mapa_inicial, id_entrada_inicial)


func _al_llegar_lider(celda: Vector2i) -> void:
	var salida: SalidaMapa = _mapa.salida_en(celda)
	if salida != null:
		_transicionar(salida.id_mapa_destino, salida.id_entrada_destino)


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
	_party.entrar_a_mapa(_mapa, _mapa.construir_grilla(), _mapa.celda_de_entrada(id_entrada))
	_camara.objetivo = _party.lider()
	_camara.ajustar_a_mapa(_mapa.rect_global())
	GameState.id_mapa_actual = id_mapa

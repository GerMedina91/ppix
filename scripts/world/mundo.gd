extends Node2D
## Raíz del mundo: carga el mapa actual como hijo y ubica a la party.
## La party y la cámara persisten entre mapas; solo se reemplaza el mapa.

@export var catalogo: CatalogoMapas
@export var id_mapa_inicial: StringName = &""
@export var id_entrada_inicial: StringName = &""

var _mapa: Mapa

@onready var _contenedor_mapa: Node2D = $MapaActual
@onready var _party: ControlParty = $Party


func _ready() -> void:
	_cargar_mapa(id_mapa_inicial, id_entrada_inicial)


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
	GameState.id_mapa_actual = id_mapa

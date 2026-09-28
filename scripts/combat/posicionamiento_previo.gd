class_name PosicionamientoPrevio
extends Node2D
## Fase de posicionamiento previa al combate (Posicionamiento, en rules/): al dispararse un encuentro, antes de
## tirar iniciativa, el jugador puede reubicar a cada miembro hasta 10 pies de donde estaba. Click en un miembro
## para elegirlo; click en una casilla resaltada para moverlo. "Empezar combate" termina la fase (también sirve
## para omitirla). Los enemigos no se mueven. Solo presenta: dibuja en el mapa y avisa por `terminado`.

signal terminado

const INSTRUCCION: String = "Antes del combate: click en un miembro y después en una casilla resaltada (hasta 10 pies)."

@export var estilo: EstiloHud
## Para tests y arneses que no la necesitan: la fase termina enseguida.
@export var omitir: bool = false

var _activo: bool = false
var _mapa: Mapa
var _party: ControlParty
var _encuentro: Encuentro
var _origenes: Dictionary[MiembroParty, Vector2i] = {}
var _elegido: MiembroParty
var _posibles: Array[Vector2i] = []
var _capa: CanvasLayer


func _ready() -> void:
	z_index = 1
	_capa = CanvasLayer.new()
	_capa.layer = 6
	add_child(_capa)
	var columna: VBoxContainer = ConstruccionUi.panel_centrado(ConstruccionUi.raiz(_capa, estilo), 0, 0.06)
	columna.add_child(ConstruccionUi.etiqueta(INSTRUCCION))
	columna.add_child(ConstruccionUi.boton("Empezar combate", terminar))
	_capa.visible = false


func activo() -> bool:
	return _activo


## Corre la fase (se espera con await). La party ya está quieta (ControlParty.entrar_en_combate).
func posicionar(encuentro: Encuentro, mapa: Mapa, party: ControlParty) -> void:
	if omitir:
		return
	_encuentro = encuentro
	_mapa = mapa
	_party = party
	_origenes.clear()
	for miembro: MiembroParty in party.miembros():
		_origenes[miembro] = miembro.celda
	_elegir(party.miembros()[0])
	_activo = true
	_capa.visible = true
	await terminado


func terminar() -> void:
	if not _activo:
		return
	_activo = false
	_capa.visible = false
	_elegido = null
	_posibles.clear()
	queue_redraw()
	terminado.emit()


## Click en una casilla: elige al miembro que está ahí o mueve al elegido si la casilla es posible.
func click_en(celda: Vector2i) -> void:
	if not _activo:
		return
	for miembro: MiembroParty in _origenes:
		if miembro.celda == celda:
			_elegir(miembro)
			return
	if _elegido != null and _posibles.has(celda):
		_elegido.colocar(celda, _mapa.celda_a_posicion(celda))
		_elegir(_elegido)


func elegido() -> MiembroParty:
	return _elegido


func posibles() -> Array[Vector2i]:
	return _posibles


func _elegir(miembro: MiembroParty) -> void:
	_elegido = miembro
	var ocupadas: Dictionary[Vector2i, bool] = {}
	var enemigos: Array[Vector2i] = []
	for otro: MiembroParty in _origenes:
		if otro != miembro:
			ocupadas[otro.celda] = true
	for enemigo: EnemigoEnMapa in _encuentro.enemigos():
		ocupadas[enemigo.celda] = true
		enemigos.append(enemigo.celda)
	_posibles = Posicionamiento.casillas_posibles(_mapa.construir_grilla(), _origenes[miembro], ocupadas, enemigos)
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if _activo and event.is_action_pressed(&"mover_a_click"):
		click_en(_mapa.posicion_a_celda(get_global_mouse_position()))
		get_viewport().set_input_as_handled()


func _draw() -> void:
	if not _activo:
		return
	var estilo_efectivo: EstiloHud = estilo if estilo != null else EstiloHud.por_defecto()
	for celda: Vector2i in _posibles:
		draw_colored_polygon(_local(_mapa.rombo_global(celda)), estilo_efectivo.color_zancadas(1))
	if _elegido != null:
		draw_colored_polygon(_local(_mapa.rombo_global(_elegido.celda)), estilo_efectivo.resaltado_activo)


func _local(puntos: PackedVector2Array) -> PackedVector2Array:
	var locales: PackedVector2Array = PackedVector2Array()
	for p: Vector2 in puntos:
		locales.append(to_local(p))
	return locales

class_name InteraccionesMundo
extends Node
## Qué pasa cuando la party llega a un objeto del mapa (click en exploración) y las pantallas que se abren
## desde la exploración. La party queda quieta mientras hay una pantalla o un panel abierto.
## - ObjetoRecuerdo: el Eco lo toma. CuerpoCompanero: extraer sus recuerdos. PuestoTasador: el trueque.
## - PuntoEstable: panel Descansar / Seguir; descansar recupera a la party, lo registra como reaparición y
##   el Eco sueña (el próximo sueño sin ver).
## - Botón o tecla R: los recuerdos del Eco.

@export var mundo: Mundo
@export var party: ControlParty
@export var fuentes: FuentesRecuerdos
@export var tasador: PantallaTasador
@export var recuerdos: PantallaRecuerdos
@export var panel_punto: PanelPuntoEstable
@export var hud: HudExploracion
## Sueños al descansar en un punto estable.
@export var suenos: CatalogoSuenos


func _ready() -> void:
	party.interaccion_alcanzada.connect(al_interactuar)
	panel_punto.descanso_pedido.connect(_descansar)
	panel_punto.cerrado.connect(_liberar_party)
	tasador.cerrada.connect(_liberar_party)
	recuerdos.cerrada.connect(_liberar_party)
	hud.recuerdos_pedidos.connect(_abrir_recuerdos)


func al_interactuar(objeto: Interactuable) -> void:
	if objeto is ObjetoRecuerdo:
		fuentes.tomar_objeto(objeto, mundo.mapa())
		party.set_grilla(mundo.grilla_exploracion())  # la casilla del objeto queda libre
	elif objeto is CuerpoCompanero:
		party.bloqueado = true
		await fuentes.extraer_de_cuerpo(objeto)
		party.bloqueado = false
	elif objeto is PuestoTasador:
		party.bloqueado = true
		tasador.abrir()
	elif objeto is DisparadorDialogo:
		# [M5-prep b] Acá se abre el diálogo con Dialogue Manager.
		fuentes.aviso.mostrar("Diálogo: %s (%s)" % [(objeto as DisparadorDialogo).titulo, (objeto as DisparadorDialogo).dialogo.get_file()])
	elif objeto is PuntoEstable:
		party.bloqueado = true
		panel_punto.abrir(objeto)


## Descanso en un punto estable (GDD 4.3): recupera a la party y lo registra como punto de reaparición.
func _descansar(punto: PuntoEstable) -> void:
	Descanso.descansar(GameState.estado_party)
	mundo.mostrar_estado_party()
	GameState.id_ultimo_punto_estable = punto.id
	GameState.id_mapa_ultimo_punto_estable = GameState.id_mapa_actual
	var sueno: DefinicionSueno = _sonar()
	EventBus.punto_estable_activado.emit(punto.id)
	panel_punto.mostrar_descansado(sueno)


## El próximo sueño sin ver (o ninguno): queda visto y se avisa por EventBus.
func _sonar() -> DefinicionSueno:
	var sueno: DefinicionSueno = suenos.proximo(GameState.suenos_vistos) if suenos != null else null
	if sueno != null:
		GameState.suenos_vistos.append(sueno.id)
		EventBus.sueno_en_descanso.emit(sueno.id)
	return sueno


func _abrir_recuerdos() -> void:
	party.bloqueado = true
	recuerdos.abrir(party.eco())


func _liberar_party() -> void:
	party.bloqueado = false

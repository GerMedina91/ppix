class_name InteraccionesMundo
extends Node
## Qué pasa cuando la party llega a un objeto del mapa (click en exploración) y las pantallas que se abren
## desde la exploración. La party queda quieta mientras hay una pantalla o un panel abierto.
## - ObjetoRecuerdo: el Eco lo toma; si `cierra_el_slice` (el fragmento 2 del Doliente), queda la marca
##   `fin_del_slice` y se muestra el fin del slice. CuerpoCompanero: extraer sus recuerdos.
## - PuestoTasador: la primera vez, su diálogo de presentación (obligatorio; queda la marca
##   `tasador_presentado`); después, el comercio directo, con "Hablar" para una charla.
## - PuntoEstable: panel Descansar / Seguir / Hablar con… (compañeros vivos); descansar recupera a la party,
##   lo registra como reaparición y el Eco sueña (el próximo sueño sin ver).
## - DisparadorDialogo: su diálogo, si se cumple la condición (y una sola vez si es `una_vez`).
## - Botón o tecla R: los recuerdos del Eco.
## Los diálogos usan un ContextoDialogo como `estado`; si cambian algo, se autoguarda.

@export var mundo: Mundo
@export var party: ControlParty
@export var fuentes: FuentesRecuerdos
@export var tasador: PantallaTasador
@export var recuerdos: PantallaRecuerdos
@export var panel_punto: PanelPuntoEstable
@export var hud: HudExploracion
@export var caja: CajaDialogo
@export var fin_slice: PantallaFinSlice
## Sueños al descansar en un punto estable.
@export var suenos: CatalogoSuenos
@export_file("*.dialogue") var dialogo_tasador: String = "res://dialogue/tasador.dialogue"
@export_file("*.dialogue") var dialogo_companeros: String = "res://dialogue/companeros.dialogue"

const MARCA_TASADOR: String = "tasador_presentado"
const CUE_PRESENTACION: String = "presentacion"
const CUE_CHARLA: String = "charla"
const MARCA_FIN_DEL_SLICE: String = "fin_del_slice"


func _ready() -> void:
	party.interaccion_alcanzada.connect(al_interactuar)
	panel_punto.descanso_pedido.connect(_descansar)
	panel_punto.cerrado.connect(_liberar_party)
	tasador.cerrada.connect(_liberar_party)
	recuerdos.cerrada.connect(_liberar_party)
	hud.recuerdos_pedidos.connect(_abrir_recuerdos)
	tasador.hablar_pedido.connect(_charlar_con_tasador)
	panel_punto.hablar_pedido.connect(_hablar_con_companero)


func al_interactuar(objeto: Interactuable) -> void:
	if objeto is ObjetoRecuerdo:
		var cierra: bool = (objeto as ObjetoRecuerdo).cierra_el_slice
		if cierra:
			GameState.marcas[StringName(MARCA_FIN_DEL_SLICE)] = true  # entra en el autoguardado de tomar el objeto
		fuentes.tomar_objeto(objeto, mundo.mapa())
		party.set_grilla(mundo.grilla_exploracion())  # la casilla del objeto queda libre
		if cierra:
			party.bloqueado = true
			fin_slice.mostrar()
	elif objeto is CuerpoCompanero:
		party.bloqueado = true
		await fuentes.extraer_de_cuerpo(objeto)
		party.bloqueado = false
	elif objeto is PuestoTasador:
		if GameState.marcas.has(StringName(MARCA_TASADOR)):
			party.bloqueado = true
			tasador.abrir()
		else:
			var contexto: ContextoDialogo = ContextoDialogo.new()
			contexto.marcar(MARCA_TASADOR)
			await dialogar(load(dialogo_tasador), CUE_PRESENTACION, contexto)
	elif objeto is DisparadorDialogo:
		await _disparar_dialogo(objeto)
	elif objeto is PuntoEstable:
		party.bloqueado = true
		panel_punto.abrir(objeto, _companeros_vivos())


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


## Muestra un diálogo con la party quieta. Al terminar: si cambió algo, autoguarda; si pidió comerciar, abre
## el Tasador.
func dialogar(recurso: DialogueResource, cue: String, contexto: ContextoDialogo) -> void:
	party.bloqueado = true
	await caja.mostrar(recurso, cue, contexto)
	if contexto.hubo_cambios:
		EventBus.cambio_irreversible.emit("diálogo")
	if contexto.pidio_comercio:
		tasador.abrir()
	else:
		party.bloqueado = false


func _disparar_dialogo(disparador: DisparadorDialogo) -> void:
	var contexto: ContextoDialogo = ContextoDialogo.new()
	var marca: String = "dialogo:%s/%s" % [GameState.id_mapa_actual, disparador.name]
	if (disparador.una_vez and contexto.tiene_marca(marca)) or not contexto.cumple(disparador.condicion):
		return
	if disparador.una_vez:
		contexto.marcar(marca)
	await dialogar(load(disparador.dialogo), disparador.titulo, contexto)


func _charlar_con_tasador() -> void:
	tasador.cerrar()
	await dialogar(load(dialogo_tasador), CUE_CHARLA, ContextoDialogo.new())


## "Hablar con…" en el punto estable: el cue es el nombre del compañero en minúsculas (irsa, orven, vaisha).
## Al terminar vuelve el panel del punto.
func _hablar_con_companero(id_miembro: StringName) -> void:
	var punto: PuntoEstable = panel_punto.punto()
	panel_punto.cerrar()
	for miembro: MiembroParty in party.miembros():
		if StringName(miembro.name) == id_miembro:
			await dialogar(load(dialogo_companeros), miembro.nombre_visible().to_lower(), ContextoDialogo.new())
	party.bloqueado = true
	panel_punto.abrir(punto, _companeros_vivos())


func _companeros_vivos() -> Array[Dictionary]:
	var lista: Array[Dictionary] = []
	for miembro: MiembroParty in party.miembros():
		if not miembro.es_eco and not GameState.estado_party.get(StringName(miembro.name), {}).get("muerto", false):
			lista.append({"id": StringName(miembro.name), "nombre": miembro.nombre_visible()})
	return lista

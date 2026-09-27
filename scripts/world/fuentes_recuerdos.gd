class_name FuentesRecuerdos
extends Node
## De dónde saca recuerdos el Eco en el mundo (GDD 4.2), fuera del Tasador. Lo usa el Mundo.
## - Objetos con recuerdos: se toman al interactuar y desaparecen para siempre.
## - Enemigos inconscientes tras la victoria: por cada uno, extraer (su recuerdo, si tiene), perdonar o
##   rematar; queda registrado en GameState.recuerdos.destinos y el enemigo se retira del mapa.
## - Cuerpo de un compañero muerto: se le extraen una vez sus recuerdos predefinidos.

const EXTRAER: String = "Extraer"
const PERDONAR: String = "Perdonar"
const REMATAR: String = "Rematar"
const DEJAR: String = "Dejar"

@export var panel: PanelOpciones
@export var aviso: AvisoMundo
@export var party: ControlParty


func tomar_objeto(objeto: ObjetoRecuerdo, mapa: Mapa) -> void:
	GameState.recuerdos.inventario.agregar_suelto(objeto.recuerdo)
	GameState.mundo.tomar_objeto(GameState.id_mapa_actual, StringName(objeto.name))
	mapa.quitar_interactuable(objeto)
	aviso.mostrar("El Eco toma un recuerdo: %s" % objeto.recuerdo.nombre)


## Tras una victoria: el jugador decide qué hacer con cada enemigo inconsciente (vuelve cuando terminó).
func resolver_inconscientes(resultado: ResultadoCombate, encuentro: Encuentro) -> void:
	for id: StringName in resultado.enemigos_inconscientes:
		var enemigo: EnemigoEnMapa = encuentro.get_node_or_null(NodePath(String(id)))
		if enemigo == null:
			continue
		var recuerdo: DefinicionRecuerdo = enemigo.definicion.recuerdo
		var opciones: PackedStringArray = PackedStringArray([PERDONAR, REMATAR])
		if recuerdo != null:
			opciones.insert(0, EXTRAER)
		panel.abrir("%s está inconsciente" % id, "¿Qué hace el Eco?", opciones)
		var indice: int = await panel.elegida
		var elegida: String = opciones[indice]
		_aplicar_destino(id, elegida, recuerdo)
		GameState.mundo.retirar_enemigo(GameState.id_mapa_actual, id)
		enemigo.queue_free()


func _aplicar_destino(id: StringName, elegida: String, recuerdo: DefinicionRecuerdo) -> void:
	var destino: EstadoRecuerdos.Destino = EstadoRecuerdos.Destino.PERDONADO
	match elegida:
		EXTRAER:
			destino = EstadoRecuerdos.Destino.EXTRAIDO
			GameState.recuerdos.inventario.agregar_suelto(recuerdo)
			aviso.mostrar("El Eco extrae un recuerdo: %s" % recuerdo.nombre)
		REMATAR:
			destino = EstadoRecuerdos.Destino.REMATADO
	GameState.recuerdos.registrar_destino(EstadoRecuerdos.id_enemigo(GameState.id_mapa_actual, id), destino)


## Cuerpo de un compañero: una sola vez, el Eco puede extraerle sus recuerdos predefinidos.
func extraer_de_cuerpo(cuerpo: CuerpoCompanero) -> void:
	var miembro: MiembroParty = _miembro(cuerpo.id_miembro)
	if GameState.mundo.cuerpo_extraido(cuerpo.id_miembro) or miembro == null or miembro.recuerdos_del_cuerpo.is_empty():
		aviso.mostrar("Ya no queda nada que extraer")
		return
	panel.abrir("Cuerpo de %s" % miembro.nombre_visible(), "Extraer sus recuerdos (%d)" % miembro.recuerdos_del_cuerpo.size(),
		PackedStringArray([EXTRAER, DEJAR]))
	var indice: int = await panel.elegida
	if indice != 0:
		return
	for recuerdo: DefinicionRecuerdo in miembro.recuerdos_del_cuerpo:
		GameState.recuerdos.inventario.agregar_suelto(recuerdo)
	GameState.mundo.extraer_cuerpo(cuerpo.id_miembro)
	aviso.mostrar("El Eco extrae %d recuerdos de %s" % [miembro.recuerdos_del_cuerpo.size(), miembro.nombre_visible()])


func _miembro(id: StringName) -> MiembroParty:
	for miembro: MiembroParty in party.todos():
		if StringName(miembro.name) == id:
			return miembro
	return null

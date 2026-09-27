class_name GestorMuerte
extends Node
## Muerte del Eco (GDD 4.3), del lado del mundo: el residuo queda en la casilla donde cayó (con una marca en
## su mapa; se recupera cuando el Eco la pisa) y, al rearmarse, el jugador elige el recuerdo integrado que
## pierde. La reaparición en el punto estable la hace el Mundo; el estado de la party, ArmadoCombate.

@export var config: ConfigRecuerdos
@export var panel_perdida: PanelPerdida
@export var aviso: AvisoMundo

var _marca: MarcaResiduo


## El Eco murió: sus recuerdos sueltos (salvo los del Doliente) quedan en un residuo donde cayó.
func registrar_muerte(resultado: ResultadoCombate) -> void:
	GameState.recuerdos.muerte_del_eco(GameState.id_mapa_actual, resultado.celda_eco, config)


## Tras reaparecer: si tiene integrados de destreza, el jugador elige cuál pierde (vuelve cuando eligió).
func elegir_perdida() -> void:
	var integrados: Array[DefinicionRecuerdo] = GameState.recuerdos.inventario.integrados
	if integrados.is_empty():
		return
	panel_perdida.abrir(integrados)
	var elegido: DefinicionRecuerdo = await panel_perdida.elegido
	GameState.recuerdos.inventario.soltar_integrado(elegido)
	aviso.mostrar("El Eco perdió un recuerdo: %s" % elegido.nombre)


## Al cargar un mapa: si el residuo está ahí, lo marca en su casilla.
func al_cargar_mapa(mapa: Mapa, id_mapa: StringName) -> void:
	_marca = null
	var residuo: Dictionary = GameState.recuerdos.residuo
	if residuo.is_empty() or residuo.mapa != id_mapa:
		return
	_marca = MarcaResiduo.new()
	_marca.name = "MarcaResiduo"
	mapa.add_child(_marca)
	_marca.colocar(residuo.celda, mapa.celda_a_posicion(residuo.celda))


## El Eco pisó `celda` en exploración: si ahí está el residuo, lo recupera.
func al_pasar_eco(celda: Vector2i) -> void:
	if not is_instance_valid(_marca) or celda != _marca.celda:
		return
	var recuperados: Array[DefinicionRecuerdo] = GameState.recuerdos.recuperar_residuo()
	_marca.queue_free()
	_marca = null
	aviso.mostrar("El Eco recupera %d %s" % [recuperados.size(), "recuerdo" if recuperados.size() == 1 else "recuerdos"])


func hay_marca() -> bool:
	return is_instance_valid(_marca)

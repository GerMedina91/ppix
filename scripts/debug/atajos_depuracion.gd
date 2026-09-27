class_name AtajosDepuracion
extends Node
## Atajos de depuración (solo builds de debug).
## - F4 (`curar_party_depuracion`): restaura por completo a la party, como un descanso (PG, sin moribundo,
##   herido ni inconsciente). Los compañeros muertos siguen muertos (muerte permanente). Solo para depurar: en
##   el juego se descansa en los puntos estables.

const ACCION_CURAR: StringName = &"curar_party_depuracion"

@export var party: ControlParty
@export var controlador: ControladorCombate


func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(ACCION_CURAR):
		curar_party()
		get_viewport().set_input_as_handled()


func curar_party() -> void:
	Descanso.descansar(GameState.estado_party)
	for miembro: MiembroParty in party.miembros():
		if not GestorMuerte.companeros_muertos().has(StringName(miembro.name)):
			miembro.mostrar_estado(ActorMapa.EstadoVisual.NORMAL)
	if controlador.en_curso():
		for c: Combatiente in controlador.combate().participantes:
			if c.bando == Combatiente.Bando.PARTY and not c.condiciones.muerto:
				c.restaurar_por_completo()
		controlador.redibujar()

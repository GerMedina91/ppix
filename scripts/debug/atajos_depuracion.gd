class_name AtajosDepuracion
extends Node
## Atajos de depuración (solo builds de debug).
## - F4 (`curar_party_depuracion`): restaura por completo a la party (PG, sin moribundo/herido/inconsciente;
##   también revive), porque los PG persisten entre combates y todavía no hay descanso.

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
	GameState.estado_party.clear()
	for miembro: MiembroParty in party.miembros():
		miembro.mostrar_estado(ActorMapa.EstadoVisual.NORMAL)
	if controlador.en_curso():
		controlador.restaurar_party_depuracion()

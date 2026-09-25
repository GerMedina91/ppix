class_name EventoCombate
extends RefCounted
## Algo que pasó en el combate. La presentación los consume en orden para animar y mostrar el registro.

enum Tipo {
	INICIATIVA, INICIO_RONDA, INICIO_TURNO, RECUPERACION, TURNO_PERDIDO,
	MOVIMIENTO, GOLPE, CAIDO, MUERTE, FIN_TURNO, FIN_COMBATE, ACCION_INVALIDA,
	REACCION_PENDIENTE, REACCION,
	## Cambió el valor de una condición: {"condicion": Condiciones.Tipo, "valor", "anterior"}.
	CONDICION,
	## Perdió acciones al empezar el turno: {"cantidad", "condicion": Condiciones.Tipo}.
	ACCIONES_PERDIDAS,
	## Arcadas contra indispuesto: {"resultado": ResultadoPrueba, "anterior", "valor"}.
	ARCADAS,
	## Empieza a lanzar un conjuro (ya pagado): {"conjuro": DefinicionConjuro, "objetivo"}.
	LANZAMIENTO,
	## Efecto del conjuro: {"conjuro", "objetivo", "resultado": ResultadoPrueba de la salvación o null}.
	EFECTO_CONJURO,
	## El conjuro no tuvo efecto: {"conjuro", "motivo"} (interrumpido, segundo maleficio del turno).
	CONJURO_FALLIDO,
	## Sostuvo un conjuro: {"conjuro", "objetivo"}.
	SOSTENER,
	## Terminó un conjuro sostenido: {"conjuro", "objetivo"}.
	FIN_CONJURO,
}

var tipo: Tipo
## Combatiente que actúa o al que le pasa (vacío si no aplica).
var actor: StringName = &""
var datos: Dictionary = {}


func _init(tipo_evento: Tipo, actor_evento: StringName = &"", datos_evento: Dictionary = {}) -> void:
	tipo = tipo_evento
	actor = actor_evento
	datos = datos_evento


func _to_string() -> String:
	return "%s %s %s" % [Tipo.keys()[tipo], actor, datos]

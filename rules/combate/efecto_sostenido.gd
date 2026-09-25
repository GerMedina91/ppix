class_name EfectoSostenido
extends RefCounted
## Un conjuro sostenido en curso (Player Core p. 302 y 419): dura hasta el final del próximo turno del
## lanzador salvo que lo Sostenga en ese turno, y como mucho `conjuro.sostenido_rondas_max` turnos suyos.

var lanzador: StringName
var conjuro: DefinicionConjuro
var objetivo: StringName
## Se lanzó o se Sostuvo en el turno en curso del lanzador (si termina su turno sin esto, se acaba).
var sostenido_en_turno: bool = true
## Turnos del lanzador que ya duró.
var turnos: int = 0


func _init(id_lanzador: StringName, conjuro_lanzado: DefinicionConjuro, id_objetivo: StringName) -> void:
	lanzador = id_lanzador
	conjuro = conjuro_lanzado
	objetivo = id_objetivo


## Fuente del piso de condición que deja mientras dura.
func clave() -> StringName:
	return StringName("%s:%s" % [lanzador, conjuro.id])

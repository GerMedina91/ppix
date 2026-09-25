class_name EfectoCondicion
extends RefCounted
## Una aplicación de una condición con valor sobre un combatiente, con su duración (Player Core p. 442:
## si la misma condición llega varias veces, cuenta el valor más alto y cada duración se sigue aparte).

var tipo: Condiciones.Tipo
var valor: int = 1
## CD del efecto que la causó (p. ej. la salvación de Arcadas contra el indispuesto).
var cd: int = 0
## Quién la causó (huyendo: de quién huye).
var fuente: StringName = &""
## Combatiente en cuyo turno corre la duración (vacío: sin duración, dura hasta que algo la quite).
var vence_con: StringName = &""
## true: descuenta al inicio del turno de `vence_con` (duraciones en rondas, "hasta el inicio de tu
## próximo turno"); false: al final ("hasta el final de su próximo turno").
var vence_al_inicio: bool = true
## Turnos de `vence_con` que faltan para que termine.
var turnos_restantes: int = 0


func _init(tipo_condicion: Condiciones.Tipo, valor_condicion: int = 1, cd_efecto: int = 0, fuente_efecto: StringName = &"") -> void:
	tipo = tipo_condicion
	valor = valor_condicion
	cd = cd_efecto
	fuente = fuente_efecto


## Dura `turnos` turnos de `id_combatiente`, descontando al inicio (true) o al final (false) de cada uno.
func con_duracion(id_combatiente: StringName, turnos: int, al_inicio: bool = true) -> EfectoCondicion:
	vence_con = id_combatiente
	turnos_restantes = turnos
	vence_al_inicio = al_inicio
	return self


func tiene_duracion() -> bool:
	return vence_con != &""

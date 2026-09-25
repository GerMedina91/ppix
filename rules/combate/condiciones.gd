class_name Condiciones
extends RefCounted
## Condiciones de un combatiente. Las reglas que las modifican están en Combatiente
## (recibir daño, curar, prueba de recuperación) y en Combate (turnos). El flanqueo no se guarda acá:
## se calcula en cada ataque, porque solo deja desprevenido frente a quienes flanquean (ver Flanqueo).
## Condiciones con valor (verificadas en docs/verificacion/c4_conjuros.md): cada aplicación es un
## EfectoCondicion con su duración; vale la más alta, y una reducción baja todas las de ese tipo.

## Condiciones con valor y duración. HUYENDO no tiene valor (se guarda con valor 1).
enum Tipo { ASUSTADO, INDISPUESTO, DEBILITADO, ATURDIDO, HUYENDO }

## Con este valor de moribundo, el personaje muere.
const MORIBUNDO_MUERTE: int = 4
const _NOMBRES: Dictionary[Tipo, String] = {
	Tipo.ASUSTADO: "asustado", Tipo.INDISPUESTO: "indispuesto", Tipo.DEBILITADO: "debilitado",
	Tipo.ATURDIDO: "aturdido", Tipo.HUYENDO: "huyendo",
}

var moribundo: int = 0
var herido: int = 0
var inconsciente: bool = false
var muerto: bool = false
## Desprevenido frente a todos (por otros efectos; el flanqueo va aparte).
var desprevenido: bool = false
var _efectos: Array[EfectoCondicion] = []
## Tipo -> {fuente: valor mínimo}: efectos que no dejan bajar la condición de ese valor mientras duran
## (p. ej. Mal de ojo con el indispuesto).
var _pisos: Dictionary[Tipo, Dictionary] = {}


static func nombre(tipo: Tipo) -> String:
	return _NOMBRES[tipo]


## En pie: consciente y vivo (puede ser objetivo de rematar, cuenta para la derrota, etc.).
func en_pie() -> bool:
	return not inconsciente and not muerto


## Puede usar acciones y reacciones: en pie y sin aturdido.
func puede_actuar() -> bool:
	return en_pie() and valor(Tipo.ATURDIDO) == 0


func fuera_de_combate() -> bool:
	return inconsciente or muerto


func aplicar(efecto: EfectoCondicion) -> void:
	if efecto.valor > 0:
		_efectos.append(efecto)


## Valor actual: el más alto entre sus aplicaciones (0 si no la tiene).
func valor(tipo: Tipo) -> int:
	var mayor: int = 0
	for efecto: EfectoCondicion in _efectos:
		if efecto.tipo == tipo:
			mayor = maxi(mayor, efecto.valor)
	return mayor


func tiene(tipo: Tipo) -> bool:
	return valor(tipo) > 0


## Efecto con el valor más alto de ese tipo (null si no la tiene): de ahí salen la CD y la fuente.
func principal(tipo: Tipo) -> EfectoCondicion:
	var elegido: EfectoCondicion = null
	for efecto: EfectoCondicion in _efectos:
		if efecto.tipo == tipo and (elegido == null or efecto.valor > elegido.valor):
			elegido = efecto
	return elegido


## Baja el valor de todas las aplicaciones de `tipo` en `cantidad`, sin pasar del piso vigente.
func reducir(tipo: Tipo, cantidad: int) -> void:
	var minimo: int = piso(tipo)
	for efecto: EfectoCondicion in _efectos:
		if efecto.tipo == tipo:
			efecto.valor = maxi(efecto.valor - cantidad, mini(minimo, efecto.valor))
	_limpiar()


## Quita la condición por completo (todas sus aplicaciones).
func quitar(tipo: Tipo) -> void:
	_efectos.assign(_efectos.filter(func(e: EfectoCondicion) -> bool: return e.tipo != tipo))


func fijar_piso(tipo: Tipo, fuente: StringName, minimo: int) -> void:
	if not _pisos.has(tipo):
		_pisos[tipo] = {}
	_pisos[tipo][fuente] = minimo


func quitar_piso(tipo: Tipo, fuente: StringName) -> void:
	if _pisos.has(tipo):
		_pisos[tipo].erase(fuente)


func piso(tipo: Tipo) -> int:
	var minimo: int = 0
	for valor_piso: int in _pisos.get(tipo, {}).values():
		minimo = maxi(minimo, valor_piso)
	return minimo


## Descuenta un turno de `id_combatiente` en las duraciones que corren en él (al inicio o al final
## de su turno, según cada efecto) y quita las que terminan.
func descontar_turno(id_combatiente: StringName, al_inicio: bool) -> void:
	for efecto: EfectoCondicion in _efectos:
		if efecto.tiene_duracion() and efecto.vence_con == id_combatiente and efecto.vence_al_inicio == al_inicio:
			efecto.turnos_restantes -= 1
			if efecto.turnos_restantes <= 0:
				efecto.valor = 0
	_limpiar()


## Valores actuales de todas las condiciones con valor (para comparar antes y después y avisar cambios).
func valores() -> Dictionary[Tipo, int]:
	var resultado: Dictionary[Tipo, int] = {}
	for tipo: Tipo in Tipo.values():
		resultado[tipo] = valor(tipo)
	return resultado


func _limpiar() -> void:
	_efectos.assign(_efectos.filter(func(e: EfectoCondicion) -> bool: return e.valor > 0))

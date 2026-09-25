class_name DisparoReaccion
extends RefCounted
## Situación que puede disparar reacciones (Player Core; verificado en docs/verificacion/c3_reacciones.md).
## - SALE_DE_CASILLA: `actor` va a salir de `celda` durante una acción de movimiento (el Paso no dispara).
## - ATAQUE_A_DISTANCIA: `actor` va a hacer un ataque a distancia.
## - OBJETIVO_DE_ATAQUE: `actor` va a atacar a `objetivo` (antes de la tirada).
## Una reacción puede sumar bonificadores a la CA del objetivo para este ataque (Esquiva ágil).

enum Tipo { SALE_DE_CASILLA, ATAQUE_A_DISTANCIA, OBJETIVO_DE_ATAQUE }

var tipo: Tipo
var actor: Combatiente
var celda: Vector2i
var objetivo: Combatiente
var arma: DefinicionArma
var bonificadores_ca: Array[Modificador] = []


static func sale_de_casilla(quien: Combatiente, casilla: Vector2i) -> DisparoReaccion:
	var d: DisparoReaccion = DisparoReaccion.new()
	d.tipo = Tipo.SALE_DE_CASILLA
	d.actor = quien
	d.celda = casilla
	return d


static func ataque_a_distancia(quien: Combatiente, arma_usada: DefinicionArma) -> DisparoReaccion:
	var d: DisparoReaccion = DisparoReaccion.new()
	d.tipo = Tipo.ATAQUE_A_DISTANCIA
	d.actor = quien
	d.celda = quien.celda
	d.arma = arma_usada
	return d


static func objetivo_de_ataque(quien: Combatiente, atacado: Combatiente, arma_usada: DefinicionArma) -> DisparoReaccion:
	var d: DisparoReaccion = DisparoReaccion.new()
	d.tipo = Tipo.OBJETIVO_DE_ATAQUE
	d.actor = quien
	d.celda = quien.celda
	d.objetivo = atacado
	d.arma = arma_usada
	return d

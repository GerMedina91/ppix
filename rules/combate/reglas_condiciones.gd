class_name ReglasCondiciones
extends RefCounted
## Lo que hacen las condiciones con valor en el flujo del combate (docs/verificacion/c4_conjuros.md).
## Combate las llama; acá no se guarda estado.
## - Inicio del turno de X: corren las duraciones que descuentan al inicio del turno de X (rondas,
##   "hasta el inicio de tu próximo turno"); X pierde acciones por aturdido.
## - Fin del turno de X: asustado de X baja 1; corren las duraciones que descuentan al final del turno de X.
## - Arcadas: 1 acción, salvación de Fortaleza contra la CD del indispuesto; éxito -1, éxito crítico -2.
## - Huyendo (simplificado, decisión de diseño): solo Zancadas y Pasos que terminan más lejos de la fuente.

const _REDUCCION_ARCADAS: Dictionary[GradoExito.Grado, int] = {
	GradoExito.Grado.EXITO_CRITICO: 2,
	GradoExito.Grado.EXITO: 1,
	GradoExito.Grado.FALLO: 0,
	GradoExito.Grado.FALLO_CRITICO: 0,
}


static func inicio_de_turno(combate: Combate, actor: Combatiente) -> Array[EventoCombate]:
	var antes: Dictionary = _valores(combate)
	for c: Combatiente in combate.participantes:
		c.condiciones.descontar_turno(actor.id, true)
	var perdidas: int = mini(actor.condiciones.valor(Condiciones.Tipo.ATURDIDO), actor.acciones_restantes)
	var eventos: Array[EventoCombate] = []
	if perdidas > 0:
		actor.acciones_restantes -= perdidas
		actor.condiciones.reducir(Condiciones.Tipo.ATURDIDO, perdidas)
		eventos.append(combate.emitir(EventoCombate.new(EventoCombate.Tipo.ACCIONES_PERDIDAS, actor.id,
			{"cantidad": perdidas, "condicion": Condiciones.Tipo.ATURDIDO})))
	eventos.append_array(_cambios(combate, antes))
	return eventos


static func fin_de_turno(combate: Combate, actor: Combatiente) -> Array[EventoCombate]:
	var antes: Dictionary = _valores(combate)
	actor.terminar_turno()
	actor.condiciones.reducir(Condiciones.Tipo.ASUSTADO, 1)
	for c: Combatiente in combate.participantes:
		c.condiciones.descontar_turno(actor.id, false)
	return _cambios(combate, antes)


## Resuelve Arcadas (la acción ya se validó y se pagó).
static func arcadas(combate: Combate, actor: Combatiente, dados: Dados) -> Array[EventoCombate]:
	var efecto: EfectoCondicion = actor.condiciones.principal(Condiciones.Tipo.INDISPUESTO)
	var anterior: int = actor.condiciones.valor(Condiciones.Tipo.INDISPUESTO)
	var resultado: ResultadoPrueba = actor.prueba_salvacion(Estadisticas.Salvacion.FORTALEZA).resolver(dados, efecto.cd)
	actor.condiciones.reducir(Condiciones.Tipo.INDISPUESTO, _REDUCCION_ARCADAS[resultado.grado])
	return [combate.emitir(EventoCombate.new(EventoCombate.Tipo.ARCADAS, actor.id,
		{"resultado": resultado, "anterior": anterior, "valor": actor.condiciones.valor(Condiciones.Tipo.INDISPUESTO)}))]


## De quién huye `actor` (null si no huye o si la fuente ya no está en el combate).
static func fuente_de_huida(combate: Combate, actor: Combatiente) -> Combatiente:
	var efecto: EfectoCondicion = actor.condiciones.principal(Condiciones.Tipo.HUYENDO)
	if efecto == null:
		return null
	var fuente: Combatiente = combate.combatiente(efecto.fuente)
	return fuente if fuente != null and not fuente.condiciones.muerto else null


## true si `actor` puede terminar un movimiento en `destino` (siempre, salvo que huya y no se aleje).
static func movimiento_permitido(combate: Combate, actor: Combatiente, desde: Vector2i, destino: Vector2i) -> bool:
	var fuente: Combatiente = fuente_de_huida(combate, actor)
	return fuente == null or Medicion.pies_entre(destino, fuente.celda) > Medicion.pies_entre(desde, fuente.celda)


## Valores de condiciones de todos (para cambios_desde()).
static func valores(combate: Combate) -> Dictionary:
	return _valores(combate)


## Eventos CONDICION de lo que cambió desde `antes` (sacado con valores()).
static func cambios_desde(combate: Combate, antes: Dictionary) -> Array[EventoCombate]:
	return _cambios(combate, antes)


static func _valores(combate: Combate) -> Dictionary:
	var valores: Dictionary = {}
	for c: Combatiente in combate.participantes:
		valores[c.id] = c.condiciones.valores()
	return valores


## Un evento CONDICION por cada condición que cambió de valor desde `antes`.
static func _cambios(combate: Combate, antes: Dictionary) -> Array[EventoCombate]:
	var eventos: Array[EventoCombate] = []
	for c: Combatiente in combate.participantes:
		var ahora: Dictionary[Condiciones.Tipo, int] = c.condiciones.valores()
		for tipo: Condiciones.Tipo in ahora:
			if ahora[tipo] != antes[c.id][tipo]:
				eventos.append(combate.emitir(EventoCombate.new(EventoCombate.Tipo.CONDICION, c.id,
					{"condicion": tipo, "valor": ahora[tipo], "anterior": antes[c.id][tipo]})))
	return eventos

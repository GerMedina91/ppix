class_name EfectosConjuro
extends RefCounted
## Efecto de un conjuro sobre una criatura, ya pagado y sin interrumpir (docs/verificacion/c4_conjuros.md).
## Lo usa AccionesConjuro; sin estado.
## - Ataque de conjuro (defensa CA): ataque de conjuro + penalizador por ataque múltiple contra la CA (con
##   los bonificadores de reacciones como Esquiva ágil); éxito, daño; crítico, doble.
## - Salvación contra la CD de conjuro: condiciones según el grado; con salvación básica, el daño es
##   0 / mitad (redondeando hacia abajo, mínimo 1) / completo / doble (Player Core p. 404 y 407).
## - Estabilizar: pierde moribundo (herido +1) y sigue inconsciente a 0 PG.
## El daño no letal deja inconsciente en vez de matar (Player Core p. 407).

const _MULTIPLICADOR_BASICA: Dictionary[GradoExito.Grado, float] = {
	GradoExito.Grado.EXITO_CRITICO: 0.0,
	GradoExito.Grado.EXITO: 0.5,
	GradoExito.Grado.FALLO: 1.0,
	GradoExito.Grado.FALLO_CRITICO: 2.0,
}


## Resuelve y devuelve {"eventos": Array[EventoCombate], "aplicadas": cantidad de condiciones aplicadas}.
static func sobre_criatura(combate: Combate, actor: Combatiente, conjuro: DefinicionConjuro, objetivo: Combatiente,
		bonificadores_ca: Array[Modificador]) -> Dictionary:
	var antes: Dictionary = ReglasCondiciones.valores(combate)
	var estaba_en_pie: bool = objetivo.condiciones.en_pie()
	var datos: Dictionary = {"conjuro": conjuro, "objetivo": objetivo.id, "resultado": null, "danio": 0, "tirada": null}
	var aplicadas: int = 0
	if conjuro.estabiliza:
		objetivo.estabilizar()
	elif conjuro.es_ataque():
		_ataque(combate, actor, conjuro, objetivo, bonificadores_ca, datos)
	elif conjuro.pide_salvacion():
		aplicadas = _salvacion(combate, actor, conjuro, objetivo, datos)
	var eventos: Array[EventoCombate] = [combate.emitir(EventoCombate.new(EventoCombate.Tipo.EFECTO_CONJURO, actor.id, datos))]
	eventos.append_array(ReglasCondiciones.cambios_desde(combate, antes))
	eventos.append_array(combate.eventos_de_estado(objetivo, estaba_en_pie))
	eventos.append_array(combate.verificar_fin())
	return {"eventos": eventos, "aplicadas": aplicadas}


static func _ataque(combate: Combate, actor: Combatiente, conjuro: DefinicionConjuro, objetivo: Combatiente,
		bonificadores_ca: Array[Modificador], datos: Dictionary) -> void:
	var prueba: Prueba = actor.prueba_conjuro()
	prueba.nombre = "Ataque de conjuro (%s)" % conjuro.nombre
	var pam: int = Golpe.PENALIZADORES_ATAQUE_MULTIPLE[mini(actor.ataques_en_turno, Golpe.PENALIZADORES_ATAQUE_MULTIPLE.size() - 1)]
	if pam != 0:
		prueba.modificadores.append(Modificador.new(pam, Modificador.Tipo.SIN_TIPO, "ataque múltiple"))
	var defensa: Prueba = objetivo.defensa_contra(false)
	defensa.modificadores.append_array(bonificadores_ca)
	var resultado: ResultadoPrueba = prueba.resolver(combate.dados(), defensa.cd())
	actor.ataques_en_turno += 1
	datos.resultado = resultado
	if resultado.grado == GradoExito.Grado.EXITO or resultado.grado == GradoExito.Grado.EXITO_CRITICO:
		var critico: bool = resultado.grado == GradoExito.Grado.EXITO_CRITICO
		_daniar(combate, conjuro, objetivo, Golpe.MULTIPLICADOR_CRITICO if critico else 1, critico, datos)


static func _salvacion(combate: Combate, actor: Combatiente, conjuro: DefinicionConjuro, objetivo: Combatiente, datos: Dictionary) -> int:
	var resultado: ResultadoPrueba = objetivo.prueba_salvacion(conjuro.salvacion()).resolver(combate.dados(), actor.prueba_conjuro().cd())
	datos.resultado = resultado
	if conjuro.hace_danio() and conjuro.salvacion_basica:
		_daniar(combate, conjuro, objetivo, _MULTIPLICADOR_BASICA[resultado.grado],
			resultado.grado == GradoExito.Grado.FALLO_CRITICO, datos)
	var aplicadas: int = 0
	for efecto: EfectoPorGrado in conjuro.efectos_de(resultado.grado):
		var condicion: EfectoCondicion = EfectoCondicion.new(efecto.condicion, efecto.valor, resultado.cd, actor.id)
		if efecto.rondas > 0:
			condicion.con_duracion(actor.id, efecto.rondas, true)
		objetivo.condiciones.aplicar(condicion)
		aplicadas += 1
	return aplicadas


## Tira el daño y lo aplica con el multiplicador (0 = sin daño). `por_critico`: crítico del atacante o
## fallo crítico propio (sube moribundo en 2).
static func _daniar(combate: Combate, conjuro: DefinicionConjuro, objetivo: Combatiente, multiplicador: float,
		por_critico: bool, datos: Dictionary) -> void:
	if multiplicador <= 0.0:
		return
	var tirada: ResultadoTirada = conjuro.tirada_danio().tirar(combate.dados())
	var base: int = maxi(Golpe.DANIO_MINIMO, tirada.total())
	var danio: int = maxi(Golpe.DANIO_MINIMO, floori(base * multiplicador))
	datos.tirada = tirada
	datos.danio = danio
	objetivo.recibir_danio(danio, por_critico, conjuro.tiene(DefinicionConjuro.Rasgo.NO_LETAL))

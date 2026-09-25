class_name Golpe
extends RefCounted
## Golpe (Strike) de PF2e: prueba de ataque contra la CA del objetivo.
## - Penalizador por ataque múltiple (sin tipo): -5 / -10, o -4 / -8 con armas ágiles.
## - A distancia: -2 (sin tipo) por cada incremento de rango más allá del primero; hasta 6 incrementos.
## - Flanqueo: el objetivo queda desprevenido (-2 por circunstancia) solo frente a quien lo flanquea.
## - Daño: dados + bonificador (mínimo 1 si impacta); éxito crítico, el doble.
## El costo en acciones lo maneja Combate.

enum Motivo { VALIDO, SIN_ARMA, OBJETIVO_ALIADO, OBJETIVO_MUERTO, FUERA_DE_ALCANCE, SIN_LINEA_DE_VISION, SIN_ACCIONES }

## Texto para mostrar al jugador por qué no se puede hacer el Golpe.
const _TEXTO_MOTIVO: Dictionary[Motivo, String] = {
	Motivo.VALIDO: "",
	Motivo.SIN_ARMA: "sin arma",
	Motivo.OBJETIVO_ALIADO: "es un aliado",
	Motivo.OBJETIVO_MUERTO: "ya está muerto",
	Motivo.FUERA_DE_ALCANCE: "fuera de alcance",
	Motivo.SIN_LINEA_DE_VISION: "sin línea de visión",
	Motivo.SIN_ACCIONES: "sin acciones",
}

const PENALIZADORES_ATAQUE_MULTIPLE: Array[int] = [0, -5, -10]
const PENALIZADORES_ATAQUE_MULTIPLE_AGIL: Array[int] = [0, -4, -8]
const PENALIZADOR_POR_INCREMENTO: int = -2
const INCREMENTOS_MAXIMOS: int = 6
const DANIO_MINIMO: int = 1
const MULTIPLICADOR_CRITICO: int = 2


static func texto_motivo(motivo: Motivo) -> String:
	return _TEXTO_MOTIVO[motivo]


static func penalizador_ataque_multiple(arma: DefinicionArma, ataques_previos: int) -> int:
	var tabla: Array[int] = PENALIZADORES_ATAQUE_MULTIPLE_AGIL if arma.agil else PENALIZADORES_ATAQUE_MULTIPLE
	return tabla[mini(ataques_previos, tabla.size() - 1)]


## Incrementos de rango por encima del primero a esa distancia (0 si es cuerpo a cuerpo).
static func incrementos_extra(arma: DefinicionArma, distancia_pies: int) -> int:
	if not arma.a_distancia:
		return 0
	return maxi(0, ceili(float(distancia_pies) / arma.incremento_rango_pies) - 1)


static func validar(atacante: Combatiente, objetivo: Combatiente, arma: DefinicionArma, vision: LineaVision) -> Motivo:
	if arma == null:
		return Motivo.SIN_ARMA
	if objetivo.es_aliado_de(atacante):
		return Motivo.OBJETIVO_ALIADO
	if objetivo.condiciones.muerto:
		return Motivo.OBJETIVO_MUERTO
	if arma.a_distancia:
		var distancia: int = Medicion.pies_entre(atacante.celda, objetivo.celda)
		if distancia > arma.incremento_rango_pies * INCREMENTOS_MAXIMOS:
			return Motivo.FUERA_DE_ALCANCE
	elif not Medicion.en_alcance(atacante.celda, objetivo.celda, arma.alcance_pies):
		return Motivo.FUERA_DE_ALCANCE
	if not vision.hay_linea(atacante.celda, objetivo.celda):
		return Motivo.SIN_LINEA_DE_VISION
	return Motivo.VALIDO


static func resolver(atacante: Combatiente, objetivo: Combatiente, arma: DefinicionArma, dados: Dados,
		participantes: Array[Combatiente], vision: LineaVision) -> ResultadoGolpe:
	var resultado: ResultadoGolpe = ResultadoGolpe.new()
	resultado.motivo = validar(atacante, objetivo, arma, vision)
	if not resultado.es_valido():
		return resultado
	var prueba: Prueba = prueba_de_ataque(atacante, objetivo, arma)
	resultado.flanqueando = Flanqueo.atacante_flanquea(atacante, objetivo, participantes)
	var cd: int = objetivo.defensa_contra(resultado.flanqueando).cd()
	resultado.prueba = prueba.resolver(dados, cd)
	atacante.ataques_en_turno += 1
	var grado: GradoExito.Grado = resultado.prueba.grado
	if grado == GradoExito.Grado.EXITO or grado == GradoExito.Grado.EXITO_CRITICO:
		resultado.critico = grado == GradoExito.Grado.EXITO_CRITICO
		resultado.tirada_danio = arma.tirada_danio(atacante.fuente.bonificador_danio(arma)).tirar(dados)
		resultado.danio = maxi(DANIO_MINIMO, resultado.tirada_danio.total())
		if resultado.critico:
			resultado.danio *= MULTIPLICADOR_CRITICO
		objetivo.recibir_danio(resultado.danio, resultado.critico)
	return resultado


## Prueba de ataque con el penalizador por ataque múltiple y el de rango ya aplicados (para previsualizar).
static func prueba_de_ataque(atacante: Combatiente, objetivo: Combatiente, arma: DefinicionArma) -> Prueba:
	var prueba: Prueba = atacante.fuente.prueba_ataque(arma)
	var pam: int = penalizador_ataque_multiple(arma, atacante.ataques_en_turno)
	if pam != 0:
		prueba.modificadores.append(Modificador.new(pam, Modificador.Tipo.SIN_TIPO, "ataque múltiple"))
	var extra: int = incrementos_extra(arma, Medicion.pies_entre(atacante.celda, objetivo.celda))
	if extra > 0:
		prueba.modificadores.append(Modificador.new(PENALIZADOR_POR_INCREMENTO * extra, Modificador.Tipo.SIN_TIPO, "incremento de rango"))
	return prueba

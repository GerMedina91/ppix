class_name AjusteDanio
extends RefCounted
## Debilidades y resistencias por tipo de daño (Player Core p. 408; docs/verificacion/m5_criaturas.md): primero se
## suma la debilidad y después se resta la resistencia, hasta un mínimo de 0 de daño.
## Versátil (Player Core p. 283): el atacante elige el tipo de daño en cada ataque; se toma el que más daño hace
## contra ese objetivo (lo que elegiría el jugador) y, si da igual, el tipo principal del arma.


## Aplica debilidad y resistencia a `danio` de ese tipo. Devuelve {"danio": el que se recibe, "debilidad": lo que
## se sumó, "resistencia": lo que se restó (nunca más que el daño)}.
static func aplicar(objetivo: FuenteEstadisticas, tipo: DefinicionArma.TipoDanio, danio: int) -> Dictionary:
	var debilidad: int = objetivo.debilidad(tipo)
	var con_debilidad: int = danio + debilidad
	var resistencia: int = mini(objetivo.resistencia(tipo), con_debilidad)
	return {"danio": con_debilidad - resistencia, "debilidad": debilidad, "resistencia": resistencia}


## Tipo de daño con que `arma` golpea a `objetivo`.
static func tipo_de_golpe(arma: DefinicionArma, objetivo: FuenteEstadisticas) -> DefinicionArma.TipoDanio:
	if arma.versatil and _neto(objetivo, arma.tipo_versatil) > _neto(objetivo, arma.tipo_danio):
		return arma.tipo_versatil
	return arma.tipo_danio


static func _neto(objetivo: FuenteEstadisticas, tipo: DefinicionArma.TipoDanio) -> int:
	return objetivo.debilidad(tipo) - objetivo.resistencia(tipo)

class_name FuenteCriatura
extends FuenteEstadisticas
## Números directos de un DefinicionCriatura.

const _NOMBRE_SALVACION: Dictionary[Estadisticas.Salvacion, String] = {
	Estadisticas.Salvacion.FORTALEZA: "Fortaleza",
	Estadisticas.Salvacion.REFLEJOS: "Reflejos",
	Estadisticas.Salvacion.VOLUNTAD: "Voluntad",
}

var _criatura: DefinicionCriatura


func _init(criatura: DefinicionCriatura) -> void:
	_criatura = criatura


func nombre() -> String:
	return _criatura.nombre


func nivel() -> int:
	return _criatura.nivel


func pg_maximos() -> int:
	return _criatura.pg


func velocidad_pies() -> int:
	return _criatura.velocidad_pies


func armas() -> Array[DefinicionArma]:
	return _criatura.armas


func prueba_ataque(arma: DefinicionArma) -> Prueba:
	return Prueba.fija("Golpe (%s)" % arma.nombre, "bonificador de ataque", _criatura.bonificador_ataque)


func bonificador_danio(_arma: DefinicionArma) -> int:
	return _criatura.bonificador_danio


func remata_caidos() -> bool:
	return _criatura.remata_caidos


func defensa() -> Prueba:
	return Prueba.fija("CA", "CA de la criatura", _criatura.ca - Prueba.BASE_CD)


func prueba_percepcion() -> Prueba:
	return Prueba.fija("Percepción", "Percepción", _criatura.percepcion)


func prueba_salvacion(salvacion: Estadisticas.Salvacion) -> Prueba:
	var valor: int = _criatura.fortaleza
	if salvacion == Estadisticas.Salvacion.REFLEJOS:
		valor = _criatura.reflejos
	elif salvacion == Estadisticas.Salvacion.VOLUNTAD:
		valor = _criatura.voluntad
	return Prueba.fija(_NOMBRE_SALVACION[salvacion], _NOMBRE_SALVACION[salvacion], valor)

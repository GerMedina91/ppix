class_name FuentePersonaje
extends FuenteEstadisticas
## Números de un DefinicionPersonaje, calculados con Estadisticas.

var _personaje: DefinicionPersonaje


func _init(personaje: DefinicionPersonaje) -> void:
	_personaje = personaje


func nombre() -> String:
	return _personaje.nombre


func nivel() -> int:
	return _personaje.nivel


func pg_maximos() -> int:
	return Estadisticas.pg_maximos(_personaje)


func velocidad_pies() -> int:
	return Estadisticas.velocidad(_personaje)


func armas() -> Array[DefinicionArma]:
	return _personaje.armas


func prueba_ataque(arma: DefinicionArma) -> Prueba:
	return Estadisticas.prueba_ataque(_personaje, arma)


func bonificador_danio(arma: DefinicionArma) -> int:
	return Estadisticas.bonificador_danio(_personaje, arma)


func defensa() -> Prueba:
	return Estadisticas.defensa(_personaje)


func prueba_percepcion() -> Prueba:
	return Estadisticas.prueba_percepcion(_personaje)


func prueba_salvacion(salvacion: Estadisticas.Salvacion) -> Prueba:
	return Estadisticas.prueba_salvacion(_personaje, salvacion)


func prueba_habilidad(habilidad: Habilidad.Tipo) -> Prueba:
	return Estadisticas.prueba_habilidad(_personaje, habilidad)


func usa_reglas_de_moribundo() -> bool:
	return true

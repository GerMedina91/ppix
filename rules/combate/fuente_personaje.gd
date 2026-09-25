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


func ataque_con_fuerza(arma: DefinicionArma) -> bool:
	return Estadisticas.atributo_de_ataque(_personaje, arma) == Atributo.Tipo.FUERZA


func danio_con_fuerza(arma: DefinicionArma) -> bool:
	return Estadisticas.danio_con_fuerza(_personaje, arma)


func prueba_conjuro() -> Prueba:
	return Estadisticas.prueba_conjuro(_personaje)


func trucos() -> Array[DefinicionConjuro]:
	return _personaje.trucos


func conjuros_preparados() -> Array[DefinicionConjuro]:
	return _personaje.conjuros_preparados


func conjuros_foco() -> Array[DefinicionConjuro]:
	return _personaje.conjuros_foco


func defensa() -> Prueba:
	return Estadisticas.defensa(_personaje)


func prueba_percepcion() -> Prueba:
	return Estadisticas.prueba_percepcion(_personaje)


func prueba_salvacion(salvacion: Estadisticas.Salvacion) -> Prueba:
	return Estadisticas.prueba_salvacion(_personaje, salvacion)


func capacidades() -> Array[Capacidad]:
	return _personaje.capacidades


func prueba_habilidad(habilidad: Habilidad.Tipo) -> Prueba:
	return Estadisticas.prueba_habilidad(_personaje, habilidad)


func usa_reglas_de_moribundo() -> bool:
	return true

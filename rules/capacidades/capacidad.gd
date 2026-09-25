class_name Capacidad
extends Resource
## Capacidad de clase o subclase (ataque furtivo, Destreza al daño, a futuro reacciones...).
## Las reglas la consultan en puntos de enganche; cada capacidad concreta sobreescribe los que usa.
## Así Golpe y Combate no tienen clases escritas a mano.

@export var id: StringName = &""
@export var nombre: String = ""


## Atributo que suma al daño de un Golpe con `arma` (null = el que corresponda sin esta capacidad).
func atributo_de_danio(_personaje: DefinicionPersonaje, _arma: DefinicionArma) -> Variant:
	return null


## Daño adicional de un Golpe que impactó: [{"fuente": String, "tirada": Tirada}]. Se duplica en un crítico.
func danio_adicional(_contexto: ContextoGolpe) -> Array[Dictionary]:
	return []

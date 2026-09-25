class_name CapacidadAtaqueFurtivo
extends Capacidad
## Ataque furtivo del pícaro (Player Core; verificado en docs/verificacion/c1_clases.md):
## +Xd6 de precisión al Golpear a una criatura desprevenida con un arma cuerpo a cuerpo ágil o sutil,
## o con un ataque a distancia. Un arma arrojadiza, además, tiene que ser ágil o sutil (llega con arrojar).

@export var cantidad_dados: int = 1
@export var caras_dado: int = 6


func danio_adicional(contexto: ContextoGolpe) -> Array[Dictionary]:
	if not contexto.objetivo_desprevenido or not arma_califica(contexto.arma):
		return []
	return [{"fuente": nombre, "tirada": Tirada.new(cantidad_dados, caras_dado)}]


static func arma_califica(arma: DefinicionArma) -> bool:
	return arma.a_distancia or arma.agil or arma.sutil

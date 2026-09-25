class_name CapacidadDestrezaAlDanio
extends Capacidad
## Tejemaneje Ladrón (Player Core; verificado): con un arma sutil cuerpo a cuerpo suma Destreza al daño
## en lugar de Fuerza.


func atributo_de_danio(_personaje: DefinicionPersonaje, arma: DefinicionArma) -> Variant:
	if arma.sutil and not arma.a_distancia:
		return Atributo.Tipo.DESTREZA
	return null

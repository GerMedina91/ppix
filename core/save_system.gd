extends Node
## Sistema de guardado. Solo la interfaz: se implementa más adelante (ver GDD 4.3).
##
## Reglas de diseño que tiene que respetar la implementación:
## - Solo se guarda en puntos estables o con el autoguardado al cambiar de mapa.
## - Nunca durante el combate. No hay guardado libre.
## - El estado del mundo es continuo: cargar no "vuelve atrás" en el tiempo.
##   El punto estable define dónde reaparece el Eco al morir, no a qué momento se vuelve.


## Guarda la partida al activar un punto estable y lo registra como punto de reaparición.
func guardar_en_punto_estable(id_punto: StringName) -> void:
	push_warning("SaveSystem.guardar_en_punto_estable: no implementado (%s)" % id_punto)


## Persiste el progreso al cambiar de mapa. No cambia el punto de reaparición.
func autoguardar() -> void:
	push_warning("SaveSystem.autoguardar: no implementado")


## Devuelve el punto estable donde reaparece el Eco al morir.
func id_ultimo_punto_estable() -> StringName:
	return GameState.id_ultimo_punto_estable


## Carga la partida guardada. Devuelve false si no hay partida o falla la carga.
func cargar() -> bool:
	push_warning("SaveSystem.cargar: no implementado")
	return false

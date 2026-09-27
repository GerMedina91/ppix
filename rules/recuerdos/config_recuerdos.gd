class_name ConfigRecuerdos
extends Resource
## Números de la economía de recuerdos (GDD 4.2 y 4.3). Valores reales en data/config/config_recuerdos.tres.

## Capacidad de integrados de destreza: base + por nivel × nivel del Eco (2 + nivel).
@export var capacidad_base: int = 2
@export var capacidad_por_nivel: int = 1
## El Tasador compra al 50 % del valor (acredita eso) y vende al 100 %.
@export var porcentaje_compra: int = 50
@export var porcentaje_venta: int = 100
## Recargo sobre el precio de venta de los recuerdos de un residuo perdido que pasan al Tasador.
@export var recargo_residuo: int = 50
## Stock del Tasador al empezar una partida (GDD 4.2: 3 de destreza, 1 vivencia y un fragmento del Doliente).
@export var stock_inicial_tasador: Array[DefinicionRecuerdo] = []


func capacidad(nivel: int) -> int:
	return capacidad_base + capacidad_por_nivel * nivel

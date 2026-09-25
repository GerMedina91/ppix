class_name DefinicionArmadura
extends Resource
## Armadura: bonificador de objeto a la CA y tope de Destreza.

@export var nombre: String = "TODO_LORE"
## Bonificador de objeto a la CA.
@export var bonificador_ca: int = 0
## Si es false, la armadura no limita la Destreza que se suma a la CA.
@export var tiene_tope_destreza: bool = true
@export var tope_destreza: int = 0

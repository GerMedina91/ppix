class_name ContextoGolpe
extends RefCounted
## Lo que una Capacidad necesita saber de un Golpe para modificarlo.

var atacante: Combatiente
var objetivo: Combatiente
var arma: DefinicionArma
## El objetivo está desprevenido frente a este atacante (por flanqueo, por su condición o inconsciente).
var objetivo_desprevenido: bool = false
var critico: bool = false

class_name Dados
extends RefCounted
## Generador de tiradas con semilla. Es la única fuente de azar de las reglas:
## se pasa a quien necesite tirar, así un combate se reproduce con la misma semilla.

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _init(semilla_inicial: int) -> void:
	_rng.seed = semilla_inicial


## Tira un dado de `caras` caras. Devuelve un valor entre 1 y `caras`.
func tirar(caras: int) -> int:
	assert(caras >= 1, "Dados.tirar: un dado necesita al menos 1 cara (recibió %d)" % caras)
	return _rng.randi_range(1, caras)


func d20() -> int:
	return tirar(20)

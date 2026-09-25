class_name Dados
extends RefCounted
## Generador de tiradas con semilla. Es la única fuente de azar de las reglas:
## se pasa a quien necesite tirar, así un combate se reproduce con la misma semilla.
## El estado se puede guardar y restaurar (para el sistema de guardado).

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _init(semilla_inicial: int) -> void:
	_rng.seed = semilla_inicial


## Tira un dado de `caras` caras. Devuelve un valor entre 1 y `caras`.
func tirar(caras: int) -> int:
	assert(caras >= 1, "Dados.tirar: un dado necesita al menos 1 cara (recibió %d)" % caras)
	return _rng.randi_range(1, caras)


func d20() -> int:
	return tirar(20)


## Tira `cantidad` dados de `caras` caras y devuelve cada resultado.
func tirar_varios(cantidad: int, caras: int) -> Array[int]:
	var resultados: Array[int] = []
	for i in cantidad:
		resultados.append(tirar(caras))
	return resultados


## Estado interno del RNG, para guardarlo. Restaurarlo reproduce exactamente las tiradas siguientes.
func estado() -> int:
	return _rng.state


func restaurar_estado(estado_guardado: int) -> void:
	_rng.state = estado_guardado

class_name ReservaConjuros
extends RefCounted
## Conjuros de un combatiente y lo que le queda para lanzarlos (Player Core; c4_conjuros.md):
## - Trucos: a voluntad.
## - Espacios: cada conjuro preparado ocupa un espacio y se gasta al lanzarlo.
## - Foco: 1 punto por conjuro de foco conocido (máximo 3); cada lanzamiento gasta 1.
## Lo gastado persiste entre combates (EstadoPartyCombate) hasta descansar en un punto estable (C7).

const FOCO_MAXIMO: int = 3

var trucos: Array[DefinicionConjuro] = []
## Un conjuro por espacio, en el orden en que se prepararon.
var espacios: Array[DefinicionConjuro] = []
var usados: Array[bool] = []
var conjuros_foco: Array[DefinicionConjuro] = []
var foco: int = 0


func _init(fuente: FuenteEstadisticas) -> void:
	trucos = fuente.trucos()
	espacios = fuente.conjuros_preparados()
	conjuros_foco = fuente.conjuros_foco()
	restaurar()


func foco_maximo() -> int:
	return mini(conjuros_foco.size(), FOCO_MAXIMO)


func restaurar() -> void:
	usados.resize(espacios.size())
	usados.fill(false)
	foco = foco_maximo()


func es_lanzador() -> bool:
	return not (trucos.is_empty() and espacios.is_empty() and conjuros_foco.is_empty())


## Conjuros que conoce, sin repetir, en orden: trucos, preparados y de foco.
func conocidos() -> Array[DefinicionConjuro]:
	var lista: Array[DefinicionConjuro] = []
	for conjuro: DefinicionConjuro in trucos + espacios + conjuros_foco:
		if not lista.has(conjuro):
			lista.append(conjuro)
	return lista


## true si le queda con qué lanzarlo (truco, un espacio sin usar con ese conjuro o un punto de foco).
func puede_lanzar(conjuro: DefinicionConjuro) -> bool:
	match conjuro.tipo:
		DefinicionConjuro.Tipo.TRUCO:
			return trucos.has(conjuro)
		DefinicionConjuro.Tipo.FOCO:
			return conjuros_foco.has(conjuro) and foco > 0
	return _espacio_libre(conjuro) >= 0


## Gasta lo que cuesta lanzarlo (nada para los trucos). Antes, puede_lanzar().
func gastar(conjuro: DefinicionConjuro) -> void:
	match conjuro.tipo:
		DefinicionConjuro.Tipo.FOCO:
			foco -= 1
		DefinicionConjuro.Tipo.ESPACIO:
			usados[_espacio_libre(conjuro)] = true


## Cuántas veces más se puede lanzar (-1 = a voluntad).
func restantes(conjuro: DefinicionConjuro) -> int:
	match conjuro.tipo:
		DefinicionConjuro.Tipo.TRUCO:
			return -1
		DefinicionConjuro.Tipo.FOCO:
			return foco
	var cantidad: int = 0
	for i in espacios.size():
		if espacios[i] == conjuro and not usados[i]:
			cantidad += 1
	return cantidad


## Lo que persiste entre combates.
func estado() -> Dictionary:
	return {"usados": usados.duplicate(), "foco": foco}


func aplicar_estado(guardado: Dictionary) -> void:
	var guardados: Array = guardado.get("usados", [])
	for i in mini(guardados.size(), usados.size()):
		usados[i] = guardados[i]
	foco = clampi(guardado.get("foco", foco), 0, foco_maximo())


func _espacio_libre(conjuro: DefinicionConjuro) -> int:
	for i in espacios.size():
		if espacios[i] == conjuro and not usados[i]:
			return i
	return -1

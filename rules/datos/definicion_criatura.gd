class_name DefinicionCriatura
extends Resource
## Criatura con números directos (como un bloque de estadísticas), sin atributos ni competencias.
## Las criaturas mueren al llegar a 0 PG (no usan las reglas de moribundo).

@export var nombre: String = "TODO_LORE"
@export_range(-1, 25) var nivel: int = 1

@export_group("Defensas")
@export var ca: int = 10
@export var pg: int = 1
@export var fortaleza: int = 0
@export var reflejos: int = 0
@export var voluntad: int = 0

@export_group("Ofensiva")
@export var percepcion: int = 0
@export var velocidad_pies: int = 25
## Bonificador total de ataque de sus Golpes.
@export var bonificador_ataque: int = 0
## Bonificador fijo que se suma al daño de sus Golpes.
@export var bonificador_danio: int = 0
@export var armas: Array[DefinicionArma] = []

@export_group("Perfil de IA")
## Si es true, también ataca a personajes caídos (inconscientes). Decisión de diseño pendiente;
## por defecto false (GDD, pilar 4: la muerte tiene que sentirse justa).
@export var remata_caidos: bool = false


func errores_de_datos() -> PackedStringArray:
	var errores: PackedStringArray = PackedStringArray()
	if pg < 1:
		errores.append("Criatura %s: necesita al menos 1 PG" % nombre)
	if velocidad_pies < 0 or velocidad_pies % Medicion.PIES_POR_CASILLA != 0:
		errores.append("Criatura %s: la Velocidad tiene que ser múltiplo de 5 pies" % nombre)
	if armas.is_empty():
		errores.append("Criatura %s: necesita al menos un arma para sus Golpes" % nombre)
	for arma: DefinicionArma in armas:
		errores.append_array(arma.errores_de_datos())
	return errores

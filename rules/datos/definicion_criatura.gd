class_name DefinicionCriatura
extends Resource
## Criatura con números directos (como un bloque de estadísticas), sin atributos ni competencias.
## Las criaturas mueren al llegar a 0 PG (no usan las reglas de moribundo), salvo las que quedan inconscientes.

@export var nombre: String = "TODO_LORE"
@export_range(-1, 25) var nivel: int = 1
## Rasgo de tipo (Recordar conocimiento; muerto viviente: Curar lo daña) y rareza.
@export var rasgo: RasgoCriatura.Tipo = RasgoCriatura.Tipo.HUMANOIDE
@export var rareza: RasgoCriatura.Rareza = RasgoCriatura.Rareza.COMUN

@export_group("Defensas")
@export var ca: int = 10
@export var pg: int = 1
@export var fortaleza: int = 0
@export var reflejos: int = 0
@export var voluntad: int = 0
## Debilidades por tipo de daño (Player Core p. 408): se suman una vez al daño de ese tipo.
@export var debilidades: Dictionary[DefinicionArma.TipoDanio, int] = {}
## Resistencias por tipo de daño (Player Core p. 408): se restan después de la debilidad, hasta 0.
@export var resistencias: Dictionary[DefinicionArma.TipoDanio, int] = {}
## A 0 PG queda inconsciente en vez de morir, aunque el daño sea letal (decisión del director para los humanos
## del slice; Player Core p. 410). Otro golpe estando a 0 PG lo mata. No aplica a los muertos vivientes.
@export var inconsciente_a_cero: bool = false
## Inmune a los efectos mentales (sin mente, Player Core p. 458).
@export var inmune_mental: bool = false
## Lento permanente (Player Core p. 446): recupera menos acciones al empezar su turno.
@export var lento: int = 0

## Modificadores totales de habilidad (las que no figuran: +0).
@export var habilidades: Dictionary[Habilidad.Tipo, int] = {}

@export_group("Ofensiva")
@export var percepcion: int = 0
@export var velocidad_pies: int = 25
## Bonificador total de ataque de sus Golpes.
@export var bonificador_ataque: int = 0
## Bonificador fijo que se suma al daño de sus Golpes.
@export var bonificador_danio: int = 0
@export var armas: Array[DefinicionArma] = []
## Acción de miedo (la usa la IA cuando hay a quién asustar); null = no tiene.
@export var accion_miedo: DefinicionAccionMiedo

@export_group("Recuerdos")
## Lo que el Eco puede extraerle si queda inconsciente tras la victoria (GDD 4.2); null = nada.
@export var recuerdo: DefinicionRecuerdo

@export_group("Perfil de IA")
## Si es true, también ataca a personajes caídos (inconscientes). Decidido: depende de cada criatura;
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
	if accion_miedo != null:
		errores.append_array(accion_miedo.errores_de_datos())
	return errores

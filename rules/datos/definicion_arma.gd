class_name DefinicionArma
extends Resource
## Arma: dados de daño, tipo de daño y rasgos básicos. Nombres de prueba: TODO_LORE.

enum TipoDanio { CORTANTE, PERFORANTE, CONTUNDENTE }

const CARAS_VALIDAS: Array[int] = [4, 6, 8, 10, 12]

@export var nombre: String = "TODO_LORE"
@export var cantidad_dados: int = 1
@export var caras_dado: int = 8
@export var tipo_danio: TipoDanio = TipoDanio.CORTANTE

@export_group("Rasgos")
## Ágil: el penalizador por ataque múltiple es -4/-8 en lugar de -5/-10.
@export var agil: bool = false
## Sutil: el ataque puede usar Destreza en lugar de Fuerza.
@export var sutil: bool = false
## A distancia: el ataque usa Destreza, no suma Fuerza al daño y tiene incremento de rango.
@export var a_distancia: bool = false
@export var incremento_rango_pies: int = 0
## Alcance cuerpo a cuerpo (5 pies por defecto; 10 con armas de alcance).
@export var alcance_pies: int = 5


func tirada_danio(bonificador: int) -> Tirada:
	return Tirada.new(cantidad_dados, caras_dado, bonificador)


func errores_de_datos() -> PackedStringArray:
	var errores: PackedStringArray = PackedStringArray()
	if cantidad_dados < 1:
		errores.append("Arma %s: necesita al menos un dado de daño" % nombre)
	if not CARAS_VALIDAS.has(caras_dado):
		errores.append("Arma %s: dado de daño d%d no válido" % [nombre, caras_dado])
	if a_distancia and (incremento_rango_pies <= 0 or incremento_rango_pies % Medicion.PIES_POR_CASILLA != 0):
		errores.append("Arma %s: un arma a distancia necesita un incremento de rango múltiplo de 5 pies" % nombre)
	if not a_distancia and (alcance_pies < Medicion.PIES_POR_CASILLA or alcance_pies % Medicion.PIES_POR_CASILLA != 0):
		errores.append("Arma %s: el alcance tiene que ser múltiplo de 5 pies" % nombre)
	return errores

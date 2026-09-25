class_name DefinicionArma
extends Resource
## Arma: dados y tipo de daño, categoría (para la competencia) y rasgos (Player Core; ver
## docs/verificacion/c1_clases.md). Nombres de las armas de prueba: TODO_LORE.

enum TipoDanio { CORTANTE, PERFORANTE, CONTUNDENTE }
enum Categoria { SIMPLE, MARCIAL, AVANZADA, SIN_ARMAS }

const CARAS_VALIDAS: Array[int] = [4, 6, 8, 10, 12]

## Id estable (p. ej. para la competencia en el arma predilecta de una entidad).
@export var id: StringName = &""
@export var nombre: String = "TODO_LORE"
@export var categoria: Categoria = Categoria.SIMPLE
@export_range(1, 2) var manos: int = 1
@export var cantidad_dados: int = 1
@export var caras_dado: int = 8
@export var tipo_danio: TipoDanio = TipoDanio.CORTANTE

@export_group("Rasgos")
## Ágil: el penalizador por ataque múltiple es -4/-8 en lugar de -5/-10.
@export var agil: bool = false
## Sutil: el ataque puede usar Destreza en lugar de Fuerza.
@export var sutil: bool = false
## Letal: en un crítico suma un dado de estas caras, tirado después de duplicar (0 = sin letal).
@export var letal_caras: int = 0
## Versátil: puede hacer este otro tipo de daño (solo dato por ahora: no hay resistencias).
@export var versatil: bool = false
@export var tipo_versatil: TipoDanio = TipoDanio.CORTANTE
## Arrojadiza: incremento de rango al lanzarla (0 = no se lanza). Solo dato por ahora.
@export var arrojadiza_incremento_pies: int = 0
## A distancia: el ataque usa Destreza, no suma Fuerza al daño y tiene incremento de rango.
@export var a_distancia: bool = false
@export var incremento_rango_pies: int = 0
## Alcance cuerpo a cuerpo (5 pies; 10 con el rasgo alcance).
@export var alcance_pies: int = 5


func tirada_danio(bonificador: int) -> Tirada:
	return Tirada.new(cantidad_dados, caras_dado, bonificador)


func errores_de_datos() -> PackedStringArray:
	var errores: PackedStringArray = PackedStringArray()
	if cantidad_dados < 1:
		errores.append("Arma %s: necesita al menos un dado de daño" % nombre)
	if not CARAS_VALIDAS.has(caras_dado):
		errores.append("Arma %s: dado de daño d%d no válido" % [nombre, caras_dado])
	if letal_caras != 0 and not CARAS_VALIDAS.has(letal_caras):
		errores.append("Arma %s: dado letal d%d no válido" % [nombre, letal_caras])
	if a_distancia and (incremento_rango_pies <= 0 or incremento_rango_pies % Medicion.PIES_POR_CASILLA != 0):
		errores.append("Arma %s: un arma a distancia necesita un incremento de rango múltiplo de 5 pies" % nombre)
	if not a_distancia and (alcance_pies < Medicion.PIES_POR_CASILLA or alcance_pies % Medicion.PIES_POR_CASILLA != 0):
		errores.append("Arma %s: el alcance tiene que ser múltiplo de 5 pies" % nombre)
	return errores

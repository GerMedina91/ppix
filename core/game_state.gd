extends Node
## Estado global de la partida en curso. Es lo que SaveSystem serializa.
## Solo datos: la lógica de reglas vive en res://rules/.

## Mapa donde está la party.
var id_mapa_actual: StringName = &""

## Último punto estable donde se descansó (y guardó). Al morir, el Eco reaparece acá.
var id_ultimo_punto_estable: StringName = &""
## Mapa de ese punto estable.
var id_mapa_ultimo_punto_estable: StringName = &""

## Estado persistente de cada miembro de la party entre combates: id -> {"pg": int, "herido": int}.
## Sin entrada = PG completos y sin herido.
var estado_party: Dictionary[StringName, Dictionary] = {}

## Recuerdos del Eco, el Tasador, el residuo y el destino de los enemigos inconscientes (GDD 4.2 y 4.3).
var recuerdos: EstadoRecuerdos = EstadoRecuerdos.new()

## Sueños que ya se vieron al descansar (no se repiten).
var suenos_vistos: Array[StringName] = []

## RNG centralizado de las reglas. `reiniciar_dados()` fija la semilla (reproducible en tests).
var semilla: int = 0
var dados: Dados = Dados.new(0)


func reiniciar_dados(nueva_semilla: int) -> void:
	semilla = nueva_semilla
	dados = Dados.new(nueva_semilla)


## Datos serializables a JSON (M4g suma el resto: estado de la party y del RNG).
func a_diccionario() -> Dictionary:
	return {
		"punto_estable": {"id": String(id_ultimo_punto_estable), "mapa": String(id_mapa_ultimo_punto_estable)},
		"recuerdos": recuerdos.a_diccionario(),
		"suenos_vistos": suenos_vistos.map(func(id: StringName) -> String: return String(id)),
	}


func cargar_diccionario(datos: Dictionary, catalogo: CatalogoRecuerdos) -> void:
	var punto: Dictionary = datos.get("punto_estable", {})
	id_ultimo_punto_estable = StringName(punto.get("id", ""))
	id_mapa_ultimo_punto_estable = StringName(punto.get("mapa", ""))
	recuerdos = EstadoRecuerdos.desde_diccionario(datos.get("recuerdos", {}), catalogo)
	suenos_vistos.clear()
	for id: Variant in datos.get("suenos_vistos", []):
		suenos_vistos.append(StringName(id))


func _ready() -> void:
	reiniciar_dados(int(Time.get_unix_time_from_system()))

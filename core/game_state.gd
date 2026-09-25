extends Node
## Estado global de la partida en curso. Es lo que SaveSystem serializa.
## Solo datos: la lógica de reglas vive en res://rules/.

## Mapa donde está la party.
var id_mapa_actual: StringName = &""

## Último punto estable donde se guardó. Al morir, el Eco reaparece acá.
var id_ultimo_punto_estable: StringName = &""

## Estado persistente de cada miembro de la party entre combates: id -> {"pg": int, "herido": int}.
## Sin entrada = PG completos y sin herido.
var estado_party: Dictionary[StringName, Dictionary] = {}

## RNG centralizado de las reglas. `reiniciar_dados()` fija la semilla (reproducible en tests).
var semilla: int = 0
var dados: Dados = Dados.new(0)


func reiniciar_dados(nueva_semilla: int) -> void:
	semilla = nueva_semilla
	dados = Dados.new(nueva_semilla)


func _ready() -> void:
	reiniciar_dados(int(Time.get_unix_time_from_system()))

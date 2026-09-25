extends Node
## Estado global de la partida en curso. Es lo que SaveSystem serializa.
## Solo datos: la lógica de reglas vive en res://rules/.

## Mapa donde está la party.
var id_mapa_actual: StringName = &""

## Último punto estable donde se guardó. Al morir, el Eco reaparece acá.
var id_ultimo_punto_estable: StringName = &""

extends Node
## Bus de eventos global. Solo declara señales; no guarda estado ni tiene lógica.
## Los sistemas lejanos se comunican emitiendo y escuchando estas señales.

## Se emite cuando la party termina de entrar a un mapa nuevo (dispara el autoguardado).
signal mapa_cambiado(id_mapa: StringName)

## Se emite cuando un encuentro se dispara (empieza el combate).
signal encuentro_iniciado(id_encuentro: StringName)

## Se emite cuando termina el combate de un encuentro.
signal encuentro_terminado(id_encuentro: StringName, victoria: bool)

## Se emite cuando la party guarda en un punto estable.
signal punto_estable_activado(id_punto: StringName)

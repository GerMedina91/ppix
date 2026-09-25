extends Node
## Bus de eventos global. Solo declara señales; no guarda estado ni tiene lógica.
## Los sistemas lejanos se comunican emitiendo y escuchando estas señales.

## Se emite cuando la party termina de entrar a un mapa nuevo (dispara el autoguardado).
signal mapa_cambiado(id_mapa: StringName)

## Se emite cuando la party guarda en un punto estable.
signal punto_estable_activado(id_punto: StringName)

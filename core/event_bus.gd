extends Node
## Bus de eventos global. Solo declara señales; no guarda estado ni tiene lógica.
## Los sistemas lejanos se comunican emitiendo y escuchando estas señales.

## Se emite cuando la party termina de entrar a un mapa nuevo (dispara el autoguardado).
signal mapa_cambiado(id_mapa: StringName)

## Se emite cuando un encuentro se dispara (empieza el combate).
signal encuentro_iniciado(id_encuentro: StringName)

## Se emite cuando termina el combate de un encuentro.
signal encuentro_terminado(id_encuentro: StringName, victoria: bool)

## Se emite cuando la party descansa en un punto estable (lo registra como reaparición; SaveSystem guarda).
signal punto_estable_activado(id_punto: StringName)

## Se emite cuando el Eco sueña al descansar en un punto estable (contenido TODO_LORE).
signal sueno_en_descanso(id_sueno: StringName)

## Se emite enseguida después de un cambio que no se deshace (SaveSystem autoguarda): compra o venta,
## integrar / soltar / ver, tomar o extraer un recuerdo, destino de un enemigo, rearmado del Eco, fin de combate.
signal cambio_irreversible(motivo: String)

## Lo emite SaveSystem justo antes de escribir: el mundo anota en GameState dónde está la party.
signal antes_de_guardar

class_name ObjetoRecuerdo
extends Interactuable
## Objeto del mapa con un recuerdo (GDD 4.2: fuente "encontrar en el mundo"). Al interactuar, el Eco lo toma
## (suelto) y el objeto desaparece para siempre (GameState.mundo; el nombre del nodo es su id en el mapa).

@export var recuerdo: DefinicionRecuerdo

# Guía: armar un mapa nuevo desde el editor

Todo se hace en el editor de Godot, sin tocar código. Lo que está mal configurado muestra un **triángulo
amarillo** en el árbol de escena; pasando el mouse se lee el aviso. Los mismos avisos los revisa el test
`tests/world/test_mapas_del_catalogo.gd`, así que un mapa roto no llega al juego sin que falle un test.

## 1. Crear el mapa
1. En el panel Sistema de archivos, clic derecho sobre `scenes/world/mapas/plantilla_mapa.tscn` → **Duplicar…**
   y guardalo como `scenes/world/mapas/<id_del_mapa>.tscn` (snake_case). Cambiá el nombre del nodo raíz.
2. Registralo: en `data/mapas/` duplicá un `.tres` existente, poné su **id** (el mismo que vas a usar en las
   salidas) y su **ruta_escena**, y sumalo a la lista `mapas` de `data/mapas/catalogo_mapas.tres`.

La plantilla ya trae los nodos que el juego necesita, con el y-sort configurado:

| Nodo | Para qué |
|---|---|
| `Suelo` | Capa de suelo (se dibuja debajo de todo). |
| `Paredes` | Capa de paredes (se ordena con la party y se vuelve transparente si tapa a alguien). |
| `Entradas` | Dónde aparece la party al llegar. |
| `Salidas` | Casillas que llevan a otro mapa. |
| `Encuentros` | Combates. |
| `Interactuables` | Objetos con recuerdos, puntos estables, el Tasador, disparadores de diálogo. |

## 2. Pintar suelo y paredes
1. Seleccioná `Suelo` y abrí el panel **TileMap** (abajo). Tile set: `assets/placeholder/tileset_iso_placeholder.tres`.
   - Fuente 0: `(0,0)` suelo pisable, `(1,0)` suelo de salida.
2. Seleccioná `Paredes` y pintá encima: fuente 1 = pared alta (se transparenta), fuente 2 = zócalo (bordes que
   dan a la cámara).
3. Una casilla se puede pisar si su suelo tiene `transitable` y no tiene pared encima. Cada casilla es de 5 pies.

## 3. Colocar cosas
Arrastrá la escena desde `scenes/world/objetos/` al nodo que corresponde (o clic derecho en el nodo →
**Instanciar escena hija**). Al soltarla se acomoda sola al centro de su casilla. Se configura en el inspector.

| Escena | Dónde va | Qué configurar |
|---|---|---|
| `entrada.tscn` | `Entradas` | **id** (único en el mapa). Opcional: `formacion` (casillas de la fila, líder primero). |
| `salida.tscn` | `Salidas` | **id_mapa_destino** (del catálogo) e **id_entrada_destino** (una entrada de ese mapa). |
| `encuentro.tscn` | `Encuentros` | **id** (único en el mapa). Su hijo `Zona`: rectángulo de casillas que lo dispara (se ve en rojo sobre el suelo). |
| `enemigo.tscn` | dentro de un encuentro | **definicion** (una criatura de `data/criaturas/`), color del placeholder. |
| `objeto_recuerdo.tscn` | `Interactuables` | **recuerdo** (de `data/recuerdos/`, tiene que estar en el catálogo). El nombre del nodo es su id en el mapa: no lo cambies después de publicar. |
| `punto_estable.tscn` | `Interactuables` | **id** (único en todo el mundo). |
| `tasador.tscn` | `Interactuables` | Nada. |
| `disparador_dialogo.tscn` | `Interactuables` | **dialogo** (archivo `.dialogue` de `dialogue/`), **titulo** donde empieza, **condicion** opcional, **una_vez**. |

Los enemigos, objetos, el Tasador, los puntos estables y los disparadores ocupan su casilla (no se pisan) y se
interactúa con ellos haciendo click: la party camina hasta una casilla vecina.

### Condición de un disparador de diálogo
Una expresión de GDScript sobre `estado`, el contexto de diálogo (se completa en M5-prep b). Vacía = siempre.
Ejemplo: `estado.companero_vivo("Miembro2") and not estado.vio_sueno("sueno_placeholder_1")`.
Si la expresión no es válida, el nodo lo avisa.

## 4. Probar
1. Conectá el mapa: poné una salida en otro mapa con `id_mapa_destino` = tu mapa, y una entrada en el tuyo.
2. Corré los tests rápidos (`pwsh tests/run_tests.ps1 -Rapidos`): el test de mapas revisa todos los del catálogo.
3. Corré el juego (F5) y caminá hasta la salida que lleva a tu mapa.

## Avisos posibles
- *Tiene que estar dentro de un mapa* / *está en la casilla (x, y), que no se puede pisar*.
- *Falta el id* / *el id está repetido en este mapa*.
- *El mapa destino no está en el catálogo* / *el mapa no tiene la entrada*.
- *No tiene enemigos* / *no tiene disparador* / *la zona está vacía* (encuentros).
- *Falta la definición de la criatura* / *tiene que ser hijo de un Encuentro* (enemigos).
- *Falta el recuerdo* / *el recuerdo no está en el catálogo* (objetos).
- *Falta el archivo de diálogo* / *no existe* / *falta el título* / *la condición no es una expresión válida*.

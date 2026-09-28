# Dirección de arte

Decidida por Germán (2026-09-28). Todo el arte del juego sigue siendo placeholder hasta que Germán produzca los
sprites. Complementa `docs/GDD.md` (sección 5) y `CLAUDE.md` (configuración de render).

## Referencias
- **Children of Morta:** penumbra, la luz cálida como refugio.
- **Blasphemous:** gótico, religioso, doloroso.

## Color
- Mundo **desaturado con acentos**, y los acentos tienen significado:
  - **Rampa Lumbre (cálida):** refugio, lo humano, lo seguro.
  - **Rampa Herida (azul frío lechoso):** el otro lado, la Convergencia, la magia ocultista, la Marea del Sueño.
  - **Nada usa la rampa Herida sin motivo.**
- **Paleta "Lumbre" v0.1:** 42 colores, 8 rampas con corrimiento de tono (sombras hacia violeta, luces hacia cálido),
  más negro y blanco. Archivos: `assets/paleta/paleta_lumbre.hex` y `assets/paleta/paleta_lumbre.gpl`.
- **Todo sprite y tile, estrictamente en la paleta.** Lo controla `tests/assets/test_paleta.gd`: recorre los PNG de
  `assets/` (salvo `assets/placeholder/`) y falla si un píxel no transparente usa un color fuera de la paleta,
  informando archivo y color.

| Rampa | Colores (de oscuro a claro) |
|---|---|
| Piedra / sombra | `0b0a0f` `292130` `503b50` `705766` `90767a` `b19e98` `d1cabc` |
| Tierra / madera | `19121f` `442941` `694152` `8e5e5a` `b29874` |
| Monte | `0f141a` `253b3b` `3c5c49` `5b7d54` `929e6f` |
| Piel | `402331` `6a3f4a` `955d5e` `c08e7f` `ebc5a4` |
| Sangre / tela | `291029` `501f41` `772c49` `9e3740` |
| **Lumbre** | `731121` `96352b` `b9744f` `dcb67c` `fff5b3` |
| **Herida** | `2c1947` `363372` `566e9d` `82b3c8` `b6f2ed` |
| Metal / hueso | `43464c` `7b7180` `b29fa4` `e6e2cf` |
| Negro / blanco | `08070c` `f4eee2` |

## Iluminación
- **Luz libre:** las luces 2D del motor tiñen suave por encima y **no se cuantizan** a la paleta.
- Las **Lumbres** emiten luz cálida.
- La oscuridad general se hace con **modulación del canvas**.

## Contorno
- **Selectivo:** oscuro de color (no negro), solo donde el sprite se separa del fondo.

## Personajes
- Semirrealistas, **~5 cabezas**, **~48 px de alto** (el placeholder de 32×56 se ajusta cuando llegue el sprite
  canónico del Eco).
- **4 direcciones isométricas diagonales:** se dibujan 2 (frente-derecha y espalda-derecha) y se espejan.
- **Animaciones del slice:** quieto, caminar, Golpe, recibir daño, caer. Lanzar conjuro, solo para Orven y Vaisha.

## El Eco: costuras de luz
- Grietas donde se unieron los recuerdos, con la luz de la **rampa Herida**. Es el **único personaje** que lleva ese
  color encima.
- **[idea futura, no implementar]** Que brillen más al integrar recuerdos o cerca de la herida.

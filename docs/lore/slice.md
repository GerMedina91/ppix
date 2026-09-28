# SPOILER — estructura del vertical slice

> Documento de referencia para el diseño: para armar los mapas y para una futura sesión de escritura. **No usar
> nada de esto en textos del juego** (diálogos, descripciones, registro, UI) sin pedido explícito del director.
> Aprobado por Germán (2026-09-28). Nombres decididos: Kardel, el Monte de los Idos, las Lumbres. Lo que no
> tenga nombre sigue `TODO_LORE`. No inventar.

**Duración estimada:** 25-30 minutos.

## Las Lumbres (los puntos estables del mundo)
Pequeñas llamas que arden sin nada que quemar y que la Marea del Sueño no puede apagar. Su forma cambia según el
lugar (farol, nicho, piedra); la llama es siempre la misma. En UI y textos: "Lumbre", "descansar en la Lumbre".
En código, la mecánica sigue siendo `PuntoEstable`.

**Lumbres del slice (decidido 2026-09-28):** dos. La de Kardel (el farol de la entrada del camino) y una **al final
del linde, justo antes de la salida al corazón**. Curva resultante: combate 1 → descanso posible → combates 2 y 3
**sin descanso entre medio**. Si el Eco muere en el corazón, reaparece en la Lumbre del linde (si descansó ahí).

## Mapa 1 — Kardel (el pueblo). Sin combate.
- Llegada al anochecer por el camino a Kardel. En la entrada del camino, **la Lumbre del slice: un farol viejo**.
  Primer descanso y **primer sueño de Nalia** (voz todavía ininteligible).
- **El Tasador:** presentación obligatoria; **reconoce a Irsa** (una sola línea, sin explicación). Vende el
  **fragmento 1 del Doliente**.
- **2-3 NPCs** con rumores del Monte: gente que entra buscando a sus muertos y no vuelve (los Deudos, **sin
  nombrarlos**).
- **Un objeto con recuerdo escondido** (premia la exploración).

## Mapa 2 — El linde del Monte (el bosque: el Monte de los Idos).
- **Combate 1: Deudos** (humanos, peregrinos desesperados que van al corazón del Monte a cruzar). **Primera
  decisión con un inconsciente.**
- **La realidad empieza a fallar** (narrativa visual, sin mecánica): sendero que vuelve sobre sí mismo, un árbol
  con una cara que parpadea.
- **La segunda Lumbre**, al final, justo antes de la salida al corazón.

## Mapa 3 — El corazón del Monte, donde la Convergencia tocó la herida.
- **Combate 2:** muertos que no terminan de irse (muertos vivientes).
- **Combate 3 (final):** el líder de los Deudos, que "casi lo logró", con lo que atrajo del otro lado.
- **Fragmento 2 del Doliente** en el centro. Al verlo: visión de una puerta enorme cerrándose y una niña del
  otro lado. Corte a negro. **Fin del slice.**

## Fragmento 3
Lo lleva Irsa: solo se obtiene si muere (ver `companeros.md`).

## En el juego (M5)
Mapas `kardel`, `linde_del_monte` y `corazon_del_monte` (arte placeholder). Encuentros y criaturas en
`docs/verificacion/m5_criaturas.md`; reparto de recuerdos y decisiones en el GDD (M5).

## Para M5 (pedido del director)
- Plan de mapas.
- Encuentros balanceados con el presupuesto del GM Core para una party de 4 de nivel 1: combate 1
  fácil/moderado, combate 2 moderado, combate 3 severo.
- Enemigos del Monster Core verificados en AoN.

# Verificación C5 — Curar, costo variable y emanación

Verificado el 2026-09-27 contra Archives of Nethys (índice oficial, Player Core Remaster). Solo números, reglas
resumidas y referencias.

- **Curar** (*Heal*, rango 1, PC p. 335 · `/Spells.aspx?ID=1554`): 1 a 3 acciones; rasgos curación, manipular y
  vitalidad (+ concentrar con 2 y 3 acciones). Objetivo: 1 ser vivo que acepte o 1 muerto viviente.
  - Ser vivo: recupera 1d8 PG. Muerto viviente: ese daño de vitalidad, con salvación básica de Fortaleza.
  - 1 acción: alcance de toque. 2 acciones: 30 pies, y +8 a la curación de un ser vivo. 3 acciones: emanación de
    30 pies que afecta a todos los seres vivos y muertos vivientes que estén dentro.
- **Fuente divina de curar** (PC p. 108 · `/Classes.aspx?ID=33`): 4 espacios extra del rango más alto, solo para
  Curar (ver `c4_conjuros.md`).
- **Alcance de toque** (PC p. 300 · `/Rules.aspx?ID=2238`): se usa el alcance sin armas (a nivel de casillas: las
  adyacentes, también en diagonal).
- **Emanación** (PC p. 428 · `ID=2387`): sale de cada lado del espacio de quien la crea; esa criatura elige si le
  afecta. **Áreas** (PC p. 428 · `ID=2384`): se miden como el movimiento (diagonales alternadas). **Línea de
  efecto** (PC p. 426 · `ID=2382`): los afectados por un área necesitan línea de efecto al origen.
- **Criaturas que aceptan** (PC p. 426 · `ID=2380`): el jugador decide por sus personajes; por los PNJ decide el DJ.

## Interpretaciones de implementación
- La curación se tira una sola vez y se aplica a todos los afectados del área.
- En la emanación el clérigo se incluye siempre (la elección de excluirse queda para la barra de C6).
- Enemigos: no aceptan una curación con objetivo único; la emanación de 3 acciones sí los cura si están dentro,
  porque afecta a todos los seres vivos.
- La línea de efecto se aproxima con la línea de visión (`LineaVision`).
- Muertos vivientes: `DefinicionCriatura.muerto_viviente` (ninguna criatura del slice lo es todavía).

# Verificación C3 — reacciones

Verificado el 2026-09-25 contra Archives of Nethys (índice oficial, Player Core Remaster). Solo reglas resumidas y referencias.

- **Golpe reactivo** (*Reactive Strike*, PC p. 138 · `/Actions.aspx?ID=2256`), reacción del guerrero de nivel 1.
  Disparador: una criatura a su alcance usa una acción de manipular o de movimiento, hace un ataque a distancia,
  o sale de una casilla durante una acción de movimiento. Efecto: Golpe cuerpo a cuerpo contra ella; si es
  crítico y el disparador fue una acción de manipular, la interrumpe. No cuenta para el penalizador por ataque
  múltiple ni lo sufre.
- **Esquiva ágil** (*Nimble Dodge*, dote de pícaro 1, PC p. 169 · `/Feats.aspx?ID=4916`). Disparador: una criatura
  que puede ver lo elige como objetivo de un ataque. Requisito: no estar impedido (*encumbered*). Efecto: +2 por
  circunstancia a la CA contra ese ataque.
- **Paso** (*Step*, PC p. 418 · `/Actions.aspx?ID=2304`), rasgo movimiento: no dispara reacciones que se disparan
  con acciones de movimiento o al salir o entrar de una casilla.
- **Zancada** (*Stride*, PC p. 418 · `ID=2305`), rasgo movimiento. **Golpe** (*Strike*, PC p. 418 · `ID=2306`), rasgo ataque.

## Interpretaciones de implementación
- "Usa una acción de movimiento" y "sale de una casilla" se evalúan antes de salir de cada casilla de la Zancada
  (incluida la primera): en la práctica, el Golpe reactivo ocurre antes de que se mueva.
- Ante un ataque a distancia, el Golpe reactivo se resuelve antes de la tirada; si el atacante queda fuera de
  combate, el ataque se pierde (la acción ya se gastó).
- Si el que se mueve queda fuera de combate por una reacción, el movimiento se corta en esa casilla.
- Pendiente con C4: disparo por acciones de manipular (lanzar conjuros) e interrupción por crítico.
- Pendiente: el requisito de "no impedido" de la Esquiva ágil (no hay carga todavía).

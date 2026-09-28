# Verificación: cobertura, Tomar cobertura, iniciativa y sorpresa

Verificado el 2026-09-28 contra Archives of Nethys (Player Core y GM Core Remaster).

## Cobertura (PC p. 424 · `/Rules.aspx?ID=2372`)
| Cobertura | Bonificador (circunstancia) | Esconderse |
|---|---|---|
| Menor (típicamente, una criatura) | +1 a la CA | no |
| Normal | +2 a la CA, a Reflejos contra efectos de área y a Sigilo para Esconderse / Escabullirse | sí |
| Mayor | +4 (lo mismo que la normal) | sí |

- Relativa: se puede tener cobertura frente a una criatura y no frente a otra.
- Solo si el camino al objetivo está parcialmente bloqueado; si está entero detrás de una pared, no hay línea de
  efecto y en general no se lo puede elegir.
- Recta del centro de la casilla del atacante al centro de la del objetivo: si pasa por terreno que bloquea,
  **normal** (mayor si la obstrucción es extrema o el objetivo tomó cobertura); si pasa por una criatura, **menor**.
- Contra un área: la recta sale del punto de origen del efecto.
- GM Core p. 28 (`/Rules.aspx?ID=2559`): el DJ decide en los casos complicados.

## Tomar cobertura (PC p. 418 · `/Actions.aspx?ID=2307`)
- 1 acción. Requisito: tener cobertura normal, estar cerca de algo que permita cubrirse o estar tumbado.
- Si tendrías cobertura normal, pasás a mayor (+4); si no, obtenés normal (+2). Tumbado: mayor contra ataques a
  distancia.
- Dura hasta que te movés de tu espacio, usás una acción de ataque, quedás inconsciente o la terminás (acción
  gratuita).

## Iniciativa y sorpresa
- Iniciativa (PC p. 435 · `/Rules.aspx?ID=2423`): marca el inicio del encuentro; casi siempre Percepción; quien
  estaba Evitando ser notado tira Sigilo.
- Iniciativa con Sigilo (GM Core p. 25 · `/Rules.aspx?ID=2541`): quien supera la CD de Percepción de sus enemigos
  queda sin detectar y sin notar por ellos. **No hay ronda de sorpresa en el Remaster**: la emboscada es esto.

## Interpretación para el slice (decisiones del director, 2026-09-28)
- **Línea de visión (A, fiel):** se puede apuntar si algún segmento desde la casilla del atacante (centro o
  esquina) llega a la del objetivo (centro o esquina) sin pasar por pared (ver `LineaVision`). La recta de centro
  a centro decide la cobertura. Reemplaza "línea de efecto = línea de visión centro a centro" de C4.
- Varias fuentes de cobertura: vale la mayor. Las criaturas muertas no dan cobertura.
- "Cerca de algo que permita cubrirse" = una pared (o el borde del mapa) en una casilla vecina en cruz.
- Terminarla a voluntad (acción gratuita) no está en la barra todavía.
- Sin tumbado en el slice; sin efectos de área con Reflejos ni Esconderse: esos bonificadores de la cobertura
  normal y mayor quedan sin uso por ahora.
- **Sin sorpresa en el slice:** no hay Evitar ser notado ni iniciativa con Sigilo; todos tiran Percepción.

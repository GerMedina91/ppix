# Verificación C4 — conjuros

Verificado el 2026-09-25 contra Archives of Nethys (índice oficial, Player Core Remaster). Solo números, reglas
resumidas y referencias; no se copia texto de reglas.

## Lanzamiento y estadísticas
- **Lanzar un conjuro** (*Cast a Spell*, PC p. 299 · `/Actions.aspx?ID=2734`): los trucos, los conjuros de espacio y
  los de foco se lanzan igual; el de espacio gasta el espacio, el de foco gasta 1 punto de foco. Las acciones y
  los rasgos (manipular, concentrar) son los de cada conjuro.
- **Ataque de conjuro** (PC p. 403 · `/Rules.aspx?ID=2292`): atributo clave de la clase + bonificador de competencia;
  sufre el penalizador por ataque múltiple y admite bonificadores de circunstancia y de estatus.
- **CD de conjuro** (PC p. 403 · `ID=2293`): 10 + atributo clave + competencia + bonificadores + penalizadores.
- Competencia a nivel 1: clérigo y bruja, **entrenados** en ataque y CD de conjuro (ver `c1_clases.md`).
- **Salvación básica** (PC p. 404 · `ID=2297`): éxito crítico sin daño, éxito mitad, fallo daño completo, fallo
  crítico doble. Algunos conjuros agregan efectos en ciertos resultados.
- **Trucos**: a voluntad, sin espacio; se potencian solos a la mitad del nivel redondeando hacia arriba (rango 1 a
  nivel 1).
- **Interrumpir** (*Disrupting Actions*, PC p. 415 · `ID=2342`): se gastan las acciones y los costos (espacio,
  punto de foco), pero el efecto no ocurre. Con una actividad de varias acciones se pierden todas.

## Espacios y foco a nivel 1
- **Clérigo** (PC p. 108 · `/Classes.aspx?ID=33`): 2 conjuros de rango 1 y 5 trucos preparados.
- **Fuente divina de curar** (PC p. 108): 4 espacios extra del rango más alto, solo para Curar (5 a nivel 5 y 6 a
  nivel 15).
- **Bruja** (PC p. 178 · `/Classes.aspx?ID=38`): hasta 2 conjuros de rango 1 y 5 trucos preparados, de los que conoce
  el familiar.
- **Conjuros de foco** (PC p. 298 · `/Rules.aspx?ID=2228`): 1 punto de foco por conjuro de foco conocido (máximo 3);
  se potencian como los trucos. Reponer (*Refocus*) devuelve 1 punto en 10 minutos (acá: 1 punto al terminar cada
  combate, decisión de diseño).
- **Iniciado de dominio** (*Domain Initiate*, dote de clérigo 1, PC p. 113 · `/Feats.aspx?ID=4644`): conjuro inicial
  del dominio elegido; reserva de foco de 1 punto.
- **Maleficios de la bruja** (PC p. 178): la bruja empieza con 1 punto de foco y aprende *Patron's Puppet* o *Phase
  Familiar*, los dos atados al familiar (**pospuestos** con el familiar).

## Maleficios y el patrón
- **Rasgo maleficio** (*Hex*, PC p. 183 · `/Traits.aspx?ID=624`): un solo conjuro con el rasgo maleficio por turno; el
  segundo intento **falla automáticamente** (y se pierden las acciones).
- **El Rencor** = *The Resentment* (PC p. 184 · `/Patrons.aspx?ID=14`): lista ocultista, habilidad Ocultismo; da el
  truco de maleficio **Mal de ojo** y el familiar aprende **Debilitar**. El beneficio del familiar (prolongar
  condiciones) se pospone con el familiar.
- **Mal de ojo** (*Evil Eye*, PC p. 386 · `/Spells.aspx?ID=1889`): truco de maleficio, **1 acción**, rasgos maldición,
  maleficio y **manipular** (sin concentrar), 30 pies, 1 criatura, Voluntad, **sostenido hasta 1 minuto**. Fallo:
  indispuesto 1; fallo crítico: indispuesto 2. Mientras esté activo y la bruja vea al objetivo, el indispuesto no
  baja de 1. Sin efecto en éxito ni en éxito crítico.

## Conjuros decididos
- **Debilitar** (*Enfeeble*, rango 1, PC p. 329 · `/Spells.aspx?ID=1513`): **2 acciones**, concentrar y manipular,
  30 pies, 1 criatura, **Fortaleza**. Éxito crítico: nada. Éxito: **debilitado 1** hasta el inicio del próximo turno
  del lanzador. Fallo: **debilitado 2** durante 1 minuto. Fallo crítico: **debilitado 3** durante 1 minuto.
  ⚠ Aplica *enfeebled* (debilitado), **no** indispuesto.
- **Curar** (*Heal*, rango 1, PC p. 335 · `/Spells.aspx?ID=1554`): 1 a 3 acciones, manipular (+ concentrar con 2 y 3).
  1d8 PG a un ser vivo que acepte; a un muerto viviente, daño de vitalidad con salvación básica de Fortaleza.
  1 acción: toque. 2 acciones: 30 pies y +8 a la curación. 3 acciones: emanación de 30 pies que afecta a todos los
  vivos y muertos vivientes. Potenciado (+1): +1d8 y +8 más a la versión de 2 acciones. (C5.)
- **Pies ágiles** (*Agile Feet*, foco del dominio Viaje, PC p. 379 · `/Spells.aspx?ID=1838`): **1 acción**, manipular,
  hasta el final del turno: +5 pies de estatus a la Velocidad e ignora terreno difícil; **como parte del
  lanzamiento** puede dar un Paso, una Zancada o Pasar haciendo acrobacias (*Tumble Through*).
  (El conjuro avanzado de Viaje es *Traveler's Transit*, PC p. 379, fuera del slice.)

## Condiciones
- **Asustado** (*Frightened*, PC p. 444 · `/Conditions.aspx?ID=76`): penalizador de estatus igual al valor a todas
  las pruebas y CD; baja 1 al final de cada turno propio, salvo que se diga otra cosa.
- **Indispuesto** (*Sickened*, PC p. 446 · `ID=91`): penalizador de estatus igual al valor a todas las pruebas y CD;
  no puede ingerir nada. **Acción de 1 acción (vomitar, *retching*)**: salvación de Fortaleza contra la CD del efecto;
  éxito baja 1, éxito crítico baja 2. No baja solo.
- **Debilitado** (*Enfeebled*, PC p. 443 · `ID=71`): penalizador de estatus igual al valor a las tiradas y CD basadas
  en Fuerza (ataques cuerpo a cuerpo con Fuerza, daño con Fuerza, Atletismo).
- **Aturdido** (*Stunned*, PC p. 446 · `ID=93`): no puede actuar; el valor es la cantidad total de acciones que pierde
  (se descuentan al recuperar acciones).
- **Huyendo** (*Fleeing*, PC p. 444 · `ID=74`): en su turno gasta todas las acciones en alejarse de la fuente lo
  más rápido posible; no puede Demorar ni Preparar. Implementación simplificada (decisión de diseño): solo Zancadas
  y Pasos que terminan más lejos de la fuente.
- **Condiciones repetidas** (PC p. 442 · `/Rules.aspx?ID=2455`): una condición se tiene una sola vez; con valores
  distintos vale el más alto y se siguen las dos duraciones; una reducción baja todas las de ese nombre; quitar la
  condición la saca entera. **Valor de condición** (`ID=2456`): a 0, la condición termina.
- **Duraciones** (PC p. 302 · `ID=2242` y p. 426 · `ID=2378`): en rondas, bajan 1 al inicio de cada turno de quien
  creó el efecto; "hasta el final de su próximo turno" corre al final del turno del afectado. Si el lanzador muere,
  la duración sigue con su orden de iniciativa (pendiente: hoy los muertos no tienen turno).

## Sostener
- **Sostener** (*Sustain*, PC p. 419 · `/Actions.aspx?ID=2317`): 1 acción, **concentrar**. Extiende un efecto
  sostenido hasta el final del próximo turno (sostenerlo dos veces en el mismo turno no lo extiende más). Si se
  interrumpe, el efecto termina.
- **Conjuros sostenidos** (PC p. 302 · `/Rules.aspx?ID=2243`): duran hasta el final del próximo turno del lanzador si
  no se sostienen en ese turno. "Hasta 1 minuto" = 10 rondas.

## Candidatos a trucos y conjuros (lista a cerrar con el director)
| Conjuro | Rango | Tradiciones | Acciones | Alcance | Defensa | Efecto | Referencia |
|---|---|---|---|---|---|---|---|
| *Divine Lance* | truco | divina | 2 | 60 pies | CA (ataque de conjuro) | 2d4 de espíritu; crítico doble. Rasgos: santificado, espíritu | PC p. 325 · `ID=1498` |
| *Stabilize* | truco | divina, primigenia | 2 | 30 pies | — | 1 criatura moribunda: pierde moribundo, sigue inconsciente a 0 PG | PC p. 359 · `ID=1689` |
| *Daze* | truco | arcana, divina, ocultista | 2 | 60 pies | Voluntad básica | 1d6 mental; fallo crítico: también aturdido 1. No letal | PC p. 322 · `ID=1482` |
| *Telekinetic Projectile* | truco | arcana, ocultista | 2 | 30 pies | CA (ataque de conjuro) | 2d6 contundente, perforante o cortante; hace falta un objeto suelto para lanzar | PC p. 363 · `ID=1718` |
| *Fear* | 1 | las cuatro | 2 | 30 pies | Voluntad | éxito: asustado 1; fallo: asustado 2; fallo crítico: asustado 3 y huyendo 1 ronda | PC p. 331 · `ID=1524` |

## Guerrero
- **Carga repentina** (*Sudden Charge*, dote de guerrero 1, PC p. 141 · `/Feats.aspx?ID=4774`): **2 acciones**, rasgo
  **floritura** (una por turno); dos Zancadas y, si termina a alcance cuerpo a cuerpo de un enemigo, un Golpe cuerpo
  a cuerpo contra él.

## Rasgos
- **Manipular** (PC p. 458 · `/Traits.aspx?ID=645`): gestos o manipulación; suele disparar reacciones (Golpe reactivo).
- **Concentrar** (PC p. 454 · `ID=561`): requiere concentración mental.

## C4c — daño y reglas generales
- **Rasgo ataque** (PC p. 452 · `/Traits.aspx?ID=540`): cada ataque después del primero en el turno sufre el
  penalizador por ataque múltiple (también los ataques de conjuro).
- **Mitades y dobles** (PC p. 398 · `/Rules.aspx?ID=2266` y p. 407 · `ID=2307`): la mitad se redondea hacia abajo;
  1 de daño a la mitad sigue siendo 1. Se tira el daño normal y después se duplica o se divide.
- **No letal** (PC p. 407 · `ID=2311`, rasgo p. 282 · `/Traits.aspx?ID=661`): un conjuro no letal que deja a 0 PG
  noquea en vez de matar.
- **Daño de espíritu y mental** (PC p. 407 · `ID=2308`): el de espíritu no daña a criaturas sin espíritu
  (constructos); los descerebrados suelen ser inmunes al mental. Las criaturas de prueba no tienen inmunidades
  (pendiente cuando haya monstruos reales).
- **Santificado** (PC p. 113 · `ID=519`): si el lanzador es sagrado o sacrílego, el conjuro toma ese rasgo; El Umbral
  no tiene santificación, así que no cambia nada.

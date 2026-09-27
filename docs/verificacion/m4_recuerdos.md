# Verificación M4 — beneficios de recuerdos (candidatos)

Verificado el 2026-09-27 contra Archives of Nethys (índice oficial, Player Core Remaster). Solo números, reglas
resumidas y referencias. Principio de diseño: opciones, no poder bruto (sin bonificadores numéricos directos).

## Candidatos
- **Entrenado en una habilidad:** el recuerdo da la competencia directamente (hasta entrenado). Referencia: dote
  general *Skill Training* (PC p. 262 · `/Feats.aspx?ID=5214`), que pide Int +1: el recuerdo no pasa por la dote.
- **Medicina en batalla** (*Battle Medicine*, dote general y de habilidad 1, PC p. 253 · `/Feats.aspx?ID=5125`):
  1 acción, rasgos curación y manipular; requiere entrenado en Medicina y un botiquín de sanador. Prueba de
  Medicina con la CD de Tratar heridas: CD 15, éxito 2d8 PG, éxito crítico 4d8, fallo crítico 1d8 de daño
  (*Treat Wounds*, PC p. 242 · `/Actions.aspx?ID=2399`). No quita herido. El objetivo queda inmune 1 día a la
  Medicina en batalla de ese personaje.
- **Duro de matar** (*Diehard*, dote general 1, PC p. 254 · `/Feats.aspx?ID=5140`): se muere con moribundo 5 en vez
  de 4.
- **Carga repentina** (guerrero, ver `c4_conjuros.md`): dote de clase del Eco, no un recuerdo.

## Descartados
- *Toughness* (PC p. 263): PG extra, bonificador numérico directo.
- *Fleet* / *Incredible Initiative*: bonificadores numéricos.
- *Shield Block* (PC p. 262): no hay escudos en el slice.
- *Intimidating Glare* (PC p. 257): cambia el requisito de idioma de Desmoralizar; sin sistema de idiomas, no
  cambia nada.
- Competencia en armaduras o armas: el guerrero ya las tiene todas.

## Acciones de referencia (si se suman al slice)
- **Desmoralizar** (*Demoralize*, PC p. 240 · `/Actions.aspx?ID=2395`): 1 acción; Intimidación contra la CD de
  Voluntad de una criatura a 30 pies; éxito asustado 1, crítico asustado 2; inmune 10 minutos. Sin idioma
  común: -4 de circunstancia.
- **Recordar conocimiento** (*Recall Knowledge*, PC p. 231 · `/Actions.aspx?ID=2367`): 1 acción; el DJ fija la CD
  y responde una pregunta.
- **Ataque no letal** (PC p. 407 · `/Rules.aspx?ID=2311`): con un arma sin el rasgo no letal, -2 de circunstancia
  al ataque para noquear en vez de matar.

## Recordar conocimiento (verificado para M4b)
- **Acción** (PC p. 231 · `/Actions.aspx?ID=2367`): 1 acción, rasgos concentrar y **secreto** (PC p. 460 ·
  `/Traits.aspx?ID=690`: el DJ tira en secreto). Éxito crítico: respuesta verdadera y algo más; éxito: respuesta
  verdadera; fallo: nada; fallo crítico: respuesta **falsa** (o nada). Se puede usar sin entrenamiento
  (PC p. 225 · `/Rules.aspx?ID=2136`).
- **CD por nivel** (GM Core p. 52 · `/Rules.aspx?ID=2629`): nivel 0 → 14, 1 → 15, 2 → 16, 3 → 18, 4 → 19, 5 → 20.
  **Ajustes** (GM Core p. 52 · `ID=2630`): poco común +2, raro +5, único +10.
- **Habilidad por rasgo de la criatura** (GM Core p. 54 · `/Rules.aspx?ID=2641`): aberración, astral, onírica,
  etérea, cieno, espíritu, tiempo → Ocultismo; animal, hongo, planta, feérica → Naturaleza; bestia y elemental →
  Arcanos o Naturaleza; celestial, infernal, monitor, sombra, muerto viviente → Religión; constructo → Arcanos o
  Artesanía; dragón → Arcanos; humanoide → Sociedad.

### Interpretación para el slice (decisión del director: acotado)
- 1 acción; el personaje usa la mejor de sus habilidades que correspondan al rasgo de la criatura.
- Éxito o éxito crítico: la ficha muestra la salvación más débil. Fallo: nada. Fallo crítico: la ficha muestra
  una salvación que no es la más débil, como si lo fuera (el jugador no ve la tirada: rasgo secreto).
- Se puede reintentar; vale el último resultado.

## Descanso en puntos estables (verificado para M4c)
- **Descanso y preparativos diarios** (*Rest and Daily Preparations*, PC p. 439 · `/Rules.aspx?ID=2443`): una vez
  cada 24 horas, 8 horas de descanso: se recuperan PG igual al modificador de Constitución (mínimo 1) × nivel, y
  algunas condiciones se recuperan o mejoran. Después, preparativos (1 hora): los lanzadores recuperan los espacios
  de conjuro; se restablecen los puntos de foco y las capacidades de uso diario.
- **Herido** (*Wounded*, PC p. 447 · `/Conditions.aspx?ID=99`): termina con Tratar heridas exitoso o con los PG
  completos y 10 minutos de descanso.
- **Condenado / drenado / fatigado** (PC p. 443 y ss.): bajan o se van con una noche completa de descanso. No
  existen todavía en el slice.
- **Medicina en batalla:** la inmunidad dura 1 día (ver arriba), así que termina con el descanso.

### Interpretación para el slice (GDD, M3c: PG y espacios solo en puntos estables)
- Descansar en un punto estable = descanso completo + preparativos: PG completos (en vez de Con × nivel), todos
  los espacios y puntos de foco, sin herido (queda con PG completos y descansa) y sin inmunidades a Medicina en
  batalla. Los muertos siguen muertos. Sin límite de una vez por día (no hay paso del tiempo todavía).

## Muerto viviente de prueba (verificado para M4e)
- **Base: Zombie Shambler** (Monster Core p. 356 · `/Monsters.aspx?ID=3249`): nivel -1, CA 12, 20 PG, Fort +6, Ref +0,
  Vol +2, Percepción +0, Atletismo +7, Velocidad 25; puño +7, 1d6+3 contundente (más Agarrar y Mordisco, que no
  se implementan). **Debilidades:** cortante 5 y vitalidad 5. **Inmunidades:** sin sangrado, efectos de muerte,
  enfermedad, **mental**, paralizado, veneno, **inconsciente**. **Lento:** permanentemente lento 1 y sin reacciones.
- **Muerto viviente** (PC p. 462 · `/Traits.aspx?ID=722`): destruido a 0 PG; el daño de vitalidad lo daña.
- **Sin mente** (PC p. 458 · `/Traits.aspx?ID=652`): inmune a los efectos mentales.
- **Debilidad** (PC p. 408 · `/Rules.aspx?ID=2317`): se suma el valor al daño de ese tipo, una vez por efecto.
- **Inmunidad** (PC p. 408 · `/Rules.aspx?ID=2313`): se lo puede elegir como objetivo; el efecto no se aplica.
- **Lento** (PC p. 446 · `/Conditions.aspx?ID=92`): recupera tantas acciones menos al empezar su turno.
- **CD de Recordar conocimiento:** la tabla del GM Core empieza en nivel 0 (14); a nivel -1 se usa 14 (el bloque de
  AoN muestra 13, extrapolado).

## Inconsciente estable (verificado para la propuesta de M4e)
- **Inconsciente** (PC p. 446 · `/Conditions.aspx?ID=95`): a 0 PG sin moribundo, vuelve a 1 PG y despierta cuando
  pasa suficiente tiempo (el DJ decide: de 10 minutos a varias horas). Si lo curan, despierta y actúa en su turno
  siguiente.
- **Moribundo** (PC p. 443 · `/Conditions.aspx?ID=69`): al perder moribundo con éxito en la prueba de
  recuperación y seguir a 0 PG, sigue inconsciente y despierta como dice inconsciente.

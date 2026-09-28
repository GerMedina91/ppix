# Verificación M5 — encuentros, criaturas y resistencias

Verificado el 2026-09-28 contra Archives of Nethys (índice oficial; libros Remaster). Solo números, reglas resumidas
y referencias. Los nombres de las criaturas son `TODO_LORE` (su lore está en `docs/lore/slice.md`, SPOILER).

## Presupuesto de encuentros (GM Core)
- **Presupuesto por amenaza** (GM Core p. 75, tabla 10-1 · `/Rules.aspx?ID=2717`), party de 4: trivial 40 o menos,
  baja 60, moderada 80, severa 120, extrema 160.
- **XP por criatura** (GM Core p. 76, tabla 10-2 · `/Rules.aspx?ID=2718`): nivel de la party -4 → 10, -3 → 15,
  -2 → 20, -1 → 30, igual → 40, +1 → 60, +2 → 80, +3 → 120, +4 → 160. Para la party de nivel 1: criatura de nivel
  -1 = 20, 0 = 30, 2 = 60.
- En código: `PresupuestoEncuentro`; el test `test_presupuesto_encuentro.gd` controla los tres encuentros.

| # | Encuentro | Criaturas | XP | Amenaza |
|---|---|---|---|---|
| 1 | El linde del Monte | 2 humanos de nivel 0 (hoz) + 1 de nivel -1 (arco) | 30 + 30 + 20 = 80 | moderada |
| 2 | El corazón del Monte | 2 zombis (nivel -1) + 2 esqueletos (nivel -1, uno con arco) | 4 × 20 = 80 | moderada |
| 3 | El corazón del Monte (final) | Líder humano (nivel 2) + criatura (nivel 2) | 60 + 60 = 120 | severa (Jefe y lugarteniente, p. 75) |

## Reglas nuevas
- **Resistencia** (Player Core p. 408 · `/Rules.aspx?ID=2318`): después de las debilidades; cada vez que se recibe
  daño de ese tipo se resta el valor, hasta un mínimo de 0. Si hay varias al mismo tipo, se aplica una (la mayor).
  En código: `DefinicionCriatura.resistencias` y `AjusteDanio` (Golpes y conjuros).
- **Versátil** (Player Core p. 283 · `/Traits.aspx?ID=724`): el arma puede hacer el tipo alternativo; se elige en
  cada ataque. **Decisión de implementación:** se toma solo el tipo que más daño hace contra ese objetivo (lo que
  elegiría el jugador); si da igual, el principal.
- **Quedar noqueado a 0 PG** (Player Core p. 410 · `/Rules.aspx?ID=2324`): la mayoría de las criaturas mueren a 0 PG
  salvo con daño no letal; los muertos vivientes y constructos quedan destruidos. El DJ puede decidir que villanos
  y criaturas importantes usen las reglas de quedar noqueado. **Decisión del director:** los humanos del slice
  (incluido el líder) quedan **inconscientes** a 0 PG aunque el daño sea letal, sin moribundo; otro golpe a 0 PG los
  mata. Es un dato por criatura (`inconsciente_a_cero`). Así la primera decisión con un inconsciente está
  garantizada en el combate 1.
- **Inconsciente** (Player Core p. 446 · `/Conditions.aspx?ID=95`): sin cambios (ver `m4_recuerdos.md`).

## Esqueleto (base: Skeleton Guard, Monster Core p. 312 · `/Monsters.aspx?ID=3193`)
- Nivel -1, muerto viviente. Percepción +2. Acrobacias +6, Atletismo +3.
- CA 16, Fortaleza +2, Reflejos +8, Voluntad +2, **4 PG** (curación del vacío: Curar lo daña).
- Inmunidades: sangrado, efectos de muerte, enfermedad, **mental**, paralizado, veneno, inconsciente.
- **Resistencias: frío 5, electricidad 5, fuego 5, perforante 5, cortante 5.**
- Velocidad 25 pies. Cimitarra +6 (vigorosa, barrido), 1d6+2 cortante. Garra +6 (ágil, sutil), 1d4+2 cortante.
  Arco corto +6 (letal d10, incremento 60 pies, recarga 0), 1d6 perforante.
- **En el juego:** `esqueleto_guardia.tres` (cimitarra) y `esqueleto_guardia_arquero.tres` (arco corto, sin
  bonificador al daño). Es el mismo bloque: cambia solo el Golpe que usa (la IA usa el arma principal).
  **[aproximación]** Sin garra, vigorosa ni barrido; del resto de inmunidades solo importa la mental.
- Armas (Player Core): cimitarra 1d6 cortante, marcial, vigorosa y barrido (`/Weapons.aspx?ID=393`); arco corto
  1d6 perforante, marcial, letal d10, incremento 60 pies, recarga 0 (`/Weapons.aspx?ID=437`).

## Zombi (ya verificado en M4e)
Base Zombie Shambler (Monster Core p. 356), ver `m4_recuerdos.md`. Sin cambios.

## Criaturas construidas con el GM Core ("Building Creatures", GM Core p. 112 · `/Rules.aspx?ID=2874`)
Tablas usadas (valores para los niveles -1, 0 y 2):

| Tabla | Nivel -1 | Nivel 0 | Nivel 2 |
|---|---|---|---|
| 2-2 Percepción (extr./alta/mod./baja) | 9 / 8 / 5 / 2 | 10 / 9 / 6 / 3 | 12 / 11 / 8 / 5 |
| 2-3 Habilidades (extr./alta/mod.) | 8 / 5 / 4 | 9 / 6 / 5 | 11 / 8 / 7 |
| 2-5 CA (extr./alta/mod./baja) | 18 / 15 / 14 / 12 | 19 / 16 / 15 / 13 | 21 / 18 / 17 / 15 |
| 2-6 Salvaciones (extr./alta/mod./baja) | 9 / 8 / 5 / 2 | 10 / 9 / 6 / 3 | 12 / 11 / 8 / 5 |
| 2-7 PG (alta / mod. / baja) | 9 / 8-7 / 6-5 | 20-17 / 16-14 / 13-11 | 40-36 / 32-28 / 25-21 |
| 2-9 Ataque (extr./alta/mod./baja) | 10 / 8 / 6 / 4 | 10 / 8 / 6 / 4 | 13 / 11 / 9 / 7 |
| 2-10 Daño (alta / mod.) | 1d4+1 (3) / 1d4 (3) | 1d6+2 (5) / 1d4+2 (4) | 1d10+4 (9) / 1d8+4 (8) |
| 2-11 CD (extr./alta/mod.) | 19 / 16 / 13 | 19 / 16 / 13 | 22 / 18 / 15 |

"Se puede usar la tabla de CD de conjuros para las CD de las capacidades activas" (GM Core p. 112).

### Humano con hoz (nivel 0) — `deudo_peregrino.tres`
Rol: soldado raso de voluntad férrea. Humanoide.
- Percepción +6 (moderada). Atletismo +5, Religión +5 (moderadas).
- CA 15 (moderada). Fortaleza +6 (moderada), Reflejos +3 (baja), **Voluntad +9 (alta)**. 15 PG (moderados).
- Velocidad 25 pies. Hoz +8 (alto; ágil, sutil), **1d4+2** cortante (moderado; el dado de la hoz, Player Core
  `/Weapons.aspx?ID=364`: 1d4 cortante, simple, ágil, sutil, derribo). **[aproximación]** Sin derribo.
- Queda inconsciente a 0 PG.

### Humano con arco (nivel -1) — `deudo_devoto.tres`
Rol: tirador frágil. Humanoide.
- Percepción +5 (moderada). Religión +4 (moderada).
- CA 14 (moderada). Fortaleza +2 (baja), Reflejos +5 (moderada), **Voluntad +8 (alta)**. 8 PG (moderados).
- Velocidad 25 pies. Arco corto +6 (moderado; letal d10, incremento 60 pies), **1d6** perforante (3,5 de media,
  como el daño alto de nivel -1, 1d4+1).
- Queda inconsciente a 0 PG.

### Líder humano con guadaña (nivel 2) — `deudo_lider.tres`
Rol: jefe marcial (decisión del director: sin conjuros; la IA no lanza). Humanoide.
- Percepción +8 (moderada). Atletismo +8, Intimidación +8 (altas); Religión +7 (moderada).
- **CA 18 (alta).** Fortaleza +8 (moderada), Reflejos +5 (baja), **Voluntad +11 (alta)**. 32 PG (moderados, tope).
- Velocidad 25 pies. Guadaña +11 (alto; letal d10), **1d10+4** cortante (alto; el dado de la guadaña, Player Core
  `/Weapons.aspx?ID=394`: 1d10 cortante, marcial, dos manos, letal d10, derribo). **[aproximación]** Sin derribo.
- Queda inconsciente a 0 PG (decisión del director: también el líder).

### Criatura de nivel 2 (nombre TODO_LORE) — `eco_fallido.tres`
Concepto del director: una forma hecha de recuerdos de los muertos del Monte, un Eco fallido. Rasgo **espíritu**
(Recordar conocimiento con Ocultismo), **no incorpórea**, **inmune a los efectos mentales**. Placeholder con la rampa
Herida.
- Percepción +8 (moderada).
- CA 17 (moderada). Fortaleza +8, Reflejos +8 (moderadas), Voluntad +5 (baja: está hecha de pedazos). **36 PG
  (altos)**.
- Velocidad 25 pies. Mano +9 (moderado; ágil), **1d8+4** contundente (moderado).
- **Acción de miedo** (nombre TODO_LORE) · 1 acción · auditivo, emoción, miedo, mental. Cada enemigo vivo a 30 pies
  o menos, con línea de efecto, tira **Voluntad contra CD 18** (alta de nivel 2, tabla 2-11). Éxito crítico y
  éxito: nada. **Fallo: asustado 1. Fallo crítico: asustado 2.** Sea cual sea el resultado, queda inmune a esta
  acción de esa criatura durante 1 minuto (en el juego: el resto del combate).
  - **Referencia:** el Gemido espantoso (*Frightful Moan*) del Ghost Commoner, nivel 4 (Monster Core p. 161 ·
    `/Monsters.aspx?ID=3007`): 1 acción, 30 pies, Voluntad CD 21 (la alta de nivel 4), fallo asustado 2, fallo
    crítico asustado 3, inmune 1 minuto con éxito. Y la Presencia espantosa (Monster Core p. 359 ·
    `/MonsterAbilities.aspx?ID=17`), que da la inmunidad sea cual sea el resultado.
  - **Frecuencia razonable:** con la inmunidad tras cualquier resultado, afecta a cada miembro de la party una sola
    vez por combate; la IA la usa en su primera acción mientras haya alguien a quien asustar. Los valores de
    asustado bajan uno respecto del fantasma de nivel 4 (las tablas del GM Core no tabulan valores de condición).
  - **Decisión de implementación:** afecta solo a sus enemigos (el Gemido del fantasma afecta a toda criatura viva;
    así no asusta al líder humano).

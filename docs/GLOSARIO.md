# Glosario de reglas

Términos de reglas en castellano, según la edición oficial en castellano de los libros Remaster.
**Obligatorio** en código (identificadores de dominio), UI y textos del juego. Ver `CLAUDE.md`.

- **Confirmado:** validado por el director.
- **Provisorio:** elegido por el director para usar ya (código, UI y textos), pendiente de verificar contra la edición en castellano.
- **A verificar:** usado provisoriamente en código; confirmar contra la edición oficial antes de mostrarlo en UI o textos.
  Si se corrige, renombrar también en el código.

| Inglés (Remaster) | Castellano | En código | Estado |
|---|---|---|---|
| Difficulty Class (DC) | Clase de Dificultad (CD) | `cd` | Confirmado |
| Armor Class (AC) | Clase de Armadura (CA) | `ca` | Confirmado |
| Fortitude | Fortaleza | `FORTALEZA` | Confirmado |
| Reflex | Reflejos | `REFLEJOS` | Confirmado |
| Will | Voluntad | `VOLUNTAD` | Confirmado |
| Perception | Percepción | `percepcion` | Confirmado |
| untrained | no entrenado | `NO_ENTRENADO` | Confirmado |
| trained | entrenado | `ENTRENADO` | Confirmado |
| expert | experto | `EXPERTO` | Confirmado |
| master | maestro | `MAESTRO` | Confirmado |
| legendary | legendario | `LEGENDARIO` | Confirmado |
| critical success | éxito crítico | `EXITO_CRITICO` | Confirmado |
| success | éxito | `EXITO` | Confirmado |
| failure | fallo | `FALLO` | Confirmado |
| critical failure | fallo crítico | `FALLO_CRITICO` | Confirmado |
| fortune | fortuna | `fortuna` | Confirmado |
| misfortune | infortunio | `infortunio` | Confirmado |
| degree of success | grado de éxito | `GradoExito` | A verificar |
| check | prueba | `Prueba` | Provisorio |
| saving throw | tirada de salvación | `Salvacion` | Provisorio |
| proficiency / proficiency rank | competencia / rango de competencia | `Competencia`, `Rango` | A verificar |
| proficiency bonus | bonificador por competencia | `bonificador()` | A verificar |
| attribute modifier | modificador de atributo | — | A verificar |
| Strength / Dexterity / Constitution | Fuerza / Destreza / Constitución | `fuerza`, `destreza`, `constitucion` | Provisorio |
| Intelligence / Wisdom / Charisma | Inteligencia / Sabiduría / Carisma | `inteligencia`, `sabiduria`, `carisma` | Provisorio |
| bonus / penalty | bonificador / penalizador | — | A verificar |
| circumstance / status / item bonus | bonificador por circunstancia / de estatus / de objeto | `CIRCUNSTANCIA`, `ESTATUS`, `OBJETO` | Provisorio |
| untyped (penalty) | sin tipo | `SIN_TIPO` | A verificar |
| Hit Points (HP) | Puntos de Golpe (PG) | `pg` | Provisorio |
| class DC | CD de clase | `cd_clase` | A verificar |
| key attribute | atributo clave | `atributo_clave` | A verificar |
| Dexterity cap (armor) | tope de Destreza | `tope_destreza` | A verificar |
| natural 20 / natural 1 | 20 natural / 1 natural | `natural` | A verificar |
| Stride | Zancada | `zancada()` | Provisorio |
| Step | Paso | `paso()` | Provisorio |
| Speed | Velocidad | `velocidad_pies` | Provisorio |
| range increment | incremento de rango | `incremento_rango_pies` | Provisorio |
| reach | alcance | `alcance_pies` | Provisorio |
| Strike | Golpe | `Golpe` | Provisorio |
| multiple attack penalty | penalizador por ataque múltiple | `penalizador_ataque_multiple()` | Provisorio |
| agile | ágil | `agil` | Provisorio |
| finesse | sutil | `sutil` | Provisorio |
| off-guard | desprevenido | `desprevenido` | Provisorio |
| flanked / flanking | flanqueado / flanqueo | `Flanqueo` | Provisorio |
| dying | moribundo | `moribundo` | Provisorio |
| wounded | herido | `herido` | Provisorio |
| unconscious | inconsciente | `inconsciente` | Provisorio |
| recovery check | prueba de recuperación | `prueba_de_recuperacion()` | Provisorio |
| flat check | prueba plana | `Prueba.plana()` | Provisorio |
| slashing / piercing / bludgeoning | cortante / perforante / contundente | `CORTANTE`, `PERFORANTE`, `CONTUNDENTE` | Provisorio |
| initiative | iniciativa | `iniciativa` | Provisorio |
| reaction | reacción | `reaccion` | Provisorio |
| line of sight | línea de visión | `LineaVision` | Provisorio |
| deity (en el mundo propio) | entidad | `DefinicionEntidad` | Provisorio |
| divine font | fuente divina | `fuente_divina` | Provisorio |
| heal / harm (fuente) | curar / dañar | `CURAR`, `DANAR` | Provisorio |
| domain | dominio | `dominios` | Provisorio |
| edicts / anathema | edictos / anatemas | `edictos`, `anatemas` | Provisorio |
| divine skill | habilidad divina | `habilidad_divina` | Provisorio |
| favored weapon | arma predilecta | `arma_predilecta` | Provisorio |
| travel / dreams / death (dominios) | viaje / sueños / muerte | `viaje`, `suenos`, `muerte` | Provisorio |
| halberd | alabarda | `alabarda` | Provisorio |
| Occultism | Ocultismo | `ocultismo` | Provisorio |
| skill | habilidad | `Habilidad` | Provisorio |
| Acrobatics / Arcana / Athletics / Crafting | Acrobacias / Arcanos / Atletismo / Artesanía | `ACROBACIAS`, `ARCANOS`, `ATLETISMO`, `ARTESANIA` | Provisorio |
| Deception / Diplomacy / Intimidation / Lore | Engaño / Diplomacia / Intimidación / Saber | `ENGANO`, `DIPLOMACIA`, `INTIMIDACION` | Provisorio |
| Medicine / Nature / Performance / Religion | Medicina / Naturaleza / Interpretación / Religión | `MEDICINA`, `NATURALEZA`, `INTERPRETACION`, `RELIGION` | Provisorio |
| Society / Stealth / Survival / Thievery | Sociedad / Sigilo / Supervivencia / Latrocinio | `SOCIEDAD`, `SIGILO`, `SUPERVIVENCIA`, `LATROCINIO` | Provisorio |
| check penalty (armor) | penalizador a pruebas | `penalizador_pruebas` | Provisorio |
| simple / martial / advanced weapons / unarmed | armas simples / marciales / avanzadas / sin armas | `SIMPLE`, `MARCIAL`, `AVANZADA`, `SIN_ARMAS` | Provisorio |
| unarmored / light / medium / heavy armor | sin armadura / ligera / media / pesada | `SIN_ARMADURA`, `LIGERA`, `MEDIA`, `PESADA` | Provisorio |
| deadly / versatile / thrown / reach | letal / versátil / arrojadiza / alcance | `letal_caras`, `versatil`, `arrojadiza_incremento_pies`, `alcance_pies` | Provisorio |
| condition / condition value | condición / valor de condición | `Condiciones`, `EfectoCondicion`, `valor` | Provisorio |
| frightened / sickened / enfeebled | asustado / indispuesto / debilitado | `ASUSTADO`, `INDISPUESTO`, `DEBILITADO` | Provisorio |
| stunned / fleeing | aturdido / huyendo | `ATURDIDO`, `HUYENDO` | Provisorio |
| retching (acción de indispuesto) | Arcadas | `arcadas()`, `ARCADAS` | Provisorio |
| Sustain | Sostener | `sostener` | Provisorio |
| spell attack / spell DC | ataque de conjuro / CD de conjuro | `prueba_conjuro()` | Provisorio |
| spell / cantrip / spell slot / rank | conjuro / truco / espacio de conjuro / rango | `conjuros` | Provisorio |
| Focus Point / focus pool / focus spell | punto de foco / reserva de foco / conjuro de foco | — | Provisorio |
| basic saving throw | salvación básica | — | Provisorio |
| hex | maleficio | — | Provisorio |
| Cast a Spell | Lanzar un conjuro | `lanzar_conjuro()` | Provisorio |
| Evil Eye / Enfeeble / Agile Feet | Mal de ojo / Debilitar / Pies ágiles | `mal_de_ojo`, `debilitar`, `pies_agiles` | Provisorio |
| tradition (arcane / divine / occult / primal) | tradición (arcana / divina / ocultista / primigenia) | `Tradicion` | Provisorio |
| disrupt (an action) | interrumpir | `interrumpida` | Provisorio |

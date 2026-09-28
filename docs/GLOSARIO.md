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
| spirit / mental (daño) | de espíritu / mental | `ESPIRITU`, `MENTAL` | Provisorio |
| nonlethal | no letal | `NO_LETAL` | Provisorio |
| spell attack roll / basic save | ataque de conjuro / salvación básica | `es_ataque()`, `salvacion_basica` | Provisorio |
| Divine Lance / Stabilize / Fear | Lanza divina / Estabilizar / Miedo | `lanza_divina`, `estabilizar`, `miedo` | Provisorio |
| Telekinetic Projectile / Daze | Proyectil telequinético / Aturdir | `proyectil_telequinetico`, `aturdir` | Provisorio |
| Heal | Curar | `curar` | Provisorio |
| touch (range) / emanation / area / line of effect | toque / emanación / área / línea de efecto | `toque`, `emanacion_pies`, `es_area()` | Provisorio |
| willing | que acepte | — | Provisorio |
| undead / vitality (daño) | muerto viviente / de vitalidad | `muerto_viviente`, `VITALIDAD` | Provisorio |
| variable-cost spell | conjuro de costo variable | `VarianteConjuro`, `variantes` | Provisorio |
| creature trait (aberration, undead, humanoid...) | rasgo de criatura (aberración, muerto viviente, humanoide...) | `RasgoCriatura` | Provisorio |
| rarity (common / uncommon / rare / unique) | rareza (común / poco común / rara / única) | `Rareza` | Provisorio |
| Recall Knowledge / secret (trait) | Recordar conocimiento / secreto | `recordar_conocimiento()` | Provisorio |
| Battle Medicine / Treat Wounds | Medicina en batalla / Tratar heridas | `medicina_en_batalla()` | Provisorio |
| Diehard / Sudden Charge / flourish | Duro de matar / Carga repentina / floritura | `duro_de_matar`, `carga_repentina`, `floritura_en_turno` | Provisorio |
| nonlethal attack | ataque no letal | `no_letal` | Provisorio |
| memory (skill / experience / of the Mourner) | recuerdo (de destreza / vivencia / del Doliente) | `DefinicionRecuerdo` | Provisorio |
| rest / daily preparations | descanso, descansar / preparativos diarios | `Descanso`, `descansar()` | Provisorio |
| weakness / immunity / resistance | debilidad / inmunidad / resistencia | `debilidades`, `inmune_mental` | Provisorio |
| slowed | lento | `LENTO`, `lento` | Provisorio |
| lesser / standard / greater cover | cobertura menor / normal / mayor | `Cobertura.Nivel` | Provisorio |
| Take Cover | Tomar cobertura | `tomar_cobertura()`, `tomando_cobertura` | Provisorio |
| mindless | sin mente | — | Provisorio |

## Términos del mundo (no son de PF2e)

Nombres propios del mundo del juego (lore en `docs/lore/`). Se usan en UI y textos; en código la mecánica puede
tener otro nombre.

| Término del mundo | Qué es | En código | Estado |
|---|---|---|---|
| Lumbre / descansar en la Lumbre | Punto estable (GDD 4.3): pequeña llama que arde sin nada que quemar y que la Marea del Sueño no puede apagar; su forma cambia según el lugar (farol, nicho, piedra). | `PuntoEstable`, `Descanso` | Confirmado |
| Kardel | El pueblo del slice (mapa 1). | — | Confirmado |
| el Monte de los Idos | El bosque del slice (mapas 2 y 3: el linde del Monte, el corazón del Monte). | — | Confirmado |

# Verificación C1 — clases, ascendencia y equipo

Verificado el 2026-09-25 contra Archives of Nethys (índice oficial `elasticsearch.aonprd.com`, contenido
Remaster del **Player Core**). Solo números y referencias; no se copia texto de reglas.

## Clases (nivel 1)
| | Guerrero | Pícaro | Clérigo | Bruja |
|---|---|---|---|---|
| Fuente | PC p. 136 · `/Classes.aspx?ID=35` | PC p. 164 · `ID=37` | PC p. 108 · `ID=33` | PC p. 178 · `ID=38` |
| PG por nivel | 10 | 8 | 8 | 6 |
| Atributo clave | Fue o Des | Des u otro (según tejemaneje) | Sab | Int |
| Percepción | experto | experto | entrenado | entrenado |
| Fort / Ref / Vol | experto / experto / entrenado | entrenado / experto / experto | entrenado / entrenado / experto | entrenado / entrenado / experto |
| Ataques | simples y marciales experto; avanzadas entrenado; sin armas experto | simples y marciales entrenado; sin armas entrenado | simples, arma predilecta y sin armas entrenado | simples y sin armas entrenado |
| Defensa | todas las armaduras y sin armadura entrenado | ligera y sin armadura entrenado | sin armadura entrenado (la doctrina puede cambiarlo) | sin armadura entrenado |
| Habilidades | Acrobacias o Atletismo + 3 + Int | Sigilo + las del tejemaneje + 7 + Int | Religión + la de la deidad + 2 + Int | la del patrón + 3 + Int |
| CD de clase | entrenado | entrenado | entrenado | entrenado |
| Conjuros | — | — | ataque y CD entrenado | ataque y CD entrenado |
| Capacidades de nivel 1 | Golpe reactivo, dote de guerrero, Bloqueo con escudo | tejemaneje, ataque furtivo 1d6, ataque sorpresa, dote de pícaro, dote de habilidad | deidad, lanzamiento, fuente divina, doctrina | patrón, familiar, lanzamiento, maleficios |

- **Clérigo:** prepara 2 conjuros de rango 1 y 5 trucos. Fuente divina de curar: 4 espacios extra al rango más alto (5 a nivel 5, 6 a nivel 15).
- **Doctrina Enclaustrado** (PC p. 112 · `/Doctrines.aspx?ID=4`): primera doctrina = dote Iniciado de dominio.
- **Bruja:** prepara hasta 2 conjuros de rango 1 y 5 trucos. Un solo conjuro con el rasgo maleficio por turno.
- **Tejemaneje Ladrón** (PC p. 167 · `/Rackets.aspx?ID=9`): con arma sutil cuerpo a cuerpo (o ataque sin armas sutil) suma Destreza al daño en lugar de Fuerza; entrenado en Latrocinio.
- **Ataque furtivo:** +1d6 de precisión contra un objetivo desprevenido, con arma cuerpo a cuerpo ágil o sutil, ataque sin armas ágil o sutil, o ataque a distancia (arrojadiza: también ágil o sutil).
- **Ataque sorpresa:** primer asalto, si tira iniciativa con Engaño o Sigilo, las criaturas que no actuaron están desprevenidas frente al pícaro.

## Ascendencia
- **Humano** (PC p. 62 · `/Ancestries.aspx?ID=64`): 8 PG, Velocidad 25, Mediano, dos mejoras libres.

## Reglas de creación
- Mejoras de atributo (PC p. 17 · `/Rules.aspx?ID=2027`; p. 24 · `ID=2036`): +1 cada una; las cuatro libres van a atributos distintos; a nivel 1 ningún modificador supera +4 (ni baja de -1).
- Requisito de Fuerza de armaduras (PC p. 271 · `/Rules.aspx?ID=2175`): con Fuerza ≥ requisito no hay penalizador a pruebas y el de Velocidad baja 5 pies.

## Armas y armaduras
| Arma | Daño | Categoría | Manos | Rasgos | Fuente |
|---|---|---|---|---|---|
| Espadón | 1d12 cortante | marcial | 2 | versátil | PC p. 278 · `/Weapons.aspx?ID=379` |
| Estoque | 1d6 perforante | marcial | 1 | letal d8, desarmar, sutil | PC p. 278 · `ID=391` |
| Alabarda | 1d10 perforante | marcial | 2 | alcance, versátil | PC p. 278 · `ID=381` |
| Daga | 1d4 perforante | simple | 1 | ágil, sutil, arrojadiza, versátil | PC p. 277 · `ID=358` |

- **Letal** (PC p. 282 · `/Traits.aspx?ID=570`): en un crítico suma un dado del tamaño indicado, tirado después de duplicar.

| Armadura | CA | Tope Des | Categoría | Fuerza | Pruebas | Velocidad | Fuente |
|---|---|---|---|---|---|---|---|
| Cuero | +1 | +4 | ligera | 0 | -1 | — | PC p. 273 · `/Armor.aspx?ID=41` |
| Cota de malla | +4 | +1 | media | +3 | -2 | -5 pies | PC p. 273 · `ID=46` |

## Dominios (para El Umbral)
- En Player Core: Viaje (`/Domains.aspx?ID=93`), Sueños (`ID=72`) y Muerte (PC p. 39 · `ID=70`; conjuro de dominio *Death's Call*, avanzado *Eradicate Undeath*).
- **Reposo** y **Vigilia**: la versión Remaster está en *Divine Mysteries* (`ID=116`, `ID=123`), **no en Player Core**. Descartados: el tercer dominio es Muerte.

## Builds fijos del slice (resultado de `ArmadorPersonaje`, testeado)
Humano, nivel 1. Trasfondo: solo 2 mejoras + 1 habilidad (su dote de habilidad queda para más adelante).

| Build | Fue Des Con Int Sab Car | PG | CA | Ataque | Percepción | Fort / Ref / Vol | Equipo |
|---|---|---|---|---|---|---|---|
| Guerrero | 4 1 2 0 2 0 | 20 | 18 | espadón +9 (1d12+4) | +7 | +7 / +6 / +5 | cota de malla |
| Pícaro (Ladrón) | 0 4 1 1 1 2 | 17 | 18 | estoque +7 (1d6; Des al daño en C2) | +6 | +4 / +9 / +6 | armadura de cuero |
| Clérigo (Enclaustrado, El Umbral) | 1 1 2 0 4 1 | 18 | 14 | alabarda +4 (1d10+1, alcance 10) | +7 | +5 / +4 / +9 | — |
| Bruja (El Rencor) | 0 2 1 4 2 0 | 15 | 15 | daga +5 (1d4) | +5 | +4 / +5 / +7 | — |

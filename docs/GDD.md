# Documento de Diseño — [Título a definir]

> Estado: borrador v0.1. Director: Germán. Las secciones marcadas **[propuesta]** no están cerradas.

## 1. Visión
RPG táctico por turnos en pixel art, de fantasía oscura, no lineal y con muchos mapas, con reglas de Pathfinder 2e Remaster.
El jugador es un **Eco**: una criatura armada con recuerdos ajenos, en un mundo donde los planos de la realidad se están fusionando y los recuerdos se comercian como moneda.
Referencias de sensación: libertad y reactividad de un CRPG moderno + dificultad y narrativa fragmentaria estilo FromSoftware.

## 2. Pilares de diseño
1. **Nada servido.** La historia se reconstruye con fragmentos: descripciones de items, inscripciones, recuerdos comprados y NPCs que se contradicen o mienten. Nadie cuenta la verdad completa.
2. **Sin marcadores (o casi).** Las pistas están en el mundo. Se premia la atención del jugador.
3. **Dificultad táctica, no de reflejos.** Combates exigentes, recursos que se agotan entre peleas, descansos limitados, enemigos que usan bien sus tres acciones.
4. **La muerte duele pero es justa.** Perder tiene que sentirse como un error propio, nunca como azar injusto.
5. **Todo cuesta algo de vos.** La pregunta central: ¿cuánto de tu identidad vendés para ser más fuerte?

## 3. Mundo

### 3.1 Los tres planos
- **Físico:** la materia y los cuerpos.
- **Mental:** recuerdos, sueños, ideas.
- **Espiritual:** identidad, alma, lo que alguien *es*.

**[propuesta]** Los planos son el origen de las cuatro esencias de PF2e: el físico contiene materia y vida, el mental la mente y el espiritual el espíritu. Así el lore explica las tradiciones mágicas (arcana, divina, ocultista, primigenia) sin crear un sistema de magia paralelo.

### 3.2 La Convergencia (marco)
Los tres planos se están fusionando. Donde se tocan, la realidad se deforma: la geografía cambia, los lugares absorben recuerdos ajenos, los muertos no terminan de irse.
Implicancia de diseño: zonas que mutan según avanza la historia, lo que justifica volver a mapas ya visitados.

### 3.3 La Marea del Sueño (síntoma)
Cada noche el plano mental se desborda sobre el físico y las pesadillas toman cuerpo. Las ciudades viven con toque de queda.
Implicancia de diseño: ciclo día/noche como mecánica. De día se explora; de noche se sobrevive (encuentros y reglas distintas). **[detalle a definir]**

### 3.4 El Eco (protagonista)
Criatura nacida de la Convergencia, armada con recuerdos rescatados de alguien que murió. No sabe quién fue. Cada fragmento recuperado cambia lo que puede hacer y en quién puede confiar.

### 3.5 Recuerdos como moneda
Con la Convergencia, los recuerdos se volvieron extraíbles y tangibles.
- La moneda común existe para lo mundano (comida, alojamiento, equipo básico).
- Lo valioso se paga con recuerdos: magia, entrenamiento, favores, secretos.
- Capa social oscura: nobles que acumulan recuerdos de los pobres, extracción forzada, mercado negro, gente que vendió todo y quedó vacía.

## 4. Mecánicas centrales

### 4.1 Combate
- Por turnos, en grilla de 5 pies, sistema de tres acciones de PF2e, grados de éxito, condiciones.
- Contenido solo de libros Remaster.
- Party de 4 personajes, todos controlados por el jugador: decide las tres acciones de cada miembro en su turno.
- El combate ocurre **en el mismo mapa de exploración**, sin pantalla aparte (estilo BG3). La grilla de exploración es la grilla de combate.
- **[planificado]** Antes del combate, la party se puede separar para posicionar a cada miembro por separado.
- Nota para M3: el pathfinding de exploración usa costo diagonal uniforme; en combate hay que aplicar la regla de PF2e de diagonales alternadas (5/10 pies).
- Nota para M3: las entradas de mapa necesitan **posiciones de formación** para la party (una celda por miembro), no un punto único. Hoy los 4 aparecen apilados en la celda de entrada y se despliegan al caminar.

### 4.2 Recuerdos
**Diseño cerrado con el director (2026-09-27). Reemplaza la versión anterior de esta sección y de 4.3.**
- **Solo el Eco integra recuerdos.** La party sube de nivel con la XP normal de PF2e (el slice sigue en nivel 1; XP y subida de nivel quedan fuera del slice). En el slice, **el Eco es el guerrero**; en el juego completo, la clase la elige el jugador.
- **Principio:** los recuerdos dan **opciones, no poder bruto**. Nunca bonificadores numéricos directos; sí competencias (hasta entrenado), dotes generales y de habilidad y familiaridad con armas específicas. Todo verificado en AoN.
- **Estados:** *suelto* (objeto comerciable) / *integrado* (parte del Eco, da su beneficio, no se comercia).
- **Tipos:**
  - *Destreza:* beneficio mecánico; ocupa capacidad.
  - *Vivencia:* escena de lore; al verla se consume y queda en el diario; no ocupa capacidad.
  - *Del Doliente:* vivencia especial de trama; nunca se pierde; no ocupa capacidad.
- **Capacidad** de integrados de destreza: 2 + nivel (en la config). Soltar un integrado lo pierde para siempre. Integrar, solo fuera de combate.
- **Economía:** los recuerdos se pagan con otros recuerdos sueltos; cada uno tiene un valor entero (en `data/`). La moneda común existe aparte para lo mundano (no hace falta en el slice). El **Tasador** compra al 50 % del valor y vende al 100 % (en la config).
- **Fuentes:** comprar al Tasador; encontrar en el mundo (objetos interactuables en el mapa); extraer a enemigos inconscientes; extraer a compañeros muertos.
- **Enemigos inconscientes:** tras la victoria **quedan en el mapa** (reemplaza el "sacarlos del mapa" de M3c) y el jugador elige por cada uno: **extraer** (obtiene su recuerdo; el enemigo queda vacío), **perdonar** o **rematar**.
- **Decisiones del plan (2026-09-27):**
  - Recuerdos de destreza del slice: entrenado en Medicina, Medicina en batalla, Duro de matar, entrenado en Sigilo, en Religión y en Ocultismo. **Recordar conocimiento** acotado (1 acción; la habilidad depende del tipo de criatura, como en PF2e) revela en la ficha la salvación más débil, así Religión y Ocultismo sirven con distintos enemigos. **Sigilo** se usará en exploración más adelante.
  - **[pendiente]** Medicina en batalla ignora el requisito del botiquín de sanador hasta que haya objetos.
  - Ataque no letal: opción del Golpe con -2 (Player Core p. 407).
  - Los fragmentos del Doliente **no se venden**. El Tasador vende uno (valor 50): el jugador paga con recuerdos para conocer su pasado. Un fragmento suelto del Doliente no cae en el residuo (nunca se pierde).
  - Valores: destreza 20-40, vivencia 10, Doliente 50. Stock inicial del Tasador: 3 de destreza y 1 vivencia (más el fragmento del Doliente). El camino normal del slice tiene que dar recuerdos sueltos suficientes para que comprar el fragmento sea posible, pero obligue a vender o a no integrar algo que el jugador quiera (el detalle de fuentes y totales se documenta con el contenido).
  - **Trueque con el Tasador (implementación):** venderle un recuerdo acredita el 50 % de su valor en un **crédito con el Tasador**; comprarle cuesta el 100 % de ese crédito. Lo vendido entra a su stock.
  - Se registra en GameState qué se hizo con cada enemigo inconsciente (extraído, perdonado o rematado) para consecuencias futuras.
  - Encuentro donde murió el Eco: los muertos siguen muertos; los vivos y los inconscientes recuperan PG y vuelven a su posición.
  - Interacción en exploración: solo click por ahora.
  - Guardado a disco (M4g): una sola ranura por partida; incluye el estado del RNG (recargar no cambia las tiradas).
  - **Contenido de prueba (M4e):** al menos un enemigo muerto viviente (TODO_LORE; idea del director: "un muerto que no terminó de irse", consecuencia de la herida del Umbral). Vulnerable al daño de vitalidad según su definición PF2e (base a verificar en AoN, GM Core), así Curar le hace daño y Religión sirve para Recordar conocimiento.
  - **Barra de acciones (M4f):** las acciones sin objetivos válidos se muestran deshabilitadas (en gris) con el motivo al pasar el cursor, en vez de ocultarlas o dejarlas activas.
- **Lore (se mantiene):** los recuerdos muestran escenas desde el punto de vista de otros; algunos pueden ser falsos o manipulados.

### 4.3 Muerte del Eco
**Diseño cerrado con el director (2026-09-27).**
- **Muerte del Eco:** el Eco llega a moribundo 4, o cae toda la party. El combate termina y la party viva se rearma en el **último punto estable**. Los compañeros moribundos en ese momento sobreviven con herido +1.
- **Residuo:** los recuerdos sueltos que llevaba el Eco quedan en la casilla donde cayó, recuperables. Solo hay un residuo a la vez: si el Eco muere de nuevo antes de recuperarlo, los recuerdos de ese residuo pasan al stock del Tasador con un recargo (en la config).
- **Pérdida:** al rearmarse, el jugador **elige** un recuerdo integrado de destreza para perder (si tiene alguno). Los del Doliente y las vivencias vistas no se pierden.
- **Compañeros:** moribundo 4 = muerte permanente. El Eco puede extraer de su cuerpo (fuera de combate) recuerdos predefinidos de ese compañero (destreza y vivencia).
- El mundo sigue: los mapas no se regeneran y lo hecho, hecho está.
- **[propuesta]** Modo hardcore opcional con muerte permanente, para más adelante.

#### Guardado y puntos estables
- Solo se guarda en **puntos estables**: lugares donde la Convergencia no deforma la realidad.
- Autoguardado al cambiar de mapa.
- Sin guardado libre y sin guardado durante el combate.
- Al morir, el Eco vuelve al **último punto estable** con recuerdos perdidos. El estado del mundo no se revierte: el punto estable define dónde reaparece, no a qué momento se vuelve.
- Implicancia técnica: SaveSystem guarda un estado continuo del mundo (sin "volver atrás") más la referencia al último punto estable visitado. El autoguardado al cambiar de mapa persiste el progreso; no es un punto de reaparición.
- **Anti-savescum (decidido 2026-09-27, M4g):** una sola ranura y un mundo que no retrocede.
  - Además de descansar y cambiar de mapa, se autoguarda enseguida después de cada evento irreversible: muerte y rearmado del Eco (con el residuo y la elección del recuerdo perdido), compra y venta en el Tasador, integrar / soltar / ver, tomar o extraer un recuerdo, destino de un enemigo inconsciente, fin de combate (incluida la muerte de compañeros).
  - Al iniciar un combate se guarda el estado previo al primer turno: si el jugador cierra en medio, al cargar ese combate vuelve a empezar desde su comienzo (mismo RNG), no desde antes del encuentro.
  - Escritura atómica (temporal + renombrado), campo de versión con punto de entrada para migraciones, pantalla de inicio con Continuar / Nueva partida (confirmación si pisa la existente).

### 4.4 Exploración
Mundo no lineal, muchos mapas conectados, mínimos o nulos marcadores de misión.
- **Control:** click en una celda con pathfinding (8 direcciones, sin cortar esquinas) + teclado en direcciones de pantalla (W arriba, D derecha, etc.). Cada tecla es un paso diagonal de la grilla; combinando dos teclas salen los ortogonales (8 direcciones).
- **Party:** los 4 miembros caminan en fila india detrás del líder. El seguimiento se diseña para poder desactivarlo y controlar a cada miembro por separado (ver 4.1).

## 5. Dirección de arte
- **Vista isométrica.** Tiles en rombo de 64×32 (1 celda = 5 pies). La lógica sigue siendo una grilla cuadrada; isométrico es solo la proyección.
- **Resolución nativa: 960×540**, escalado entero (×2 a 1080p, ×4 a 4K). Se ven ~450 celdas y hasta 50–60 pies desde el centro, casi todo el rango de 60 pies (comparación con 640×360 en `docs/propuestas/`).
  - Contra: en web, dentro de una ventana de navegador no llega a ×2 y queda a ×1. **La versión web necesita un botón de pantalla completa.**
  - Contra: en 1440p queda a ×2 con franjas negras grandes.
  - **[a evaluar]** Steam Deck (1280×800) queda a ×1; evaluar más adelante un zoom de cámara.
- Personajes: placeholder 32×56; tamaño final a definir con el sprite canónico del Eco. Retratos de diálogo 96–128 px.
- **Y-sort** desde el principio: todo lo que se para sobre el mapa (party, paredes, objetos) se ordena por la posición de su base.
- **Transparencia de paredes** cuando tapan a un actor que hay que mantener visible (hoy la party; en M3 también enemigos y NPCs).
  - Hecho: capa `Paredes` separada del suelo, con y-sort junto con la party.
  - Criterio: una pared tapa a un miembro si su base está delante (y-sort mayor) y su rect en pantalla se superpone con el del sprite.
  - Implementado por tile (`_tile_data_runtime_update` de TileMapLayer), cambio instantáneo, opacidad en la config. Solo las paredes con el dato `se_transparenta`. Actores: grupo `mantener_visible`.
  - **[a futuro]** Fundido suave de la opacidad.
  - Observación de las pruebas: con paredes de 64 px de cara, una pared tapa casi entero a un personaje hasta dos celdas detrás.
- **Paredes cortadas:** las paredes de los bordes que dan a la cámara (bordes inferiores del rombo) son zócalos de ~16 px de cara; las del fondo y las interiores son altas. La transparencia aplica a las interiores.
- Generación con PixelLab + retoque en Aseprite. Todo asset final se pasa a modo indexado con la paleta del proyecto.
- **Paleta:** a definir (candidatas: Resurrect 64, Endesga 64, AAP-64). Rampas de 4–6 tonos con hue shifting.
- Primer asset a producir: sprite canónico del Eco, que sirve de referencia de estilo para todo lo demás.

## 6. Licencias
- Reglas bajo licencia ORC (PF2e Remaster). Incluir el aviso de atribución requerido.
- Excluido: material reservado de Paizo (setting, dioses, lugares, personajes, organizaciones) y la marca "Pathfinder".
- Mundo, historia y nombres 100% originales. Inspiración en tono y estructura sí; calcar mundos existentes no.
- Revisar el texto completo de la licencia antes de publicar.

## 7. Alcance: vertical slice **[propuesta]**
Objetivo: 10–15 minutos jugables que demuestren los pilares.
- 1 asentamiento + 1 zona peligrosa (mazmorra o exterior).
- 4 clases jugables a nivel 1: guerrero, pícaro, clérigo y bruja (Player Core, Remaster).
- Combate táctico completo con tres acciones.
- 1 mercader de recuerdos, 5–6 recuerdos comprables.
- Pérdida de recuerdos al morir.
- Ciclo día/noche básico (opcional para el slice).

## 8. Hitos técnicos **[propuesta]**
- **M0 — Setup:** proyecto Godot, config de render, estructura de carpetas, git, framework de tests.
- **M1 — Mundo:** tilemap de prueba, movimiento en grilla, cámara, colisiones, transición entre mapas.
- **M2 — Reglas:** motor de tiradas, grados de éxito, stats de personaje desde Resources.
  - Hecho: `Dados` (con estado serializable), `Tirada` (NdX+M), `GradoExito`, `Modificador` + `SumaModificadores`, `Competencia`, `Prueba` (con fortuna/infortunio y desglose), `Estadisticas` sobre `DefinicionPersonaje`.
  - Sin clases ni ascendencias: los números del personaje se cargan a mano hasta definir el contenido del slice.
- **M3 — Combate:** iniciativa, turnos, tres acciones, ataque/movimiento/condiciones básicas, IA enemiga simple. **Cerrado.**
  - **Resumen de M3.** Combate de PF2e en el mismo mapa de exploración, con la party de 4 controlada por el jugador:
    - Reglas (`rules/combate/`, lógica pura y reproducible con semilla): medición con diagonales 5/10 y alcance de 10 pies, Zancada (una o varias, cada una una acción), Paso, Golpe (penalizador por ataque múltiple, incrementos de rango, crítico, daño mínimo), línea de visión, flanqueo (desprevenido solo frente a quien flanquea), moribundo/herido/inconsciente completos, iniciativa, turnos de 3 acciones, IA de a una acción, punto de extensión para reacciones.
    - Presentación (`scripts/combat/`): encuentros con disparador genérico, controlador + animador + resaltados, HUD con registro y desglose, feedback de acciones imposibles, previsualización de costo (◆), capas de depuración F3 y curación F4.
    - Garantía: test de invariante sobre el mapa real (IA contra IA): tras cada evento, cada actor está en la casilla de su combatiente.
    - Pendientes que pasan a M3c/M4: clases y ascendencias reales, conjuros, reacciones, cobertura, posicionamiento previo, muerte del Eco (derrota hoy es placeholder), caídos que siguen caminando en exploración.
  - El costo de movimiento en combate usa la regla de diagonales de PF2e (5/10 pies alternado), calculado en `rules/`, no el costo de AStarGrid2D (que solo sirve para exploración).
  - En combate, las celdas ocupadas por actores bloquean el paso.
  - `Dados` tiene que poder serializar y restaurar el estado del RNG, para el guardado.
  - Las entradas de mapa necesitan posiciones de formación para la party (ver 4.1).
  - Dividido en M3a (reglas en `rules/`, sin escenas) y M3b (presentación en el mapa).
  - M3a hecho: `Medicion`, `MovimientoCombate`, `LineaVision`, `Combatiente` (+ `FuenteEstadisticas`), `Condiciones`, `Flanqueo`, `Golpe`, `Combate` (eventos, reproducible) e `IASimple`.
  - M3b hecho: formación de entrada, encuentros (`Encuentro` + `DisparadorEncuentro`/`ZonaEncuentro`), `ControladorCombate` (turnos, animaciones, resaltados), `HudCombate` con registro y desglose, capas F3 de rangos y línea de visión, F4 de curación (debug).
  - Victoria con miembros moribundos: se estabilizan (pierden moribundo, herido +1). **Decidido en M4e:** al ganar, los inconscientes estables despiertan con 1 PG y conservan su herido (ver M4e).
  - **[placeholder M4]** Derrota: la party se cura y vuelve a la última entrada del mapa.
  - ~~En exploración, los miembros caídos (0 PG) siguen caminando en la fila.~~ Resuelto en M4e: despiertan con 1 PG al ganar.
  - Flanqueo: el flanqueado queda desprevenido **solo frente a las criaturas que lo flanquean**.
  - Alcance de 10 pies: llega a dos casillas en diagonal aunque por la regla de diagonales contaría 15 pies.
  - Moribundo, herido e inconsciente con reglas completas para la party; los enemigos mueren a 0 PG.
  - Sin reacciones en M3; el sistema queda preparado para sumarlas.
  - Inicio del combate: zona de encuentro detrás de una interfaz de disparador genérica (para sumar después detección por visión).
  - Party de prueba: 2 combatientes cuerpo a cuerpo y 2 a distancia, con números genéricos (`TODO_LORE`); la estructura queda lista para que clases y ascendencias armen el `DefinicionPersonaje`.
  - M3b: tecla de depuración (solo builds de debug) para curar a la party por completo, porque los PG persisten entre combates y todavía no hay descanso.
  - M3b: la fuente del HUD es la de Godot como placeholder.
- **M3c — Clases:** guerrero, pícaro, clérigo y bruja a nivel 1, con builds fijos y ascendencia humana (placeholder). Cada clase se verifica en Archives of Nethys **antes** de implementarla (`docs/verificacion/`).
  - Recuperación: PG y espacios de conjuro solo en puntos estables; 1 punto de foco al terminar cada combate.
  - Reacciones del jugador: aviso [Sí] [No] [Siempre] con el combate pausado; "Siempre" dura la sesión (se podrá revertir desde un menú futuro).
  - Bruja: patrón El Rencor (mecánica de *The Resentment*); familiar sin rol mecánico por ahora.
  - Conjuros del slice. Clérigo: trucos Lanza divina y Estabilizar; rango 1: Miedo; fuente divina: Curar; foco: Pies ágiles (dominio Viaje). Bruja: trucos Mal de ojo, Proyectil telequinético (sin el requisito del objeto suelto) y Aturdir; rango 1: Debilitar y Miedo. La bruja no tiene conjuro de foco (sus maleficios de foco dependen del familiar).
  - **[pendiente]** Duraciones de un lanzador muerto: según las reglas siguen corriendo en su lugar de la iniciativa; hoy los muertos no tienen turno y esas duraciones quedan congeladas. Los conjuros sostenidos sí terminan si muere el lanzador o el objetivo.
  - Reacciones antes del primer turno: **habilitadas para ambos bandos** (el Player Core p. 436 lo deja al DJ). Opción `reacciones_antes_del_primer_turno` en `ConfigCombate`, true por defecto.
  - Objetivos de conjuros: se permiten aliados (reglas), resaltados con otro color que los oponentes. La IA nunca elige aliados como objetivo de un conjuro dañino.
  - Clérigo: prepara Miedo en sus 2 espacios de rango 1 (la lista tiene un solo conjuro de rango 1).
  - Daño no letal (Aturdir): el enemigo que queda a 0 PG queda inconsciente, no muere. La victoria cuenta a los enemigos fuera de combate (muertos o inconscientes) Al ganar se sacaban todos del mapa; **M4 lo reemplaza:** los inconscientes quedan (ver 4.2).
  - Curar (C5): 1 acción toque, 2 acciones 30 pies y +8, 3 acciones emanación de 30 pies. El clérigo tiene 4 espacios de fuente divina solo para Curar. Los enemigos no aceptan curación de objetivo único, pero la emanación cura a todos los seres vivos que estén dentro (incluidos enemigos), como dicen las reglas. Selección: tecla del conjuro y después 1-3 para las acciones (placeholder hasta la barra de C6).
  - Huyendo simplificado: en su turno solo puede hacer Zancadas o Pasos que terminen más lejos de la fuente del miedo (party e IA).
  - Pasos: C4a condiciones y estadísticas de conjuro → C4b motor de lanzamiento (Mal de ojo, Debilitar, Pies ágiles, Sostener, un maleficio por turno, manipular dispara el Golpe reactivo) → C4c el resto de la lista.
  - **M3c cerrado (2026-09-27).** Resumen:
    - **Clases y builds (C1):** competencias por categoría, 16 habilidades, ascendencia humana, guerrero, pícaro (Ladrón), clérigo (Enclaustrado, El Umbral: viaje, sueños, muerte) y bruja (El Rencor), armados y validados por `ArmadorPersonaje`. La party del mundo usa los 4 builds.
    - **Capacidades (C2):** ataque furtivo y Destreza al daño del Ladrón.
    - **Reacciones (C3):** Golpe reactivo (también ante manipular, con interrupción por crítico) y Esquiva ágil (también ante ataques de conjuro); aviso [Sí] [No] [Siempre] con el combate en pausa; reacciones desde el primer turno.
    - **Condiciones y conjuros (C4):** asustado, indispuesto, debilitado, aturdido y huyendo con duraciones y pisos; Arcadas; ataque y CD de conjuro; trucos, espacios, reserva de foco y fuente divina; Sostener; un maleficio por turno; salvación básica, ataques de conjuro, no letal y Estabilizar. Lista completa del slice: Mal de ojo, Debilitar, Miedo, Proyectil telequinético, Aturdir, Lanza divina, Estabilizar, Pies ágiles y Curar.
    - **Costo variable y áreas (C5):** Curar de 1 a 3 acciones con emanación de 30 pies.
    - **Presentación (C6):** barra de acciones con selector de costo e interruptor para incluirse en la emanación, ficha del combatiente bajo el cursor, atajos en el InputMap (1-9, Esc/click derecho, E, Espacio), estilo del HUD centralizado en `EstiloHud` (`data/config/estilo_hud.tres`).
    - **Recuperación (C7, parcial):** 1 punto de foco al terminar cada combate. PG y espacios en puntos estables llegan con los puntos estables (M4); hasta entonces, F4 (depuración) restaura todo.
    - **Rendimiento y estructura:** previsión de movimiento por punto de decisión; `Combate` delega en `AccionesMovimiento`, `AccionesGolpe`, `AccionesConjuro` (+ `ObjetivosConjuro`, `EfectosConjuro`), `CicloTurno` y `ReglasCondiciones`; tests rápidos (`-Rapidos`) y de integración separados.
    - Verificación de reglas en `docs/verificacion/` (c1, c3, c4, c5); capturas en `docs/capturas/c4`, `c5` y `c6`.
  - **Pendientes que deja M3c:**
    - Recuperación de PG y espacios en puntos estables (con M4). "Siempre" del aviso de reacción reversible desde un menú futuro.
    - Guerrero: Carga repentina (verificada, sin implementar; rasgo floritura).
    - Duraciones de un lanzador muerto (hoy quedan congeladas; los sostenidos sí terminan).
    - Esquiva ágil: requisito de no estar impedido (no hay carga todavía).
    - Pies ágiles: la opción de Pasar haciendo acrobacias como parte del lanzamiento, e ignorar terreno difícil (no hay terreno difícil).
    - Inmunidades a daño mental y de espíritu, y muertos vivientes reales (el soporte existe; ninguna criatura lo usa).
    - IA: no lanza conjuros; cuando lo haga, nunca elige aliados para conjuros dañinos.
    - Familiar de la bruja y sus maleficios de foco; santificación, edictos y anatemas con efecto mecánico; Saber (*Lore*); dote de habilidad del trasfondo; ascendencias reales (hoy humano placeholder).
    - Aproximaciones: línea de efecto = línea de visión; en criaturas, el ataque cuerpo a cuerpo sin sutil se toma como de Fuerza (para debilitado); huyendo simplificado.
  - **A verificar (terminología):** todos los términos del glosario marcados **Provisorio** están pendientes de confirmar contra la edición oficial en castellano (condiciones, conjuros, rasgos, acciones, clases, armas). Marcados **A verificar** (no van a UI ni textos): grado de éxito, competencia / rango de competencia, bonificador por competencia, modificador de atributo, bonificador / penalizador, sin tipo, CD de clase, atributo clave, tope de Destreza, 20 natural / 1 natural.
- **Después de M3:** cobertura (menor / normal / mayor) calculada con la línea de visión; posicionamiento previo de la party antes del combate.
- **M4 — Recuerdos:** ver 4.2 y 4.3. Alcance del slice: puntos estables funcionales (reaparición y recuperación de PG, espacios y foco), 1 Tasador con compra/venta, contenido placeholder `TODO_LORE` (5-6 recuerdos de destreza, 3-4 vivencias, 1-2 fragmentos del Doliente, recuerdos predefinidos de los 3 compañeros), diario básico, UI funcional con el tema centralizado. Guardado a disco como paso final si encaja. Además: Carga repentina del guerrero (el Eco). Cobertura y posicionamiento previo quedan para después de M4.
  - Enemigos inconscientes tras la victoria: pasó de idea a decisión (extraer, perdonar, rematar; ver 4.2). Interrogar queda como idea para más adelante.
  - **M4c hecho:** objetos interactuables en los mapas (`Interactuable`, ocupan su casilla): click en uno y la party camina hasta una casilla vecina (`GrillaMapa.celda_junto_a`) y se abre; otro click o el teclado lo cancelan. `PuntoEstable` con panel Descansar / Seguir: el descanso (`Descanso`, PC p. 439, ver `docs/verificacion/m4_recuerdos.md`) recupera PG, espacios, foco, herido e inmunidad a Medicina en batalla; los muertos siguen muertos. Registra el punto de reaparición (`GameState.id_ultimo_punto_estable` + mapa) y emite `punto_estable_activado` (SaveSystem guarda en M4g). F4 queda solo para depuración. Punto de prueba en el mapa A (4,9); capturas en `docs/capturas/m4/05` a `07`.
    - **[provisorio]** Sin límite de un descanso por día (no hay paso del tiempo).
    - **Gancho de sueños:** al descansar, el Eco tiene el próximo sueño sin ver (`CatalogoSuenos` en `data/suenos/`, contenido TODO_LORE); se registra en `GameState.suenos_vistos` (incluido en `GameState.a_diccionario()`, JSON), se emite `EventBus.sueno_en_descanso` y el panel muestra el texto. Es la vía por la que le hablan al Eco (ver `docs/lore/verdad.md`).
    - **Nombres de la party** (`docs/lore/companeros.md`): Irsa (pícara), Orven (clérigo), Vaisha (bruja), en los builds; el Eco se muestra siempre como "el Eco" (`MiembroParty.nombre_visible()`). El HUD, la ficha y el registro muestran `Combatiente.nombre_visible`; los ids internos siguen siendo los nodos (Miembro1-4). En el registro: "El Eco" al empezar la línea y "del Eco".
    - **[pregunta abierta]** Costo de descansar. Idea del director: descansar es dormir, y dormir abre la puerta a la Marea del Sueño; conectarlo con los sueños de la persona amada (ver `docs/lore/verdad.md`) y con los Insomnes.
    - Tiempos de los tests (2026-09-27): el costo fijo por test subió de ~14 ms a ~92 ms sin cambios de código (el commit anterior, medido de nuevo, da lo mismo; un test vacío tarda ~90 ms y un frame vacío ~5,5 ms). Es de la máquina (CPU compartida, antivirus), no del proyecto.
  - **M4d (1 y 2) hecho — muerte del Eco:**
    - Reglas: `Combatiente.es_eco`; el combate termina en derrota si muere el Eco o cae toda la party (**decidido:** la derrota tiene prioridad si coincide con la victoria en la misma acción). `ResultadoCombate` (lo arma `ArmadoCombate.cerrar` y viaja en `combate_terminado`). `Rearmado` calcula la party rearmada.
    - Mundo: `EstadoMundo` en `GameState.mundo` (encuentros resueltos y enemigos retirados, serializable) se aplica al cargar cada mapa: los muertos siguen muertos; tras la muerte del Eco el encuentro queda sin resolver y los demás enemigos vuelven a su lugar con todos sus PG (el mapa se recarga).
    - `GestorMuerte`: residuo en la casilla donde cayó (marca en el suelo; se recupera cuando el Eco la pisa en exploración, con aviso) y `PanelPerdida` para elegir el integrado que se pierde. El Mundo hace reaparecer a la party al lado del último punto estable.
    - **Decidido (2026-09-27):** rearmado = descanso completo (PG, espacios, foco, inmunidades), pero los compañeros conservan su herido y los moribundos suman +1; el Eco se rearma sin herido.
    - **Decidido:** sin punto estable registrado, la party reaparece en la última entrada del mapa.
    - **Decidido:** los enemigos inconscientes vencidos se retiran del mapa hasta M4e (que los deja con extraer / perdonar / rematar).
    - Capturas en `docs/capturas/m4/10` a `13`.
  - **M4d (3) hecho — muerte permanente de compañeros:** el compañero muerto deja su cuerpo (`CuerpoCompanero`, interactuable; en M4e se le extraen recuerdos) en la casilla donde cayó, anotado en `EstadoMundo.cuerpos` (persiste al cambiar de mapa), y sale de la fila (`ControlParty.fijar_retirados`; el Eco nunca se retira). F4 ya no revive a los muertos. Capturas `m4/14` y `15`.
    - **Decidido (M4e):** los compañeros inconscientes estables despiertan con 1 PG al ganar el combate y conservan su herido (Player Core p. 446: a 0 PG sin moribundo vuelven a 1 PG tras al menos 10 minutos; el rato después del combate cuenta como ese tiempo).
  - **M4e hecho — fuentes de recuerdos en el mundo:**
    - `ObjetoRecuerdo` (interactuable): el Eco lo toma y desaparece para siempre (`EstadoMundo.objetos_tomados`).
    - Enemigos inconscientes tras la victoria: `FuentesRecuerdos` pregunta por cada uno (`PanelOpciones`): **extraer** (su `DefinicionCriatura.recuerdo`), **perdonar** o **rematar**; se registra el destino en `GameState.recuerdos.destinos` y el enemigo se retira del mapa. **Decidido:** los tres destinos lo retiran del mapa, con el destino registrado (extraído: queda vacío y se va; perdonado: se va).
    - Cuerpo de un compañero: se le extraen una vez sus recuerdos predefinidos (`MiembroParty.recuerdos_del_cuerpo`; Irsa lleva además el tercer fragmento del Doliente).
    - Muerto viviente de prueba (base: Zombie Shambler, Monster Core p. 356; verificado en `docs/verificacion/m4_recuerdos.md`): debilidad cortante y vitalidad 5, inmune a lo mental, lento 1, destruido a 0 PG aunque el daño sea no letal. Dos en un encuentro al fondo del mapa B. **[aproximación]** Sin Agarrar ni Mordisco.
    - Contenido placeholder en `data/recuerdos/` (catálogo en `catalogo_recuerdos.tres`); stock inicial del Tasador en `ConfigRecuerdos`.
    - Capturas `m4/16` a `22`.
  - **Balance de recuerdos sueltos (M4e).** Capacidad a nivel 1: 3 integrados de destreza. El Tasador acredita el 50 % y vende al 100 %.

    | Fuente | Recuerdo | Tipo | Valor | Vendible |
    |---|---|---|---|---|
    | Objeto, mapa A | Entrenado en Medicina | destreza | 20 | sí |
    | Objeto, mapa A | Vivencia 2 | vivencia | 10 | sí |
    | Objeto, mapa B (detrás de los muertos vivientes; decidido) | Entrenado en Sigilo | destreza | 30 | sí |
    | Objeto, mapa B | Vivencia 3 | vivencia | 10 | sí |
    | Objeto, mapa B | Fragmento del Doliente 2 | Doliente | 50 | no |
    | Extraer, enemigo cuerpo a cuerpo | Duro de matar | destreza | 30 | sí |
    | Extraer, enemigo a distancia | Vivencia 4 | vivencia | 10 | sí |
    | Stock del Tasador | Medicina en batalla (requiere Medicina) | destreza | 30 (precio) | — |
    | Stock del Tasador | Entrenado en Religión / en Ocultismo | destreza | 20 c/u (precio) | — |
    | Stock del Tasador | Vivencia 1 | vivencia | 10 (precio) | — |
    | Stock del Tasador | Fragmento del Doliente 1 | Doliente | 50 (precio) | — |
    | Cuerpo de Irsa (si muere) | Sigilo 20 + vivencia 10 + Fragmento del Doliente 3 | — | 30 vendible | parcial |
    | Cuerpo de Orven / de Vaisha (si mueren) | Religión / Ocultismo 20 + vivencia 10 | — | 30 vendible c/u | sí |

    - **Decidido (2026-09-27): no tocar este balance.** El dilema buscado: rematar en vez de extraer deja sin fragmento.
    - **Camino normal** (todos los objetos y extraer a los dos enemigos): 110 de valor vendible → vendiendo todo, 55 de crédito. El fragmento del Tasador cuesta 50: comprarlo obliga a vender casi todo (incluidas las vivencias sin verlas) y renunciar a integrar Medicina, Sigilo y Duro de matar. Sin comprarlo, sobran recuerdos para llenar los 3 espacios y todavía cambiar algo en el Tasador.
    - Rematar o perdonar a un enemigo baja el total: sin Duro de matar quedan 80 (40 de crédito, no alcanza para el fragmento); sin la vivencia 4 quedan 100 (50, justo).
    - Extraer de compañeros muertos no es el camino normal: suma hasta 90 vendibles más.
  - **M4f hecho — interfaces** (funcionales, placeholder, con el tema del `EstiloHud` y piezas comunes en `ConstruccionUi`):
    - `PantallaTasador`: se abre al interactuar con el Tasador (mapa A, TODO_LORE). Crédito, stock con precio y Comprar, sueltos con lo que acreditan y Vender; lo imposible en gris con el motivo como tooltip (`Tasador.motivo_compra` / `motivo_venta`).
    - `PantallaRecuerdos`: botón "Recuerdos" en exploración (`HudExploracion`; oculto en combate). Capacidad de integrados, Integrar / Ver (vivencias y fragmentos pasan al diario y se lee su texto), Soltar con confirmación ("se pierde para siempre"), pestaña Diario.
    - Barra de combate: las opciones sin objetivos válidos se muestran en gris con el motivo más repetido como tooltip (`SinObjetivos`) y su atajo no las elige.
    - **[propuesta]** Atajo de teclado para abrir los recuerdos (p. ej. R): requiere sumar una acción al InputMap.
    - Capturas `m4/23` a `27` (el tooltip no sale en las capturas automáticas; se ve pasando el mouse en el editor).
  - **M4g hecho — guardado a disco:** `SaveSystem` escribe `user://partida.json` (una ranura; otra para los tests) con `GameState.a_diccionario()` completo: mapa, casillas de la party, combate y pérdida pendientes, punto estable, party (PG, herido, muerte, conjuros, inmunidades), recuerdos (inventario, Tasador, residuo, destinos), mundo (encuentros, enemigos, cuerpos, objetos), sueños y RNG (semilla y estado como texto: son enteros de 64 bits). Autoguardado por `EventBus.cambio_irreversible`; `EventBus.antes_de_guardar` para que el mundo anote dónde está la party. Pantalla de inicio (`scenes/ui/inicio.tscn`, escena principal). Tests de ida y vuelta (el RNG sigue igual), escritura atómica, guardado dañado, versión futura, combate cortado que vuelve a empezar igual y pérdida pendiente. Capturas `m4/28` a `30`.
  - **M4 cerrado (2026-09-27).** Resumen:
    - **Recuerdos (M4a-b):** modelo de recuerdos (destreza, vivencia, del Doliente), inventario, capacidad (2 + nivel), Tasador con crédito (compra al 50 %, vende al 100 %, recargo a lo que viene de residuos perdidos) y estado persistente. El Eco (el guerrero) se arma con sus integrados. Beneficios: entrenado en habilidades, Medicina en batalla, Duro de matar; además Carga repentina, ataque no letal y Recordar conocimiento (salvación más débil, fallo crítico falso y secreto).
    - **Puntos estables (M4c):** interacción por click con objetos del mapa; descanso completo, punto de reaparición y el gancho de sueños (TODO_LORE).
    - **Muerte (M4d):** muerte del Eco (moribundo 4 o 5, o toda la party caída) = derrota; rearmado en el último punto estable, residuo único recuperable, pérdida elegida de un integrado; muerte permanente de compañeros con el cuerpo en el mapa. Estado persistente de los mapas (encuentros, enemigos, cuerpos, objetos).
    - **Fuentes (M4e):** objetos con recuerdos, enemigos inconscientes (extraer / perdonar / rematar, destino registrado), extracción del cuerpo de un compañero, muerto viviente de prueba (debilidades, inmunidad mental, lento), contenido placeholder y tabla de balance. Compañeros inconscientes estables despiertan con 1 PG al ganar.
    - **Interfaces (M4f):** Tasador, recuerdos del Eco con diario (tecla R), acciones sin objetivo en gris con motivo; `ConstruccionUi` y `EstiloHud` para todo.
    - **Guardado (M4g):** una ranura, autoguardado en cada cambio irreversible y al iniciar combate, escritura atómica, versión y pantalla de inicio.
    - **Lore registrado:** `docs/lore/companeros.md` y la persona amada en `verdad.md` (spoilers), `docs/lore/estilo.md` (nombres). Nombres de la party en el HUD: el Eco, Irsa, Orven, Vaisha.
    - Verificación en `docs/verificacion/m4_recuerdos.md`; capturas en `docs/capturas/m4/` (01 a 30).
  - **Pendientes que deja M4:**
    - Costo de descansar (pregunta abierta: dormir, la Marea del Sueño, los sueños y los Insomnes); sin límite de un descanso por día mientras no haya tiempo de juego.
    - Botiquín de sanador para Medicina en batalla (no hay objetos).
    - Sigilo en exploración (el recuerdo existe; todavía no tiene uso).
    - Muerto viviente: Agarrar y Mordisco sin implementar.
    - Contenido real: nombres y textos de recuerdos, vivencias, fragmentos, sueños, Tasador y punto estable (todo `TODO_LORE`); título del juego.
    - IA: no lanza conjuros.
    - Tooltips de la UI: no salen en las capturas automáticas (sí en el juego).
    - Arte: todo placeholder.
  - **A verificar (terminología):** se suman como **Provisorio** descanso / preparativos diarios, debilidad / inmunidad / resistencia, lento, sin mente, Recordar conocimiento, Medicina en batalla, Duro de matar, Carga repentina, floritura, ataque no letal, rasgo de criatura y rareza; siguen **A verificar** los de M3c.
- **M5-prep — Preparación técnica del contenido** (plan aprobado 2026-09-28): a) herramientas de mapas → b) diálogos con Dialogue Manager → c) exportación web. Cobertura y posicionamiento previo quedan para después de M5.
  - **a) hecho — herramientas de mapas:** los nodos que se colocan en un mapa son `@tool`: se acomodan solos a su casilla en el editor, el encuentro dibuja su zona y cada uno avisa en el árbol de escena lo que está mal (`ValidacionMapa`). Escenas listas para arrastrar en `scenes/world/objetos/` y plantilla `scenes/world/mapas/plantilla_mapa.tscn`. Nuevo `DisparadorDialogo` (archivo, título, condición validada como expresión sobre `estado`, una vez); el diálogo en sí llega en b. Test de todos los mapas del catálogo con los mismos avisos, más un mapa roto a propósito. Guía: `docs/guia_mapas.md`.
  - **b) hecho — diálogos:** Dialogue Manager 4.1.0 (versión para Godot 4.7 según el repositorio oficial; licencia MIT en `addons/dialogue_manager/`). El plugin registra su propio autoload `DialogueManager` (dependencia aprobada con el plugin). `CajaDialogo` propia con el `EstiloHud` (nombre, texto, lugar para retrato, respuestas en gris con el motivo de la etiqueta `[#motivo=...]`). `ContextoDialogo` es `estado` en los diálogos y en las condiciones de los disparadores: `tiene_integrado`, `vio_recuerdo`, `destino`, `companero_vivo`, `vio_sueno`, `tiene_marca`, `marcar`, `comerciar`. `GameState.marcas` (entra en el guardado); si un diálogo cambia algo, se autoguarda. Diálogos de prueba TODO_LORE en `dialogue/tasador.dialogue` (presentación y charla) y `dialogue/companeros.dialogue` ("Hablar con…" en el punto estable, solo compañeros vivos).
    - Decidido (Tasador, para b): el primer click abre su diálogo de presentación (obligatorio); después, click abre el comercio directo, con un botón "Hablar". Se registra en GameState si ya se habló con él (entra en el guardado).
  - **c) hecho — exportación web** (`docs/export_web.md`): plantillas oficiales 4.7.2 (SHA-512 verificado), preset Web sin hilos. Probado solo en local (Chrome y Firefox): renderer, guardado persistente en el navegador, pantalla completa (botón en inicio y exploración) y carga. Banco de rendimiento (`scenes/debug/banco_rendimiento.tscn`, `?banco` en web): `PrevisionTurno` por debajo de 16 ms por decisión en todos los casos (combate ~4,5 ms; peor caso sintético hasta 13,7 ms en Chrome). Tamaño: 40,6 MB sin comprimir, 10,7 MB gzip, 7,7 MB brotli (el motor es casi todo).
  - **M5-prep cerrado (2026-09-28).** Resumen:
    - **Mapas desde el editor:** nodos `@tool` que se acomodan a su casilla y avisan lo que está mal (`ValidacionMapa`, la misma que usa el test de los mapas del catálogo), escenas para arrastrar, plantilla de mapa y guía (`docs/guia_mapas.md`).
    - **Diálogos:** Dialogue Manager 4.1.0 (autoload `DialogueManager` como excepción documentada), caja propia con el `EstiloHud`, contexto `estado` para condiciones y mutaciones, marcas en el guardado, Tasador con presentación obligatoria y "Hablar", "Hablar con…" en el punto estable, disparadores de diálogo con condición y una vez.
    - **Web:** export funcional y medido, pantalla completa, guardado en el navegador, sin bloqueos; créditos de terceros en `docs/creditos.md`.
    - Capturas en `docs/capturas/m5prep/` (01 a 11).
  - **Pendientes que deja M5-prep:**
    - Pantalla de créditos en el juego (aviso ORC, Godot y sus componentes, Dialogue Manager).
    - Retratos en la caja de diálogo (el lugar está reservado).
    - Medir FPS fuera de la sesión remota (acá todo topa en ~30) y en máquinas modestas; evaluar un build del motor a medida si el tamaño molesta.
    - Contenido real de los diálogos (todo `TODO_LORE`).
- **Después de M4 (pedido 2026-09-28):** créditos, cobertura y posicionamiento previo (plan aprobado; verificación en `docs/verificacion/cobertura.md`).
  - **Créditos hecho:** `PantallaCreditos` desde el inicio (aviso ORC en borrador, Godot y sus componentes, Dialogue Manager). Ver `docs/creditos.md`.
  - **Cobertura hecho:**
    - **Decidido (A, fiel a PF2e):** se puede apuntar si algún segmento desde la casilla del atacante (centro o esquina) llega a la del objetivo (centro o esquina) sin pasar por pared; la recta de centro a centro decide la cobertura (pared = normal, criatura = menor). Reemplaza la línea de efecto de C4 (centro a centro).
    - `Cobertura` suma el bonificador de circunstancia a la CA del Golpe y del ataque de conjuro; vale la mayor. Tomar cobertura (1 acción, junto a una pared en cruz o con cobertura normal frente a algún enemigo): normal → mayor, si no normal; termina al moverse, atacar o quedar inconsciente.
    - La ficha del objetivo muestra la cobertura frente al que está en turno; el registro la incluye junto a la CA. Capa F3 "Cobertura".
    - **[pendiente]** Terminar Tomar cobertura a voluntad; IA que busque o tome cobertura; bonificadores a Reflejos (áreas) y Sigilo sin uso todavía.
    - Capturas `docs/capturas/cobertura/01` (créditos) a `04`.
  - **Posicionamiento previo hecho:** al dispararse un encuentro, antes de tirar iniciativa, `PosicionamientoPrevio` deja reubicar a cada miembro (click en el miembro y en una casilla resaltada). **Decidido:** hasta 10 pies caminando por la grilla (diagonales 5/10, sin cortar esquinas ni atravesar criaturas), casilla pisable, libre y no al lado de un enemigo (`Posicionamiento`, en rules/). "Empezar combate" termina (u omite) la fase; los enemigos no se mueven.
    - No es una regla de PF2e: representa el instante antes de notarse; la iniciativa (Percepción) no depende de la posición. **Sin sorpresa en el slice** (no hay Evitar ser notado ni iniciativa con Sigilo).
    - Guardado: al dispararse el encuentro (si se cierra durante el posicionamiento, al cargar se vuelve a posicionar desde las casillas guardadas) y después del posicionamiento (el estado previo al primer turno, con el mismo RNG).
    - Capturas `docs/capturas/cobertura/05` a `07`.
- **M5 — Contenido del slice:** mapas, NPCs, diálogos, arte final.

## 9. Preguntas abiertas
- Título del juego.
- Quién fue el Eco original y por qué fue rearmado.
- Qué provocó la Convergencia.
- Facciones principales.
- Qué ascendencias de PF2e entran en el slice (las clases ya están decididas, ver registro).
- Justificación en el lore de la party de 4 (¿otros Ecos? ¿mercenarios?).
- Muerte en party: qué pasa si cae el Eco pero sobreviven los demás, y qué pierden (si algo) los otros miembros al morir.
- Paleta definitiva.
- Guardado (decidido, ver 4.3: una sola ranura). Pendiente: ¿hay puntos estables que se pierden o aparecen con la Convergencia?

## 10. Registro de decisiones
| Fecha | Decisión |
|---|---|
| 2026-09-24 | Motor: Godot 4. |
| 2026-09-24 | Reglas: PF2e Remaster bajo ORC; mundo original. |
| 2026-09-24 | Resolución 640×360, tiles 32×32, vista top-down ¾. |
| 2026-09-24 | Tono: fantasía oscura. Concepto: Convergencia + Marea del Sueño + Eco + recuerdos como moneda. |
| 2026-09-24 | Narrativa ambiental, sin/pocos marcadores, dificultad táctica. |
| 2026-09-24 | Muerte: el Eco se rearma perdiendo recuerdos (no roguelike procedural). |
| 2026-09-24 | Empezar con vertical slice y expandir. |
| 2026-09-24 | El jugador controla la party completa en combate (no solo al Eco). |
| 2026-09-24 | Tests: gdUnit4 (tests parametrizados, útiles para tablas de reglas; corre headless por CLI). |
| 2026-09-24 | Terminología: "ascendencia" (no "ancestría") para *ancestry*. |
| 2026-09-25 | Diálogos: Dialogue Manager (Nathan Hoad). Archivos `.dialogue` en `dialogue/`, condiciones en GDScript sobre el estado del juego. |
| 2026-09-25 | Party: 4 personajes controlados por el jugador. Justificación en el lore: pendiente. |
| 2026-09-25 | Guardado: solo en puntos estables + autoguardado al cambiar de mapa. Sin guardado libre ni en combate. Al morir, el Eco vuelve al último punto estable con recuerdos perdidos. |
| 2026-09-25 | Combate en el mismo mapa de exploración, sin pantalla aparte (estilo BG3). |
| 2026-09-25 | Control en exploración: click con pathfinding (AStarGrid2D, diagonales sin cortar esquinas) + teclado 4 direcciones. |
| 2026-09-25 | Party en fila india en exploración; separable a futuro para posicionarse antes del combate. |
| 2026-09-25 | Placeholders de colores planos permitidos en `assets/placeholder/` (a reemplazar por arte final). |
| 2026-09-25 | Vista isométrica (reemplaza top-down ¾). Rombo 64×32. La grilla lógica sigue siendo cuadrada: isométrico es solo la proyección. |
| 2026-09-25 | Y-sort desde el inicio; paredes en capa propia; transparencia de paredes prevista (sin implementar). |
| 2026-09-25 | Resolución nativa 960×540 (×2 a 1080p), ventana de desarrollo 1920×1080. Contras: web necesita pantalla completa, 1440p con franjas, Steam Deck a evaluar con zoom. |
| 2026-09-25 | Teclado en direcciones de pantalla, 8 direcciones combinando teclas (reemplaza "teclado 4 direcciones"). |
| 2026-09-25 | Personaje placeholder 32×56; tamaño final con el sprite canónico del Eco. |
| 2026-09-25 | Paredes cortadas (zócalo de 16 px) en los bordes que dan a la cámara; fondo del proyecto #0a0a0c; F11 alterna pantalla completa. |
| 2026-09-25 | Transparencia de paredes por tile (no shader), instantánea, sobre una lista genérica de actores visibles (grupo `mantener_visible`). |
| 2026-09-25 | Duración del paso proporcional a la distancia en grilla (diagonal ×√2); seguidores con cola propia de celdas. |
| 2026-09-25 | Glosario de reglas (`docs/GLOSARIO.md`) obligatorio en código, UI y textos. |
| 2026-09-25 | Resources de reglas en `rules/datos/`; `.tres` en `data/`. |
| 2026-09-25 | Bonificadores siempre con tipo; solo los penalizadores pueden ser sin tipo (se suman todos). |
| 2026-09-25 | Las CD derivadas (CA, CD de clase, CD de Percepción) son 10 + el modificador total de su Prueba, con el mismo desglose. |
| 2026-09-25 | Fortuna/infortunio: dos tiradas, mejor/peor; juntos se cancelan. El natural del dado elegido decide el ajuste por 20/1. |
| 2026-09-25 | M3 aprobado: flanqueo solo frente a quienes flanquean; excepción del alcance de 10 pies; moribundo/herido completos; sin reacciones; disparador de encuentro genérico. |
| 2026-09-25 | IA enemiga: no ataca a personajes caídos (pilar 4: muerte justa). |
| 2026-09-25 | En combate, los oponentes no muertos bloquean el paso; los aliados se atraviesan pero no se termina en su casilla. |
| 2026-09-25 | Encuentro de prueba en el mapa B; el mapa A queda para pruebas de exploración. |
| 2026-09-25 | Inconsciente: -4 de estatus a CA, Percepción y Reflejos. Perfil de IA `remata_caidos` por criatura (por defecto false). |
| 2026-09-25 | ControlParty con modos EXPLORACION/COMBATE: en combate se desconectan la fila india y el aviso de pasos del líder. |
| 2026-09-25 | La IA decide de a una acción; cada acción se anima antes de la siguiente (estado del Combate y mapa siempre sincronizados). |
| 2026-09-25 | Movimiento de varias acciones: un click puede encadenar hasta 3 Zancadas (cada una es una acción separada); previsualización de costo con ◆. |
| 2026-09-25 | **M3 cerrado.** |
| 2026-09-25 | Conjuros del slice (decisión del director, Germán puede vetar): clérigo Lanza divina, Estabilizar, Miedo, Curar; bruja Mal de ojo, Proyectil telequinético (sin objeto suelto), Aturdir, Debilitar, Miedo. Huyendo simplificado: solo movimientos que alejan de la fuente. |
| 2026-09-25 | Reacciones antes del primer turno habilitadas para ambos bandos (opción de ConfigCombate, true por defecto). Conjuros sobre aliados permitidos con otro color; la IA no elige aliados para conjuros dañinos. |
| 2026-09-27 | 1 punto de foco al terminar cada combate (implementado al cerrar M3c). |
| 2026-09-27 | **M3c cerrado.** |
| 2026-09-27 | M4 (recuerdos) diseñado con el director: solo el Eco integra; opciones, no poder bruto; suelto/integrado; destreza/vivencia/del Doliente; capacidad 2 + nivel; economía de trueque con el Tasador (50 % / 100 %); enemigos inconscientes quedan tras la victoria (extraer, perdonar, rematar); muerte del Eco con residuo y pérdida elegida de un integrado; compañeros con muerte permanente. El Eco es el guerrero en el slice. Ver 4.2 y 4.3. |
| 2026-09-25 | Dominios de El Umbral: viaje, sueños y **muerte** (Player Core p. 39, verificado en AoN). Muerte reemplaza a vigilia; vigilia y reposo solo están en *Divine Mysteries*. |
| 2026-09-25 | Clases del slice: guerrero, pícaro, clérigo y bruja (Player Core, Remaster), nivel 1. |
| 2026-09-25 | `remata_caidos`: **decidido**, depende de cada criatura (perfil de IA en `DefinicionCriatura`). |
| 2026-09-25 | Entidad del clérigo del slice: El Umbral (lore en `docs/lore/entidades.md`, datos en `data/entidades/el_umbral.tres`). |
| 2026-09-25 | M3c: ascendencia humana para los 4 builds (placeholder). Recuperación: PG y espacios en puntos estables; 1 punto de foco por combate. Reacciones con aviso pausado [Sí] [No] [Siempre]. Glosario de clases provisorio. |
| 2026-09-25 | Patrón de la bruja: El Rencor (`docs/lore/patrones.md`). Verificación de reglas contra Archives of Nethys antes de implementar cada clase. |
| 2026-09-25 | La party del mundo usa los 4 builds reales (guerrero, pícaro, clérigo, bruja) desde C3 (adelantado de C6 para probar reacciones en el mapa). |
| 2026-09-25 | Reacciones: el Combate pausa tras usar una reacción (`pausar_tras_reacciones`) y la presentación llama a `continuar()` después de animarla (invariante de sincronía). |
| 2026-09-27 | M4: puntos estables, muerte del Eco y de compañeros, fuentes de recuerdos, Tasador, diario y guardado anti-savescum (una ranura, autoguardado en cada cambio irreversible, combate cortado vuelve a empezar). Decisiones en 4.2, 4.3 y 8 (M4). |

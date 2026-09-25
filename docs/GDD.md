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

### 4.2 Recuerdos
- **Comprar:** un recuerdo ajeno otorga competencias, dotes o conocimiento (se apoya en las reglas de reentrenamiento de PF2e).
- **Vender:** perder un recuerdo propio es real. Si vendés el recuerdo de un NPC, esa entrada desaparece del diario y el NPC pasa a ser un desconocido.
- **Lore:** los recuerdos comprados muestran escenas desde el punto de vista de otros. Algunos pueden ser falsos o manipulados.

### 4.3 Muerte del Eco
Al morir, el Eco se rearma con menos recuerdos: pierde algo concreto (un fragmento de lore, una dote, la relación con un NPC). El mundo sigue: los mapas no se regeneran y lo hecho, hecho está.
**[propuesta]** Modo hardcore opcional con muerte permanente, para más adelante.

#### Guardado y puntos estables
- Solo se guarda en **puntos estables**: lugares donde la Convergencia no deforma la realidad.
- Autoguardado al cambiar de mapa.
- Sin guardado libre y sin guardado durante el combate.
- Al morir, el Eco vuelve al **último punto estable** con recuerdos perdidos. El estado del mundo no se revierte: el punto estable define dónde reaparece, no a qué momento se vuelve.
- Implicancia técnica: SaveSystem guarda un estado continuo del mundo (sin "volver atrás") más la referencia al último punto estable visitado. El autoguardado al cambiar de mapa persiste el progreso; no es un punto de reaparición.

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
- **[planificado]** Transparencia de paredes cuando un miembro de la party queda detrás. Por eso las paredes van en una capa propia, separada del suelo.
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
- 3–4 clases jugables, nivel bajo.
- Combate táctico completo con tres acciones.
- 1 mercader de recuerdos, 5–6 recuerdos comprables.
- Pérdida de recuerdos al morir.
- Ciclo día/noche básico (opcional para el slice).

## 8. Hitos técnicos **[propuesta]**
- **M0 — Setup:** proyecto Godot, config de render, estructura de carpetas, git, framework de tests.
- **M1 — Mundo:** tilemap de prueba, movimiento en grilla, cámara, colisiones, transición entre mapas.
- **M2 — Reglas:** motor de tiradas, grados de éxito, stats de personaje desde Resources.
- **M3 — Combate:** iniciativa, turnos, tres acciones, ataque/movimiento/condiciones básicas, IA enemiga simple.
- **M4 — Recuerdos:** inventario de recuerdos, compra/venta, diario, pérdida al morir.
- **M5 — Contenido del slice:** mapas, NPCs, diálogos, arte final.

## 9. Preguntas abiertas
- Título del juego.
- Quién fue el Eco original y por qué fue rearmado.
- Qué provocó la Convergencia.
- Facciones principales.
- Qué ascendencias y clases de PF2e entran en el slice.
- Justificación en el lore de la party de 4 (¿otros Ecos? ¿mercenarios?).
- Muerte en party: qué pasa si cae el Eco pero sobreviven los demás, y qué pierden (si algo) los otros miembros al morir.
- Paleta definitiva.
- Guardado (decidido, ver 4.3). Pendiente: ¿un único slot por partida (evita cargar partidas viejas para deshacer pérdidas) o varios? ¿Hay puntos estables que se pierden o aparecen con la Convergencia?

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

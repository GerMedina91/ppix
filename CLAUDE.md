# CLAUDE.md

RPG táctico de fantasía oscura en pixel art, no lineal, con reglas de Pathfinder 2e Remaster (licencia ORC).
El diseño completo está en `docs/GDD.md`. Consultalo antes de implementar cualquier mecánica o contenido.

## Stack
- Motor: Godot 4.x (última estable). Lenguaje: GDScript con tipado estático siempre (`var hp: int`, `func f() -> void`).
- Tests: gdUnit4 (`addons/gdUnit4`). La lógica de reglas se testea sin escenas. Correr todos: `pwsh tests/run_tests.ps1` (usa `GODOT_BIN` o la instalación en `%LOCALAPPDATA%\Programs\Godot`).
- Control de versiones: git. Un commit por feature o cambio coherente, con mensaje descriptivo en español.

## Configuración de render (no modificar sin consultar)
- Resolución nativa: 960×540. Stretch mode `viewport`, aspect `keep`, escalado entero. Ventana de desarrollo 1920×1080 (×2).
- Texture filter por defecto: `Nearest`. Sin mipmaps. Snap 2D de transforms y vértices a píxel activado.
- Tiles isométricos en rombo de 64×32 px (TileSet isométrico, layout Diamond Down). 1 celda = 5 pies (casilla de PF2e).
- La lógica es una grilla cuadrada (`GrillaMapa`); isométrico es solo la proyección. Nada de reglas en coordenadas de pantalla.
- Personajes: placeholder 32×56 px, con los pies en el centro del rombo; tamaño final a definir con el sprite canónico del Eco. Retratos de diálogo: 96–128 px (capa de UI aparte).
- Vista isométrica.
- Y-sort activo desde el principio: party, paredes y objetos comparten una jerarquía con `y_sort_enabled`. El suelo se dibuja debajo, sin y-sort.
- Paredes en su propia capa, separada del suelo, para poder hacerlas transparentes cuando la party pasa detrás (previsto, no implementado).

## Estructura de carpetas
```
res://
  core/        # autoloads mínimos: GameState, EventBus, SaveSystem
  rules/       # motor de reglas PF2e: lógica pura, SIN nodos ni escenas
  data/        # Resources (.tres): clases, ascendencias, dotes, items, conjuros, monstruos, recuerdos
  scenes/      # escenas por dominio: world/, combat/, ui/, characters/
  scripts/     # scripts de escena (presentación)
  assets/      # sprites, tilesets, audio, fuentes (NO editar ni generar sin pedido explícito)
  dialogue/    # diálogos (formato a definir)
  tests/
  addons/      # plugins de terceros (gdUnit4, Dialogue Manager). No editar a mano.
docs/
  GDD.md
```

## Arquitectura
- Separación estricta: `rules/` calcula (tiradas, grados de éxito, acciones, condiciones); las escenas solo presentan y envían intenciones.
- Todo el contenido de juego (stats, items, dotes, recuerdos) vive en `data/` como Resources. Nada de números mágicos en scripts.
- Comunicación entre sistemas por señales o `EventBus`. Evitar referencias directas entre escenas lejanas.
- Autoloads: solo los listados en `core/`. No agregar nuevos sin consultar.
- RNG centralizado y con semilla, para poder reproducir combates en tests.

## Convenciones
- Archivos y carpetas: `snake_case`. `class_name`: `PascalCase`. Constantes: `UPPER_SNAKE_CASE`.
- Comentarios y nombres de dominio en español; API de Godot en inglés como corresponde.
- Funciones cortas. Si un script pasa de ~300 líneas, proponer división.

## Reglas de trabajo
- Trabajar por features chicas y verificables. Al terminar cada una: explicar cómo probarla en el editor.
- Antes de cambios de arquitectura, de configuración del proyecto o de dependencias: proponer y esperar confirmación.
- No inventar lore, nombres ni diálogos. Si falta contenido, usar placeholders marcados `TODO_LORE`.
- Si una decisión de implementación afecta el diseño, anotarla en `docs/GDD.md` → "Registro de decisiones".

## PF2e y licencia
- Usar únicamente reglas de los libros Remaster (Player Core, Player Core 2, GM Core, Monster Core). Nada pre-Remaster (OGL).
- Prohibido usar material reservado de Paizo: Golarion, sus dioses, regiones, personajes, organizaciones, ni nombres propios del setting. Si un item/conjuro/dote nombra algo del setting, se usa la mecánica con otro nombre.
- No usar la marca "Pathfinder" en textos del juego.
- Mantener `docs/ORC_ATTRIBUTION.md` con el aviso de atribución requerido (a completar antes de publicar).

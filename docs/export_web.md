# Exportación web (HTML5)

Build de prueba para navegador. **No se sube a ningún sitio**: se prueba con un servidor local.

## Requisitos
- Plantillas de exportación de Godot **4.7.2**, bajadas del sitio oficial
  (`https://godotengine.org/download/archive/4.7.2-stable/` → *Export templates*) y verificadas con el
  `SHA512-SUMS.txt` oficial. Se instalan desde el editor (*Editor → Administrar plantillas de exportación →
  Instalar desde archivo*) o descomprimiendo el `.tpz` en `%APPDATA%\Godot\export_templates\4.7.2.stable\`.
- Renderer **Compatibility** (el del proyecto): es el único que funciona en web.

## Preset
`export_presets.cfg`, preset **Web**:
- Sin hilos (`variant/thread_support=false`): no hacen falta las cabeceras COOP/COEP en el servidor.
- Excluye `tests/`, `reports/`, `docs/` y `addons/gdUnit4/`.
- Salida: `build/web/index.html` (`build/` está en `.gitignore`).

## Generar el build
Una sola vez, para que el editor no importe lo que se exporta (si no, las imágenes del build se importan y
podrían entrar al paquete): crear `build/.gdignore` (vacío). El preset además excluye `build/*`.
```
"%LOCALAPPDATA%\Programs\Godot\Godot_v4.7.2-stable_win64_console.exe" --headless --path . --export-release "Web" build/web/index.html
```
(`--export-debug` para un build con depuración.)

## Probarlo localmente
```
python -m http.server 8060 --directory build/web
```
y abrir `http://localhost:8060/` en el navegador. Abrir `index.html` directo del disco no funciona (el navegador
bloquea la carga del `.wasm` y del `.pck` desde `file://`).

## Prueba mínima (2026-09-28, M5-prep b)
Chromium (Playwright) contra el servidor local, ventana de 1100×700:
- **Renderer:** WebGL 2.0, Compatibility, un solo hilo. Sin errores en la consola.
- **Guardado:** Nueva partida → autoguardado → recargar la página → "Continuar" habilitado → carga bien. El
  `user://` del navegador (IndexedDB) persiste entre recargas y la escritura atómica (temporal + renombrado)
  funciona.
- **Escala:** en la ventana del navegador queda a ×1 con franjas negras (esperado, ver GDD 5).
- **Tamaño:** `index.wasm` 39,5 MB (el motor), `index.pck` 0,78 MB (el juego), ~40 MB en total sin comprimir.
- Capturas: `docs/capturas/m5prep/07` a `10`.

## Problemas encontrados
- **Dialogue Manager trae archivos C# y escenas de ejemplo** que en un proyecto sin .NET fallan al exportar
  (`No loader found for resource: *.cs`). Se excluyen `*.cs`, `addons/dialogue_manager/example_balloon/*` y
  `addons/dialogue_manager/nodes/*` (el juego usa su propia caja de diálogo).
- **No excluir `addons/dialogue_manager/test_scene.tscn`:** `settings.gd` del plugin la precarga; sin ella el
  autoload `DialogueManager` no compila en el navegador (se probó).
- **`build/` dentro del proyecto:** el editor importaba las imágenes del build (`.import`). Se resuelve con
  `build/.gdignore` y `build/*` en el filtro de exclusión.

## Prueba completa (2026-09-28, M5-prep c)
Máquina de desarrollo (sesión remota: la pantalla limita todo a ~30 FPS, también en escritorio). "Chrome" es el
Chromium de Playwright; Firefox 146 sin ventana (`-headless`, perfil temporal). Resultados del banco de
rendimiento.

### Banco de rendimiento
`scenes/debug/banco_rendimiento.tscn`: en web se abre con `?banco` en la URL; en escritorio, corriendo la escena.
Mide `PrevisionTurno` (la operación más pesada: alcance por Zancadas y Golpes) en el peor caso sintético
(actor con Velocidad 30 en el centro del mapa B, rodeado; 20 cálculos) y en 12 decisiones reales del combate
de prueba (5 cálculos cada una), y los FPS. Muestra el resumen en pantalla y lo manda al servidor local
(`GET /banco?...`, queda en su registro; el 404 es esperado).

| PrevisionTurno (ms) | Combate: media / máx | Peor caso: media / máx |
|---|---|---|
| Escritorio (Windows) | 4,07 / 6,75 | 5,19 / 5,48 |
| Chrome (web) | 4,50 / 6,60 | 7,87 / 13,70 |
| Firefox (web, sin ventana) | 4,32 / 6,00 | 8,20 / 12,00 |

- **Por debajo de ~16 ms por decisión en todos los casos** (el umbral pedido): no hace falta optimizar ahora.
  El peor caso en web tarda ~1,5× lo de escritorio y tiene picos (13,7 ms en Chrome).
- Firefox redondea los tiempos a 1 ms (reduce la precisión de los temporizadores).
- **FPS:** combate 29 de media (mín. 26) en Chrome y 28 (mín. 23) en Firefox; escritorio 31. Todo topa en ~32
  por la sesión remota, así que no mide el techo real. Los mínimos de 1-2 FPS en exploración son el cambio de
  mapa (fundido y carga).

### Pantalla completa
Botón "Pantalla completa" en la pantalla de inicio y en la exploración (arriba a la derecha). En Chrome entra y
sale con clicks reales; el navegador solo lo acepta desde una acción del jugador (por eso es un botón).

### Tamaño
| Archivo | Sin comprimir | gzip | brotli |
|---|---|---|---|
| `index.wasm` (motor) | 39,51 MB | 10,05 MB | 7,10 MB |
| `index.pck` (juego) | 0,78 MB | 0,54 MB | 0,52 MB |
| Total | 40,6 MB | 10,7 MB | 7,7 MB |

Lo que se descarga depende de que el servidor comprima (gzip o brotli). El motor es casi todo: un build del
motor a medida (sin 3D ni módulos que no se usan) podría achicarlo, a evaluar si hace falta.

## Banco después de la cobertura (2026-09-28)
La visión nueva (decisión A: hasta 25 segmentos entre centros y esquinas por par) se volvió a medir:

| PrevisionTurno (ms) | Combate: media / máx | Peor caso: media / máx |
|---|---|---|
| Escritorio (Windows) | 3,88 / 4,68 | 5,06 / 5,25 |
| Chrome (web) | 4,51 / 5,90 | 7,35 / **15,90** |
| Firefox (web, sin ventana) | 4,50 / 6,00 | 8,15 / 14,00 |

- Sigue por debajo de ~16 ms, pero el pico del peor caso en Chrome (15,9 ms, un solo cálculo de 20; mediana
  6,3) quedó al borde. Las medias casi no cambiaron: el costo nuevo aparece solo cuando hay paredes entre las
  casillas. Sin optimizar (a la espera del director).

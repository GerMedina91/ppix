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

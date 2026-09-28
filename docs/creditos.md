# Créditos y licencias de terceros

Software de terceros que va dentro del build del juego y los avisos que hay que mostrar. Referenciado desde
`docs/ORC_ATTRIBUTION.md` (checklist antes de publicar). Los avisos tienen que aparecer **dentro del juego**
(pantalla de créditos), no solo en este documento.

## En el build

### Godot Engine 4.7.2 — licencia MIT
- Texto: `LICENSE.txt` del repositorio oficial (`https://github.com/godotengine/godot/blob/4.7.2-stable/LICENSE.txt`).
- Aviso: *Copyright (c) 2014-present Godot Engine contributors (see AUTHORS.md). Copyright (c) 2007-2014 Juan
  Linietsky, Ariel Manzur.* + el texto de la licencia MIT.
- **Componentes de terceros del motor** (FreeType, ENet, mbedTLS, etc.; 107 entradas en el `COPYRIGHT.txt` de
  4.7.2, cada una con su licencia): van en el build y también hay que mostrarlos. El motor los expone en tiempo
  de ejecución (`Engine.get_copyright_info()`, `Engine.get_license_info()`, `Engine.get_license_text()`), así que
  la pantalla de créditos los puede listar sin copiarlos a mano.
- Guía oficial: `https://docs.godotengine.org/en/stable/about/complying_with_licenses.html`.

### Dialogue Manager 4.1.0 (Nathan Hoad) — licencia MIT
- Texto: `addons/dialogue_manager/LICENSE`.
- Aviso: *Copyright (c) 2022-present Nathan Hoad and Dialogue Manager contributors.* + el texto de la licencia MIT.

## No va en el build
- **gdUnit4** (MIT, Mike Schulze): solo para tests; el preset de exportación excluye `addons/gdUnit4/`.
- Plantillas de exportación de Godot: son el motor (cubiertas arriba).

## En el juego
- **Pantalla de créditos** (`PantallaCreditos`, botón "Créditos" en la pantalla de inicio): aviso ORC
  (`data/creditos/orc_aviso.txt`, borrador), Godot con su licencia y sus componentes (desde
  `Engine.get_license_text()`, `get_copyright_info()` y `get_license_info()`), Dialogue Manager
  (`data/creditos/dialogue_manager_licencia.txt`). El preset web incluye `data/creditos/*.txt`.

## Pendiente
- Créditos propios (equipo, arte, música): TODO_LORE.
- Revisar esta lista cada vez que se sume un plugin, una fuente tipográfica, audio o arte de terceros.

# Placeholders

Assets provisorios de colores planos. **Reemplazar por arte final.**

- `iso_suelo.png`: rombos isométricos de 64×32 → (0,0) suelo, (1,0) salida.
- `iso_pared.png`: bloque de pared de 64×96 (tapa, 64 px de cara, huella del rombo abajo).
- `tileset_iso_placeholder.tres`: TileSet isométrico (Diamond Down, 64×32) con la capa de datos `transitable` (bool).
  La pared tiene `texture_origin = (0, 32)` para que la huella del bloque coincida con su celda.

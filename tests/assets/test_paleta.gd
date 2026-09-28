extends GdUnitTestSuite
## Todo el arte usa estrictamente la paleta "Lumbre" (docs/arte/direccion.md): cada píxel no transparente de cada
## PNG de assets/ (salvo assets/placeholder/) tiene que ser uno de sus 42 colores. Informa archivo y color.

const PALETA: String = "res://assets/paleta/paleta_lumbre.hex"
const RAIZ: String = "res://assets"
const EXCLUIDA: String = "res://assets/placeholder"
const COLORES_DE_LA_PALETA: int = 42


static func paleta() -> Dictionary[String, bool]:
	var colores: Dictionary[String, bool] = {}
	for linea: String in FileAccess.get_file_as_string(PALETA).split("\n", false):
		colores[linea.strip_edges().to_lower()] = true
	return colores


## Colores (hex) fuera de la paleta en la imagen -> cantidad de píxeles.
static func colores_fuera(imagen: Image, colores: Dictionary[String, bool]) -> Dictionary[String, int]:
	var fuera: Dictionary[String, int] = {}
	if imagen.is_compressed():
		imagen.decompress()
	for y in imagen.get_height():
		for x in imagen.get_width():
			var color: Color = imagen.get_pixel(x, y)
			if color.a8 == 0:
				continue
			var hexa: String = color.to_html(false).to_lower()
			if not colores.has(hexa):
				fuera[hexa] = fuera.get(hexa, 0) + 1
	return fuera


static func _pngs(carpeta: String) -> Array[String]:
	var lista: Array[String] = []
	if carpeta == EXCLUIDA:
		return lista
	for archivo: String in DirAccess.get_files_at(carpeta):
		if archivo.get_extension().to_lower() == "png":
			lista.append(carpeta.path_join(archivo))
	for sub: String in DirAccess.get_directories_at(carpeta):
		lista.append_array(_pngs(carpeta.path_join(sub)))
	return lista


func test_la_paleta_tiene_42_colores() -> void:
	assert_int(paleta().size()).is_equal(COLORES_DE_LA_PALETA)


func test_todo_png_de_assets_usa_solo_la_paleta() -> void:
	var colores: Dictionary[String, bool] = paleta()
	var errores: PackedStringArray = PackedStringArray()
	for ruta: String in _pngs(RAIZ):
		var imagen: Image = Image.load_from_file(ProjectSettings.globalize_path(ruta))
		if imagen == null:
			errores.append("%s: no se pudo leer" % ruta)
			continue
		var fuera: Dictionary[String, int] = colores_fuera(imagen, colores)
		for hexa: String in fuera:
			errores.append("%s: #%s (%d píxeles)" % [ruta, hexa, fuera[hexa]])
	assert_array(Array(errores)).override_failure_message("Colores fuera de la paleta:\n" + "\n".join(errores)).is_empty()


func test_el_control_detecta_un_color_fuera_y_ignora_lo_transparente() -> void:
	var imagen: Image = Image.create(2, 2, false, Image.FORMAT_RGBA8)
	imagen.set_pixel(0, 0, Color.html("#0b0a0f"))
	imagen.set_pixel(1, 0, Color.html("#ff00ff"))
	imagen.set_pixel(0, 1, Color(1, 0, 1, 0))  # transparente: no cuenta
	imagen.set_pixel(1, 1, Color.html("#f4eee2"))
	assert_dict(colores_fuera(imagen, paleta())).is_equal({"ff00ff": 1})

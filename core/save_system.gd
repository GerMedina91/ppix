extends Node
## Guardado en disco (GDD 4.3, M4g): una sola ranura, JSON con versión, escritura atómica.
##
## Reglas (anti-savescum: una sola ranura y un mundo que no retrocede):
## - Se guarda al descansar en un punto estable, al cambiar de mapa y enseguida después de cada cambio
##   irreversible (EventBus.cambio_irreversible): muerte y rearmado del Eco, compra y venta en el Tasador,
##   integrar / soltar / ver recuerdos, tomar un recuerdo, destino de un enemigo inconsciente, fin de un combate.
## - Al empezar un combate se guarda el estado previo al primer turno (GameState.combate_pendiente): si el
##   jugador cierra en medio, al cargar ese combate vuelve a empezar (no se vuelve a antes del encuentro).
## - No hay guardado libre. El punto estable define dónde reaparece el Eco, no a qué momento se vuelve.
## - Escritura atómica: se escribe un temporal y se renombra; si el cierre llega antes del renombrado, la
##   carga usa el temporal (si está completo).
## - Mientras corren los tests (gdUnit) se usa otra ranura, para no pisar la partida real.

const RUTA: String = "user://partida.json"
const RUTA_TESTS: String = "user://partida_tests.json"
const SUFIJO_TEMPORAL: String = ".tmp"
const CATALOGO_RECUERDOS: String = "res://data/recuerdos/catalogo_recuerdos.tres"

## Ranura en uso (la de tests si corre gdUnit).
var ruta: String = RUTA


func _ready() -> void:
	if " ".join(OS.get_cmdline_args()).contains("gdUnit4"):
		ruta = RUTA_TESTS
	EventBus.mapa_cambiado.connect(func(_id: StringName) -> void: autoguardar())
	EventBus.punto_estable_activado.connect(guardar_en_punto_estable)
	EventBus.cambio_irreversible.connect(func(_motivo: String) -> void: autoguardar())


func hay_partida() -> bool:
	return _leer(ruta) != null or _leer(ruta + SUFIJO_TEMPORAL) != null


## Guarda al descansar en un punto estable (el Mundo ya lo registró como punto de reaparición).
func guardar_en_punto_estable(_id_punto: StringName) -> void:
	guardar()


func autoguardar() -> void:
	guardar()


## Pide al mundo que anote dónde está la party y escribe la ranura. Devuelve si pudo.
func guardar() -> bool:
	EventBus.antes_de_guardar.emit()
	var texto: String = JSON.stringify(GameState.a_diccionario(), "\t")
	var temporal: String = ruta + SUFIJO_TEMPORAL
	var archivo: FileAccess = FileAccess.open(temporal, FileAccess.WRITE)
	if archivo == null:
		push_error("SaveSystem: no se pudo escribir %s (%s)" % [temporal, error_string(FileAccess.get_open_error())])
		return false
	archivo.store_string(texto)
	archivo.close()
	var destino: String = ProjectSettings.globalize_path(ruta)
	var error: Error = DirAccess.rename_absolute(ProjectSettings.globalize_path(temporal), destino)
	if error != OK and FileAccess.file_exists(ruta):
		# Si el sistema no reemplaza al renombrar: se borra la vieja; hasta el renombrado vale el temporal.
		DirAccess.remove_absolute(destino)
		error = DirAccess.rename_absolute(ProjectSettings.globalize_path(temporal), destino)
	if error != OK:
		push_error("SaveSystem: no se pudo renombrar el guardado (%s)" % error_string(error))
		return false
	return true


## Carga la ranura en GameState. Devuelve false si no hay partida, está dañada o es de una versión futura.
func cargar() -> bool:
	var datos: Variant = _leer(ruta)
	if datos == null:
		datos = _leer(ruta + SUFIJO_TEMPORAL)  # cierre entre la escritura y el renombrado
	if datos == null:
		return false
	var migrados: Variant = migrar(datos)
	if migrados == null:
		return false
	GameState.cargar_diccionario(migrados, load(CATALOGO_RECUERDOS))
	GameState.recien_cargada = not GameState.ubicacion.is_empty()
	return true


## Borra la ranura (nueva partida).
func borrar() -> void:
	for archivo: String in [ruta, ruta + SUFIJO_TEMPORAL]:
		if FileAccess.file_exists(archivo):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(archivo))


## Punto de entrada para migraciones: lleva un guardado viejo a la versión actual (null si no se puede).
## Cada versión nueva suma un paso `_migrar_desde_N` que deja los datos en la N + 1.
static func migrar(datos: Dictionary) -> Variant:
	var version: int = int(datos.get("version", 0))
	if version > GameState.VERSION_GUARDADO or version < 1:
		push_error("SaveSystem: versión de guardado no soportada (%d)" % version)
		return null
	# while version < GameState.VERSION_GUARDADO: datos = call("_migrar_desde_%d" % version, datos); version += 1
	return datos


## El contenido de `archivo` si es un JSON completo (un diccionario); si no, null.
static func _leer(archivo: String) -> Variant:
	if not FileAccess.file_exists(archivo):
		return null
	var json: JSON = JSON.new()
	if json.parse(FileAccess.get_file_as_string(archivo)) != OK:
		return null
	return json.data if json.data is Dictionary else null

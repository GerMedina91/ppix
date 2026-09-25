class_name ValidacionDatos
extends RefCounted
## Validación de los Resources de reglas al cargarlos. Cada Resource declara sus reglas en
## `errores_de_datos() -> PackedStringArray`. Los errores se informan con push_error
## (funciona también en release) y el recurso inválido no se usa.

const METODO: StringName = &"errores_de_datos"


## Carga y valida. Devuelve null (con push_error) si no se puede cargar o si tiene datos inválidos.
static func cargar(ruta: String) -> Resource:
	var recurso: Resource = load(ruta)
	if recurso == null:
		push_error(mensaje(ruta, "no se pudo cargar"))
		return null
	if not validar(recurso).is_empty():
		return null
	return recurso


## Valida un recurso ya cargado. Informa cada error con push_error y los devuelve.
static func validar(recurso: Resource) -> PackedStringArray:
	var errores: PackedStringArray = PackedStringArray()
	if recurso.has_method(METODO):
		errores = recurso.call(METODO)
	var ruta: String = recurso.resource_path if not recurso.resource_path.is_empty() else str(recurso)
	for error: String in errores:
		push_error(mensaje(ruta, error))
	return errores


static func mensaje(ruta: String, error: String) -> String:
	return "Datos inválidos en %s: %s" % [ruta, error]

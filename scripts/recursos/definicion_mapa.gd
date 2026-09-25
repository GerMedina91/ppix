class_name DefinicionMapa
extends Resource
## Datos de un mapa del mundo. La escena se carga recién al entrar al mapa.

@export var id: StringName = &""
@export_file("*.tscn") var ruta_escena: String = ""

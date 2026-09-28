@tool
class_name DisparadorDialogo
extends Interactuable
## Algo del mapa que abre un diálogo de Dialogue Manager al hacerle click (un personaje, un objeto que
## "habla"). Se configura desde el inspector: archivo `.dialogue` de dialogue/, título donde empieza y una
## condición opcional (expresión de GDScript sobre `estado`, el contexto de diálogo; vacía = siempre).
## El diálogo en sí llega con M5-prep b; hasta entonces avisa en pantalla.

@export_file("*.dialogue") var dialogo: String = "":
	set(valor):
		dialogo = valor
		update_configuration_warnings()
## Título del .dialogue donde empieza (la línea `~ titulo`).
@export var titulo: String = "inicio":
	set(valor):
		titulo = valor
		update_configuration_warnings()
## Expresión que decide si responde (p. ej. `estado.companero_vivo("Miembro2")`). Vacía = siempre.
@export var condicion: String = "":
	set(valor):
		condicion = valor
		update_configuration_warnings()
## Si responde una sola vez por partida.
@export var una_vez: bool = false


func _get_configuration_warnings() -> PackedStringArray:
	var avisos: PackedStringArray = super()
	if dialogo.is_empty():
		avisos.append("Falta el archivo de diálogo (.dialogue en dialogue/).")
	elif not FileAccess.file_exists(dialogo):
		avisos.append("No existe el archivo de diálogo '%s'." % dialogo)
	if titulo.strip_edges().is_empty():
		avisos.append("Falta el título donde empieza el diálogo.")
	var error: String = ValidacionMapa.error_de_condicion(condicion)
	if error != "":
		avisos.append("La condición no es una expresión válida: %s" % error)
	return avisos

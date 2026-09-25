class_name DefinicionModificador
extends Resource
## Modificador definido en datos (p. ej. el de una condición o un objeto). Se convierte en Modificador con crear().

@export var valor: int = 0
@export var tipo: Modificador.Tipo = Modificador.Tipo.CIRCUNSTANCIA
## Texto del desglose (p. ej. "Flanqueado"). Obligatorio.
@export var fuente: String = ""


func errores_de_datos() -> PackedStringArray:
	var errores: PackedStringArray = PackedStringArray()
	var error_regla: String = Modificador.error_de_datos(valor, tipo, fuente)
	if not error_regla.is_empty():
		errores.append(error_regla)
	if fuente.strip_edges().is_empty():
		errores.append("Modificador sin fuente: el desglose necesita un nombre")
	return errores


func crear() -> Modificador:
	return Modificador.new(valor, tipo, fuente)

class_name BeneficioDote
extends BeneficioRecuerdo
## Una dote general o de habilidad, como capacidad (p. ej. Medicina en batalla, Duro de matar). Puede pedir
## estar entrenado en una habilidad (requisito de la dote).

@export var dote: Capacidad
## Habilidad en la que hay que estar entrenado (si `requiere_habilidad`).
@export var requiere_habilidad: bool = false
@export var habilidad_requerida: Habilidad.Tipo = Habilidad.Tipo.MEDICINA


func aplicar(personaje: DefinicionPersonaje) -> void:
	if not ya_lo_tiene(personaje):
		personaje.capacidades.append(dote)


func ya_lo_tiene(personaje: DefinicionPersonaje) -> bool:
	return personaje.capacidades.any(func(c: Capacidad) -> bool: return c.id == dote.id)


func motivo_requisitos(personaje: DefinicionPersonaje) -> String:
	if requiere_habilidad and personaje.habilidades.get(habilidad_requerida, Competencia.Rango.NO_ENTRENADO) < Competencia.Rango.ENTRENADO:
		return "requiere estar entrenado en %s" % Habilidad.nombre(habilidad_requerida)
	return ""


func descripcion() -> String:
	return dote.nombre if dote != null else ""


func errores_de_datos() -> PackedStringArray:
	var errores: PackedStringArray = PackedStringArray()
	if dote == null:
		errores.append("Beneficio de dote sin dote")
	return errores

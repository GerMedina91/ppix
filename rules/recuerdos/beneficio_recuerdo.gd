class_name BeneficioRecuerdo
extends Resource
## Lo que da un recuerdo de destreza integrado en el Eco. Principio de diseño (GDD 4.2): opciones, no poder
## bruto; nunca bonificadores numéricos directos. Subclases: BeneficioHabilidad, BeneficioDote.


## Suma el beneficio al personaje armado (ArmadorPersonaje, con los recuerdos integrados del Eco).
func aplicar(_personaje: DefinicionPersonaje) -> void:
	pass


## true si el personaje ya tiene lo que daría (integrarlo no sumaría nada).
func ya_lo_tiene(_personaje: DefinicionPersonaje) -> bool:
	return false


## Por qué no se puede integrar en ese personaje ("" si se puede): requisitos del beneficio.
func motivo_requisitos(_personaje: DefinicionPersonaje) -> String:
	return ""


## Texto corto para la interfaz ("Entrenado en Medicina").
func descripcion() -> String:
	return ""


func errores_de_datos() -> PackedStringArray:
	return PackedStringArray()

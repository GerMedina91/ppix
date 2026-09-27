class_name DefinicionRecuerdo
extends Resource
## Un recuerdo (GDD 4.2). Suelto es un objeto comerciable; integrado es parte del Eco.
## - Destreza: beneficio mecánico (BeneficioRecuerdo); ocupa capacidad de integrados.
## - Vivencia: escena de lore; al verla se consume y queda en el diario; no ocupa capacidad.
## - Del Doliente: vivencia especial de trama; nunca se pierde ni se vende; no ocupa capacidad.

enum Tipo { DESTREZA, VIVENCIA, DOLIENTE }

@export var id: StringName = &""
@export var nombre: String = "TODO_LORE"
@export var tipo: Tipo = Tipo.DESTREZA
## Valor para el trueque (el Tasador compra al 50 % y vende al 100 %; ver ConfigRecuerdos).
@export var valor: int = 10
@export var beneficio: BeneficioRecuerdo
## Escena de la vivencia (o descripción del recuerdo de destreza).
@export_multiline var texto: String = "TODO_LORE"


func es_destreza() -> bool:
	return tipo == Tipo.DESTREZA


## Vivencias y fragmentos del Doliente: se "ven" (se consumen y van al diario).
func se_ve() -> bool:
	return tipo != Tipo.DESTREZA


func vendible() -> bool:
	return tipo != Tipo.DOLIENTE


func errores_de_datos() -> PackedStringArray:
	var errores: PackedStringArray = PackedStringArray()
	if id == &"":
		errores.append("Recuerdo sin id")
	if valor <= 0:
		errores.append("Recuerdo %s: el valor tiene que ser positivo" % id)
	if es_destreza() and beneficio == null:
		errores.append("Recuerdo %s: un recuerdo de destreza necesita un beneficio" % id)
	if not es_destreza() and beneficio != null:
		errores.append("Recuerdo %s: solo los de destreza dan un beneficio" % id)
	if beneficio != null:
		errores.append_array(beneficio.errores_de_datos())
	return errores

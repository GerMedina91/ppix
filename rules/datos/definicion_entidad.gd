class_name DefinicionEntidad
extends Resource
## Entidad a la que sirve un clérigo (el equivalente del mundo propio a una deidad; no se usan deidades
## de Golarion). Mecánica según el Player Core Remaster: fuente divina, arma predilecta, dominios,
## habilidad divina, edictos y anatemas. Lore en docs/lore/entidades.md.

## Fuente divina: los espacios extra de la fuente son de curar o de dañar.
enum FuenteDivina { CURAR, DANAR }

@export var nombre: String = "TODO_LORE"
@export_multiline var descripcion: String = ""
@export var fuente_divina: FuenteDivina = FuenteDivina.CURAR
## Id del arma predilecta (la definición del arma llega con las clases, M3c).
@export var arma_predilecta: StringName = &""
## Ids de dominios verificados en el Player Core Remaster (ver docs/GLOSARIO.md).
@export var dominios: Array[StringName] = []
## Dominios pedidos por diseño que todavía no se verificaron en los libros permitidos.
@export var dominios_a_verificar: Array[StringName] = []
@export var habilidad_divina: StringName = &""
@export var edictos: PackedStringArray = PackedStringArray()
@export var anatemas: PackedStringArray = PackedStringArray()


func errores_de_datos() -> PackedStringArray:
	var errores: PackedStringArray = PackedStringArray()
	if nombre.strip_edges().is_empty():
		errores.append("Entidad sin nombre")
	if dominios.is_empty():
		errores.append("Entidad %s: necesita al menos un dominio verificado" % nombre)
	if edictos.is_empty() or anatemas.is_empty():
		errores.append("Entidad %s: necesita edictos y anatemas" % nombre)
	if arma_predilecta == &"" or habilidad_divina == &"":
		errores.append("Entidad %s: faltan arma predilecta o habilidad divina" % nombre)
	return errores

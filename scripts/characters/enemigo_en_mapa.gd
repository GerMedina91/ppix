@tool
class_name EnemigoEnMapa
extends ActorMapa
## Enemigo colocado en el mapa como parte de un Encuentro. Su casilla sale de su posición (en el editor se
## acomoda solo al centro de la casilla).

const COLOR_BORDE: Color = Color(0.1, 0.05, 0.05)

@export var definicion: DefinicionCriatura:
	set(valor):
		definicion = valor
		update_configuration_warnings()
## Recuerdo que lleva este enemigo en particular (se le extrae si queda inconsciente). Vacío: el de su definición.
## Así el reparto de recuerdos es del mapa y la criatura se define una sola vez.
@export var recuerdo: DefinicionRecuerdo


## Lo que el Eco puede extraerle (null = nada).
func recuerdo_extraible() -> DefinicionRecuerdo:
	if recuerdo != null:
		return recuerdo
	return definicion.recuerdo if definicion != null else null


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		set_notify_transform(true)


func _notification(que: int) -> void:
	if que == NOTIFICATION_TRANSFORM_CHANGED and Engine.is_editor_hint():
		ValidacionMapa.centrar(self)
		update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
	var avisos: PackedStringArray = ValidacionMapa.avisos_de_casilla(self)
	if definicion == null:
		avisos.append("Falta la definición de la criatura (data/criaturas/).")
	if not get_parent() is Encuentro:
		avisos.append("Tiene que ser hijo de un Encuentro.")
	if recuerdo != null and not ValidacionMapa.recuerdo_catalogado(recuerdo):
		avisos.append("El recuerdo no está en el catálogo (data/recuerdos/catalogo_recuerdos.tres).")
	return avisos


func _draw() -> void:
	super()
	draw_rect(Rect2(_origen_placeholder(), TAMANO_PLACEHOLDER), COLOR_BORDE, false, 1.0)

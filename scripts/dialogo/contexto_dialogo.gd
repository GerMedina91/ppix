class_name ContextoDialogo
extends RefCounted
## Lo que un diálogo puede consultar y cambiar del estado de la partida. Se pasa a Dialogue Manager como
## `estado` (en los .dialogue: `if estado.tiene_integrado("destreza_medicina")`, `$> estado.marcar("x")`), y
## las condiciones de los DisparadorDialogo lo usan con el mismo nombre. Si un diálogo cambia algo, al
## terminar se autoguarda (cambio irreversible).

## Algo pidió abrir el comercio con el Tasador al terminar el diálogo.
var pidio_comercio: bool = false
## El diálogo cambió el estado de la partida (hay que guardar).
var hubo_cambios: bool = false


func tiene_integrado(id_recuerdo: String) -> bool:
	return GameState.recuerdos.inventario.integrados.any(func(r: DefinicionRecuerdo) -> bool: return r.id == StringName(id_recuerdo))


## Vivencia o fragmento ya visto (en el diario).
func vio_recuerdo(id_recuerdo: String) -> bool:
	return GameState.recuerdos.inventario.vistos.any(func(r: DefinicionRecuerdo) -> bool: return r.id == StringName(id_recuerdo))


## "extraido", "perdonado", "rematado" o "" (id global "mapa/nombre").
func destino(id_enemigo: String) -> String:
	var destinos: Dictionary = GameState.recuerdos.destinos
	if not destinos.has(StringName(id_enemigo)):
		return ""
	return String(EstadoRecuerdos.Destino.keys()[destinos[StringName(id_enemigo)]]).to_lower()


## El compañero (id del miembro, p. ej. "Miembro2") no murió.
func companero_vivo(id_miembro: String) -> bool:
	return not GameState.estado_party.get(StringName(id_miembro), {}).get("muerto", false)


func vio_sueno(id_sueno: String) -> bool:
	return GameState.suenos_vistos.has(StringName(id_sueno))


## Marcas de la partida que ponen los diálogos (p. ej. "tasador_presentado").
func tiene_marca(marca: String) -> bool:
	return GameState.marcas.has(StringName(marca))


func marcar(marca: String) -> void:
	if not tiene_marca(marca):
		GameState.marcas[StringName(marca)] = true
		hubo_cambios = true


## Pide abrir el comercio con el Tasador cuando termine el diálogo.
func comerciar() -> void:
	pidio_comercio = true


## Evalúa la condición de un disparador (expresión sobre `estado`; vacía = true).
func cumple(condicion: String) -> bool:
	if condicion.strip_edges().is_empty():
		return true
	var expresion: Expression = Expression.new()
	if expresion.parse(condicion, ValidacionMapa.NOMBRES_CONDICION) != OK:
		push_error("Condición de diálogo inválida: %s" % condicion)
		return false
	var resultado: Variant = expresion.execute([self], null, false)
	return not expresion.has_execute_failed() and bool(resultado)

class_name InventarioRecuerdos
extends RefCounted
## Recuerdos del Eco (GDD 4.2): sueltos (comerciables), integrados de destreza (dan su beneficio) y vistos
## (vivencias y fragmentos del Doliente, en el diario). Solo el Eco integra; integrar, solo fuera de combate
## (lo controla quien llama).

var sueltos: Array[DefinicionRecuerdo] = []
var integrados: Array[DefinicionRecuerdo] = []
var vistos: Array[DefinicionRecuerdo] = []


func agregar_suelto(recuerdo: DefinicionRecuerdo) -> void:
	sueltos.append(recuerdo)


func quitar_suelto(recuerdo: DefinicionRecuerdo) -> bool:
	var i: int = sueltos.find(recuerdo)
	if i < 0:
		return false
	sueltos.remove_at(i)
	return true


func integrados_de_destreza() -> int:
	return integrados.size()


## Por qué no se puede integrar (o ver) `recuerdo` ("" si se puede). `eco`: el personaje del Eco armado
## con lo que ya tiene; `capacidad`: la de ConfigRecuerdos para su nivel.
func motivo_no_integrable(recuerdo: DefinicionRecuerdo, eco: DefinicionPersonaje, capacidad: int) -> String:
	if not sueltos.has(recuerdo):
		return "no lo tenés suelto"
	if recuerdo.se_ve():
		return ""
	if integrados.size() >= capacidad:
		return "sin capacidad (%d/%d)" % [integrados.size(), capacidad]
	if recuerdo.beneficio.ya_lo_tiene(eco):
		return "ya tenés ese beneficio"
	return recuerdo.beneficio.motivo_requisitos(eco)


## Integra un recuerdo de destreza, o ve una vivencia o un fragmento del Doliente (se consume y va al
## diario). Antes, motivo_no_integrable() == "".
func integrar(recuerdo: DefinicionRecuerdo) -> void:
	quitar_suelto(recuerdo)
	if recuerdo.se_ve():
		if not vistos.has(recuerdo):
			vistos.append(recuerdo)
	else:
		integrados.append(recuerdo)


## Suelta (o pierde al morir) un integrado: se pierde para siempre.
func soltar_integrado(recuerdo: DefinicionRecuerdo) -> bool:
	var i: int = integrados.find(recuerdo)
	if i < 0:
		return false
	integrados.remove_at(i)
	return true


## Sueltos que caen en el residuo al morir el Eco (todos menos los del Doliente, que nunca se pierden).
func sueltos_perdibles() -> Array[DefinicionRecuerdo]:
	var lista: Array[DefinicionRecuerdo] = []
	for r: DefinicionRecuerdo in sueltos:
		if r.tipo != DefinicionRecuerdo.Tipo.DOLIENTE:
			lista.append(r)
	return lista


func a_diccionario() -> Dictionary:
	return {"sueltos": _ids(sueltos), "integrados": _ids(integrados), "vistos": _ids(vistos)}


static func desde_diccionario(datos: Dictionary, catalogo: CatalogoRecuerdos) -> InventarioRecuerdos:
	var inventario: InventarioRecuerdos = InventarioRecuerdos.new()
	inventario.sueltos = resolver(datos.get("sueltos", []), catalogo)
	inventario.integrados = resolver(datos.get("integrados", []), catalogo)
	inventario.vistos = resolver(datos.get("vistos", []), catalogo)
	return inventario


static func _ids(lista: Array[DefinicionRecuerdo]) -> Array[String]:
	var ids: Array[String] = []
	for r: DefinicionRecuerdo in lista:
		ids.append(String(r.id))
	return ids


## Ids -> recuerdos del catálogo (los desconocidos se ignoran con un aviso).
static func resolver(ids: Array, catalogo: CatalogoRecuerdos) -> Array[DefinicionRecuerdo]:
	var lista: Array[DefinicionRecuerdo] = []
	for id: Variant in ids:
		var recuerdo: DefinicionRecuerdo = catalogo.buscar(StringName(id))
		if recuerdo == null:
			push_warning("Recuerdo desconocido al cargar: %s" % id)
		else:
			lista.append(recuerdo)
	return lista

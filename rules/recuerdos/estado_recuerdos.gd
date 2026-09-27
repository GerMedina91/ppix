class_name EstadoRecuerdos
extends RefCounted
## Todo lo de recuerdos que persiste en la partida (GameState.recuerdos; lo guarda SaveSystem):
## inventario del Eco, el Tasador, el residuo (GDD 4.3) y qué se hizo con cada enemigo inconsciente.
## - Residuo: al morir el Eco, sus sueltos perdibles quedan en la casilla donde cayó. Hay uno solo: si
##   muere otra vez antes de recuperarlo, los del residuo anterior pasan al stock del Tasador con recargo.

enum Destino { EXTRAIDO, PERDONADO, REMATADO }

var inventario: InventarioRecuerdos = InventarioRecuerdos.new()
var tasador: Tasador = Tasador.new()
## Residuo actual: {"mapa": StringName, "celda": Vector2i, "recuerdos": Array[DefinicionRecuerdo]}; vacío si no hay.
var residuo: Dictionary = {}
## Id global del enemigo ("mapa/nombre") -> Destino.
var destinos: Dictionary[StringName, Destino] = {}


func hay_residuo() -> bool:
	return not residuo.is_empty()


## El Eco murió en `celda` de `id_mapa`: sus sueltos perdibles pasan a un residuo nuevo; el anterior, si
## seguía ahí, va al stock del Tasador con recargo.
func muerte_del_eco(id_mapa: StringName, celda: Vector2i, config: ConfigRecuerdos) -> void:
	if hay_residuo():
		for recuerdo: DefinicionRecuerdo in residuo.recuerdos:
			tasador.agregar_al_stock(recuerdo, config.recargo_residuo)
	var perdidos: Array[DefinicionRecuerdo] = inventario.sueltos_perdibles()
	for recuerdo: DefinicionRecuerdo in perdidos:
		inventario.quitar_suelto(recuerdo)
	residuo = {"mapa": id_mapa, "celda": celda, "recuerdos": perdidos} if not perdidos.is_empty() else {}


## Recupera el residuo (el Eco pasó por su casilla): sus recuerdos vuelven a sueltos.
func recuperar_residuo() -> Array[DefinicionRecuerdo]:
	var recuperados: Array[DefinicionRecuerdo] = []
	if hay_residuo():
		recuperados.assign(residuo.recuerdos)
		for recuerdo: DefinicionRecuerdo in recuperados:
			inventario.agregar_suelto(recuerdo)
		residuo = {}
	return recuperados


static func id_enemigo(id_mapa: StringName, nombre: StringName) -> StringName:
	return StringName("%s/%s" % [id_mapa, nombre])


func registrar_destino(id_global: StringName, destino: Destino) -> void:
	destinos[id_global] = destino


func a_diccionario() -> Dictionary:
	var datos: Dictionary = {"inventario": inventario.a_diccionario(), "tasador": tasador.a_diccionario(), "destinos": {}}
	for id: StringName in destinos:
		datos.destinos[String(id)] = Destino.keys()[destinos[id]]
	if hay_residuo():
		var ids: Array[String] = []
		for r: DefinicionRecuerdo in residuo.recuerdos:
			ids.append(String(r.id))
		datos["residuo"] = {"mapa": String(residuo.mapa), "celda": [residuo.celda.x, residuo.celda.y], "recuerdos": ids}
	return datos


static func desde_diccionario(datos: Dictionary, catalogo: CatalogoRecuerdos) -> EstadoRecuerdos:
	var estado: EstadoRecuerdos = EstadoRecuerdos.new()
	estado.inventario = InventarioRecuerdos.desde_diccionario(datos.get("inventario", {}), catalogo)
	estado.tasador = Tasador.desde_diccionario(datos.get("tasador", {}), catalogo)
	var destinos_guardados: Dictionary = datos.get("destinos", {})
	for id: String in destinos_guardados:
		estado.destinos[StringName(id)] = Destino.get(destinos_guardados[id])
	if datos.has("residuo"):
		var r: Dictionary = datos.residuo
		estado.residuo = {"mapa": StringName(r.mapa), "celda": Vector2i(int(r.celda[0]), int(r.celda[1])),
			"recuerdos": InventarioRecuerdos.resolver(r.recuerdos, catalogo)}
	return estado

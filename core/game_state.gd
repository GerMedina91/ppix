extends Node
## Estado global de la partida en curso. Es lo que SaveSystem serializa (a_diccionario / cargar_diccionario).
## Solo datos: la lógica de reglas vive en res://rules/.

const CONFIG_RECUERDOS: String = "res://data/config/config_recuerdos.tres"
## Versión del formato del guardado (SaveSystem.migrar lleva los viejos a esta).
const VERSION_GUARDADO: int = 1

## Mapa donde está la party.
var id_mapa_actual: StringName = &""
## Dónde está la party al guardar: {"celdas": {id del miembro: Vector2i}, "entrada": última entrada usada}.
var ubicacion: Dictionary = {}
## La partida se acaba de cargar (SaveSystem.cargar): el Mundo arranca desde `ubicacion` y la apaga. Si no,
## arranca en el mapa y la entrada iniciales (partida nueva).
var recien_cargada: bool = false
## Encuentro que empezó y no terminó (se guardó al iniciarlo): al cargar, el combate vuelve a empezar.
var combate_pendiente: StringName = &""
## El Eco se rearmó y todavía no eligió el recuerdo integrado que pierde: al cargar, se vuelve a preguntar.
var perdida_pendiente: bool = false

## Último punto estable donde se descansó (y guardó). Al morir, el Eco reaparece acá.
var id_ultimo_punto_estable: StringName = &""
## Mapa de ese punto estable.
var id_mapa_ultimo_punto_estable: StringName = &""

## Estado persistente de cada miembro de la party entre combates: id -> {"pg": int, "herido": int}.
## Sin entrada = PG completos y sin herido.
var estado_party: Dictionary[StringName, Dictionary] = {}

## Recuerdos del Eco, el Tasador, el residuo y el destino de los enemigos inconscientes (GDD 4.2 y 4.3).
var recuerdos: EstadoRecuerdos = EstadoRecuerdos.new()

## Encuentros resueltos y enemigos que ya no están en cada mapa (se aplica al cargar el mapa).
var mundo: EstadoMundo = EstadoMundo.new()

## Sueños que ya se vieron al descansar (no se repiten).
var suenos_vistos: Array[StringName] = []

## Marcas que ponen los diálogos y el mundo (p. ej. "tasador_presentado": ya se habló con el Tasador).
var marcas: Dictionary[StringName, bool] = {}

## RNG centralizado de las reglas. `reiniciar_dados()` fija la semilla (reproducible en tests).
var semilla: int = 0
var dados: Dados = Dados.new(0)


func reiniciar_dados(nueva_semilla: int) -> void:
	semilla = nueva_semilla
	dados = Dados.new(nueva_semilla)


## Vuelve al estado de una partida nueva (no toca el RNG): el Tasador con su stock inicial. También la usan
## los tests que cargan el mundo.
func nueva_partida() -> void:
	id_mapa_actual = &""
	ubicacion = {}
	recien_cargada = false
	combate_pendiente = &""
	perdida_pendiente = false
	id_ultimo_punto_estable = &""
	id_mapa_ultimo_punto_estable = &""
	estado_party.clear()
	recuerdos = EstadoRecuerdos.new()
	for recuerdo: DefinicionRecuerdo in (load(CONFIG_RECUERDOS) as ConfigRecuerdos).stock_inicial_tasador:
		recuerdos.tasador.agregar_al_stock(recuerdo)
	mundo = EstadoMundo.new()
	suenos_vistos.clear()
	marcas.clear()


## Todo el estado, listo para JSON. El estado del RNG es un entero de 64 bits: va como texto (JSON usa double).
func a_diccionario() -> Dictionary:
	var celdas: Dictionary = {}
	for id: Variant in ubicacion.get("celdas", {}):
		var celda: Vector2i = ubicacion.celdas[id]
		celdas[String(id)] = [celda.x, celda.y]
	return {
		"version": VERSION_GUARDADO,
		"mapa": String(id_mapa_actual),
		"ubicacion": {"celdas": celdas, "entrada": String(ubicacion.get("entrada", ""))},
		"combate_pendiente": String(combate_pendiente),
		"perdida_pendiente": perdida_pendiente,
		"punto_estable": {"id": String(id_ultimo_punto_estable), "mapa": String(id_mapa_ultimo_punto_estable)},
		"party": SerializacionParty.a_diccionario(estado_party),
		"recuerdos": recuerdos.a_diccionario(),
		"mundo": mundo.a_diccionario(),
		"suenos_vistos": suenos_vistos.map(func(id: StringName) -> String: return String(id)),
		"marcas": marcas.keys().map(func(id: StringName) -> String: return String(id)),
		"dados": {"semilla": str(semilla), "estado": str(dados.estado())},
	}


func cargar_diccionario(datos: Dictionary, catalogo: CatalogoRecuerdos) -> void:
	id_mapa_actual = StringName(datos.get("mapa", ""))
	var guardada: Dictionary = datos.get("ubicacion", {})
	var celdas: Dictionary[StringName, Vector2i] = {}
	for id: String in guardada.get("celdas", {}):
		var celda: Array = guardada.celdas[id]
		celdas[StringName(id)] = Vector2i(int(celda[0]), int(celda[1]))
	ubicacion = {"celdas": celdas, "entrada": StringName(guardada.get("entrada", ""))} if not celdas.is_empty() else {}
	combate_pendiente = StringName(datos.get("combate_pendiente", ""))
	perdida_pendiente = bool(datos.get("perdida_pendiente", false))
	var punto: Dictionary = datos.get("punto_estable", {})
	id_ultimo_punto_estable = StringName(punto.get("id", ""))
	id_mapa_ultimo_punto_estable = StringName(punto.get("mapa", ""))
	estado_party = SerializacionParty.desde_diccionario(datos.get("party", {}))
	recuerdos = EstadoRecuerdos.desde_diccionario(datos.get("recuerdos", {}), catalogo)
	mundo = EstadoMundo.desde_diccionario(datos.get("mundo", {}))
	suenos_vistos.clear()
	for id: Variant in datos.get("suenos_vistos", []):
		suenos_vistos.append(StringName(id))
	marcas.clear()
	for id: Variant in datos.get("marcas", []):
		marcas[StringName(id)] = true
	if datos.has("dados"):
		reiniciar_dados(String(datos.dados.semilla).to_int())
		dados.restaurar_estado(String(datos.dados.estado).to_int())


func _ready() -> void:
	nueva_partida()
	reiniciar_dados(int(Time.get_unix_time_from_system()))

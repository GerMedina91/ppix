class_name DefinicionConjuro
extends Resource
## Un conjuro (Player Core; cada uno verificado en docs/verificacion/c4_conjuros.md). Los datos describen
## lo que hace; AccionesConjuro lo resuelve en el combate.
## - Truco: a voluntad. Espacio: gasta el espacio donde se preparó. Foco: gasta 1 punto de foco.
## - Defensa CA: ataque de conjuro (rasgo ataque: penalizador por ataque múltiple); crítico, daño doble.
## - Con defensa de salvación, el objetivo tira contra la CD de conjuro y se aplican los `efectos` de su grado;
##   con `salvacion_basica`, el daño es 0 / mitad / completo / doble según el grado.
## - Estabilizar (`estabiliza`): la criatura moribunda pierde moribundo y queda inconsciente a 0 PG.
## - Sostenido (`sostenido_rondas_max` > 0): dura hasta el final del próximo turno del lanzador salvo que
##   lo Sostenga; mientras dura, `piso_mientras_dura` no deja bajar de ese valor las condiciones que aplicó
##   (Mal de ojo) si el lanzador ve al objetivo.
## - Sobre uno mismo: `bonificador_velocidad` (de estatus, hasta el final del turno) y `permite_moverse`
##   (como parte del lanzamiento puede dar un Paso o una Zancada: Pies ágiles).

enum Tipo { TRUCO, ESPACIO, FOCO }
enum Rasgo { MANIPULAR, CONCENTRAR, MALEFICIO, MALDICION, ATAQUE, MENTAL, EMOCION, MIEDO, NO_LETAL, CURACION, VITALIDAD, ESPIRITU, SANTIFICADO }
enum Objetivo { UNA_CRIATURA, UNO_MISMO, UNA_CRIATURA_MORIBUNDA }
enum Defensa { NINGUNA, CA, FORTALEZA, REFLEJOS, VOLUNTAD }

const _SALVACION: Dictionary[Defensa, Estadisticas.Salvacion] = {
	Defensa.FORTALEZA: Estadisticas.Salvacion.FORTALEZA,
	Defensa.REFLEJOS: Estadisticas.Salvacion.REFLEJOS,
	Defensa.VOLUNTAD: Estadisticas.Salvacion.VOLUNTAD,
}

@export var id: StringName = &""
@export var nombre: String = ""
@export var tipo: Tipo = Tipo.ESPACIO
## Rango mínimo (los trucos y los de foco se potencian solos; a nivel 1, rango 1).
@export var rango: int = 1
@export var tradiciones: Array[Tradicion.Tipo] = []
## Conjuros de dominio (foco del clérigo): id del dominio.
@export var dominio: StringName = &""
@export var acciones: int = 2
@export var rasgos: Array[Rasgo] = []
@export_group("Objetivo")
@export var objetivo: Objetivo = Objetivo.UNA_CRIATURA
@export var alcance_pies: int = 30
@export var defensa: Defensa = Defensa.NINGUNA
@export var efectos: Array[EfectoPorGrado] = []
@export_group("Daño")
@export var danio_dados: int = 0
@export var danio_caras: int = 6
@export var tipo_danio: DefinicionArma.TipoDanio = DefinicionArma.TipoDanio.CONTUNDENTE
@export var salvacion_basica: bool = false
@export_group("Curación")
@export var estabiliza: bool = false
@export_group("Duración")
## 0 = no se sostiene. "Sostenido hasta 1 minuto" = 10.
@export var sostenido_rondas_max: int = 0
@export var piso_mientras_dura: int = 0
@export_group("Sobre uno mismo")
@export var bonificador_velocidad: int = 0
@export var permite_moverse: bool = false


func tiene(rasgo: Rasgo) -> bool:
	return rasgos.has(rasgo)


func es_ataque() -> bool:
	return defensa == Defensa.CA


func hace_danio() -> bool:
	return danio_dados > 0


func tirada_danio() -> Tirada:
	return Tirada.new(danio_dados, danio_caras)


func es_sostenido() -> bool:
	return sostenido_rondas_max > 0


func pide_salvacion() -> bool:
	return _SALVACION.has(defensa)


func salvacion() -> Estadisticas.Salvacion:
	return _SALVACION[defensa]


## Efectos que corresponden a un grado de éxito de la salvación.
func efectos_de(grado: GradoExito.Grado) -> Array[EfectoPorGrado]:
	var lista: Array[EfectoPorGrado] = []
	for efecto: EfectoPorGrado in efectos:
		if efecto.grado == grado:
			lista.append(efecto)
	return lista


func errores_de_datos() -> PackedStringArray:
	var errores: PackedStringArray = PackedStringArray()
	if id == &"" or nombre.strip_edges().is_empty():
		errores.append("Conjuro sin id o sin nombre")
	if acciones < 1 or acciones > 3:
		errores.append("Conjuro %s: tiene que costar de 1 a 3 acciones" % nombre)
	# Los de foco y los trucos de maleficio toman la tradición de quien los da (clase o patrón).
	if tipo != Tipo.FOCO and not tiene(Rasgo.MALEFICIO) and tradiciones.is_empty():
		errores.append("Conjuro %s: necesita al menos una tradición" % nombre)
	if tipo == Tipo.FOCO and not tradiciones.is_empty():
		errores.append("Conjuro %s: los de foco toman la tradición de su clase" % nombre)
	if objetivo != Objetivo.UNO_MISMO and (alcance_pies <= 0 or alcance_pies % Medicion.PIES_POR_CASILLA != 0):
		errores.append("Conjuro %s: alcance inválido" % nombre)
	if not efectos.is_empty() and not pide_salvacion():
		errores.append("Conjuro %s: los efectos por grado necesitan una salvación" % nombre)
	if piso_mientras_dura > 0 and not es_sostenido():
		errores.append("Conjuro %s: el piso de condición solo tiene sentido en un conjuro sostenido" % nombre)
	if hace_danio() and not es_ataque() and not salvacion_basica:
		errores.append("Conjuro %s: el daño necesita un ataque de conjuro o una salvación básica" % nombre)
	if hace_danio() and not DefinicionArma.CARAS_VALIDAS.has(danio_caras):
		errores.append("Conjuro %s: dado de daño d%d no válido" % [nombre, danio_caras])
	if es_ataque() and not tiene(Rasgo.ATAQUE):
		errores.append("Conjuro %s: un ataque de conjuro lleva el rasgo ataque" % nombre)
	for efecto: EfectoPorGrado in efectos:
		errores.append_array(efecto.errores_de_datos())
	return errores

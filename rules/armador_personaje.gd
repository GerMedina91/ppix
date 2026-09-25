class_name ArmadorPersonaje
extends RefCounted
## Convierte un DefinicionBuild de nivel 1 en un DefinicionPersonaje, con las reglas de creación del
## Player Core (verificadas en docs/verificacion/c1_clases.md):
## - Cada mejora suma +1; dentro de cada fuente (ascendencia, trasfondo, libres) van a atributos distintos;
##   la clase suma +1 al atributo clave. A nivel 1 ningún modificador supera +4.
## - Habilidades: fijas de la clase + una de las opciones (si hay) + subclase + habilidad divina +
##   libres (base de la clase + Inteligencia) + trasfondo, sin repetir.

const NIVEL: int = 1
const MAXIMO_NIVEL_1: int = 4
const MEJORAS_TRASFONDO: int = 2
const MEJORAS_LIBRES: int = 4


static func armar(build: DefinicionBuild) -> DefinicionPersonaje:
	var clase: DefinicionClase = build.clase
	var p: DefinicionPersonaje = DefinicionPersonaje.new()
	p.nombre = build.nombre
	p.nivel = NIVEL
	var atributos: Dictionary[Atributo.Tipo, int] = atributos_de(build)
	p.fuerza = atributos[Atributo.Tipo.FUERZA]
	p.destreza = atributos[Atributo.Tipo.DESTREZA]
	p.constitucion = atributos[Atributo.Tipo.CONSTITUCION]
	p.inteligencia = atributos[Atributo.Tipo.INTELIGENCIA]
	p.sabiduria = atributos[Atributo.Tipo.SABIDURIA]
	p.carisma = atributos[Atributo.Tipo.CARISMA]
	p.atributo_clave = build.atributo_clave
	p.percepcion = clase.percepcion
	p.fortaleza = clase.fortaleza
	p.reflejos = clase.reflejos
	p.voluntad = clase.voluntad
	p.cd_clase = clase.cd_clase
	p.conjuros = clase.conjuros
	p.ataques = clase.ataques.duplicate()
	p.defensas = clase.defensas.duplicate()
	if build.subclase is DefinicionDoctrina:
		for categoria: DefinicionArmadura.Categoria in (build.subclase as DefinicionDoctrina).defensas:
			p.defensas[categoria] = maxi(p.defensas.get(categoria, 0), (build.subclase as DefinicionDoctrina).defensas[categoria])
	if build.entidad != null:
		p.armas_con_competencia[build.entidad.arma_predilecta] = Competencia.Rango.ENTRENADO
	for habilidad: Habilidad.Tipo in habilidades_de(build):
		p.habilidades[habilidad] = Competencia.Rango.ENTRENADO
	p.pg_ascendencia = build.ascendencia.pg
	p.pg_clase_por_nivel = clase.pg_por_nivel
	p.velocidad_pies = build.ascendencia.velocidad_pies
	p.armas = build.armas.duplicate()
	p.armadura = build.armadura
	p.capacidades.append_array(clase.capacidades_nivel_1)
	if build.subclase != null:
		p.capacidades.append_array(build.subclase.capacidades)
	p.capacidades.append_array(build.dotes)
	return p


## Modificadores de atributo finales (+0 base, +1 por mejora).
static func atributos_de(build: DefinicionBuild) -> Dictionary[Atributo.Tipo, int]:
	var atributos: Dictionary[Atributo.Tipo, int] = {}
	for tipo: Atributo.Tipo in Atributo.Tipo.values():
		atributos[tipo] = 0
	var mejoras: Array[Atributo.Tipo] = []
	if build.ascendencia != null:
		mejoras.append_array(build.ascendencia.mejoras_fijas)
	mejoras.append_array(build.mejoras_ascendencia)
	mejoras.append_array(build.mejoras_trasfondo)
	mejoras.append(build.atributo_clave)
	mejoras.append_array(build.mejoras_libres)
	for tipo: Atributo.Tipo in mejoras:
		atributos[tipo] += 1
	return atributos


## Habilidades entrenadas del build, sin repetir.
static func habilidades_de(build: DefinicionBuild) -> Array[Habilidad.Tipo]:
	var lista: Array[Habilidad.Tipo] = []
	for habilidad: Habilidad.Tipo in _todas_las_habilidades(build):
		if not lista.has(habilidad):
			lista.append(habilidad)
	return lista


## Errores del build según las reglas de creación (vacío = válido).
static func validar(build: DefinicionBuild) -> PackedStringArray:
	var errores: PackedStringArray = PackedStringArray()
	if build.clase == null or build.ascendencia == null:
		errores.append("Build %s: faltan clase o ascendencia" % build.nombre)
		return errores
	var clase: DefinicionClase = build.clase
	if not clase.atributos_clave.has(build.atributo_clave):
		errores.append("Build %s: %s no es atributo clave de %s" % [build.nombre, Atributo.nombre(build.atributo_clave), clase.nombre])
	if build.mejoras_ascendencia.size() != build.ascendencia.mejoras_libres:
		errores.append("Build %s: la ascendencia da %d mejoras libres" % [build.nombre, build.ascendencia.mejoras_libres])
	if build.mejoras_trasfondo.size() != MEJORAS_TRASFONDO:
		errores.append("Build %s: el trasfondo da %d mejoras" % [build.nombre, MEJORAS_TRASFONDO])
	if build.mejoras_libres.size() != MEJORAS_LIBRES:
		errores.append("Build %s: hay %d mejoras libres" % [build.nombre, MEJORAS_LIBRES])
	for fuente: Array in [build.mejoras_ascendencia + build.ascendencia.mejoras_fijas, build.mejoras_trasfondo, build.mejoras_libres]:
		if _tiene_repetidos(fuente):
			errores.append("Build %s: una misma fuente mejora dos veces el mismo atributo" % build.nombre)
	for tipo: Atributo.Tipo in atributos_de(build):
		if atributos_de(build)[tipo] > MAXIMO_NIVEL_1:
			errores.append("Build %s: %s supera +%d a nivel 1" % [build.nombre, Atributo.nombre(tipo), MAXIMO_NIVEL_1])
	var todas: Array[Habilidad.Tipo] = _todas_las_habilidades(build)
	if _tiene_repetidos(todas):
		errores.append("Build %s: una habilidad se entrena dos veces (elegí otra)" % build.nombre)
	var libres_esperadas: int = clase.habilidades_libres_base + atributos_de(build)[Atributo.Tipo.INTELIGENCIA]
	if build.habilidades_libres.size() != libres_esperadas:
		errores.append("Build %s: le corresponden %d habilidades libres" % [build.nombre, libres_esperadas])
	if not clase.habilidades_una_de.is_empty() and not clase.habilidades_una_de.has(build.habilidad_una_de):
		errores.append("Build %s: la habilidad elegida no está entre las opciones de %s" % [build.nombre, clase.nombre])
	if build.armadura != null and not clase.defensas.has(build.armadura.categoria):
		errores.append("Build %s: %s no tiene competencia en esa armadura" % [build.nombre, clase.nombre])
	return errores


static func _todas_las_habilidades(build: DefinicionBuild) -> Array[Habilidad.Tipo]:
	var lista: Array[Habilidad.Tipo] = []
	lista.append_array(build.clase.habilidades_fijas)
	if not build.clase.habilidades_una_de.is_empty():
		lista.append(build.habilidad_una_de)
	if build.subclase != null:
		lista.append_array(build.subclase.habilidades)
	if build.entidad != null:
		lista.append(build.entidad.habilidad_divina)
	lista.append_array(build.habilidades_libres)
	lista.append(build.habilidad_trasfondo)
	return lista


static func _tiene_repetidos(lista: Array) -> bool:
	var vistos: Dictionary = {}
	for elemento: Variant in lista:
		if vistos.has(elemento):
			return true
		vistos[elemento] = true
	return false

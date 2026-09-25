class_name Estadisticas
extends RefCounted
## Estadísticas derivadas de un DefinicionPersonaje. Cada una se arma como una Prueba,
## así se puede tirar (Percepción, salvaciones) o usar como CD (CA, CD de clase) con su desglose.

enum Salvacion { FORTALEZA, REFLEJOS, VOLUNTAD }

const _ATRIBUTO_DE_SALVACION: Dictionary[Salvacion, Atributo.Tipo] = {
	Salvacion.FORTALEZA: Atributo.Tipo.CONSTITUCION,
	Salvacion.REFLEJOS: Atributo.Tipo.DESTREZA,
	Salvacion.VOLUNTAD: Atributo.Tipo.SABIDURIA,
}
const _NOMBRE_SALVACION: Dictionary[Salvacion, String] = {
	Salvacion.FORTALEZA: "Fortaleza",
	Salvacion.REFLEJOS: "Reflejos",
	Salvacion.VOLUNTAD: "Voluntad",
}


static func prueba_percepcion(personaje: DefinicionPersonaje) -> Prueba:
	return _prueba("Percepción", personaje, Atributo.Tipo.SABIDURIA, personaje.percepcion)


static func prueba_salvacion(personaje: DefinicionPersonaje, salvacion: Salvacion) -> Prueba:
	return _prueba(_NOMBRE_SALVACION[salvacion], personaje, _ATRIBUTO_DE_SALVACION[salvacion], _rango_salvacion(personaje, salvacion))


## CA como Prueba: Destreza (con el tope de la armadura) + competencia en defensa + bonificador de objeto.
## La CA es su cd(): 10 + modificador total.
static func defensa(personaje: DefinicionPersonaje) -> Prueba:
	var destreza: int = personaje.destreza
	var armadura: DefinicionArmadura = personaje.armadura
	if armadura != null and armadura.tiene_tope_destreza:
		destreza = mini(destreza, armadura.tope_destreza)
	var prueba: Prueba = Prueba.new("CA", Atributo.nombre(Atributo.Tipo.DESTREZA), destreza, rango_de_defensa(personaje), personaje.nivel)
	if armadura != null and armadura.bonificador_ca != 0:
		prueba.modificadores.append(Modificador.new(armadura.bonificador_ca, Modificador.Tipo.OBJETO, armadura.nombre))
	return prueba


static func prueba_clase(personaje: DefinicionPersonaje) -> Prueba:
	return _prueba("CD de clase", personaje, personaje.atributo_clave, personaje.cd_clase)


## Prueba de ataque con un arma: Fuerza; Destreza si es a distancia; la mejor de las dos si es sutil.
static func prueba_ataque(personaje: DefinicionPersonaje, arma: DefinicionArma) -> Prueba:
	return _prueba("Golpe (%s)" % arma.nombre, personaje, atributo_de_ataque(personaje, arma), rango_de_ataque(personaje, arma))


## El mejor rango entre el de la categoría del arma y el del arma específica.
static func rango_de_ataque(personaje: DefinicionPersonaje, arma: DefinicionArma) -> Competencia.Rango:
	var por_categoria: Competencia.Rango = personaje.ataques.get(arma.categoria, Competencia.Rango.NO_ENTRENADO)
	var especifico: Competencia.Rango = personaje.armas_con_competencia.get(arma.id, Competencia.Rango.NO_ENTRENADO)
	return maxi(por_categoria, especifico) as Competencia.Rango


static func categoria_de_defensa(personaje: DefinicionPersonaje) -> DefinicionArmadura.Categoria:
	return DefinicionArmadura.Categoria.SIN_ARMADURA if personaje.armadura == null else personaje.armadura.categoria


static func rango_de_defensa(personaje: DefinicionPersonaje) -> Competencia.Rango:
	return personaje.defensas.get(categoria_de_defensa(personaje), Competencia.Rango.NO_ENTRENADO)


## Velocidad con el penalizador de la armadura: si la Fuerza llega al requisito, baja 5 pies. Mínimo 5.
static func velocidad(personaje: DefinicionPersonaje) -> int:
	var armadura: DefinicionArmadura = personaje.armadura
	if armadura == null:
		return personaje.velocidad_pies
	var penalizador: int = armadura.penalizador_velocidad_pies
	if personaje.fuerza >= armadura.requisito_fuerza:
		penalizador = maxi(0, penalizador - Medicion.PIES_POR_CASILLA)
	return maxi(Medicion.PIES_POR_CASILLA, personaje.velocidad_pies - penalizador)


static func atributo_de_ataque(personaje: DefinicionPersonaje, arma: DefinicionArma) -> Atributo.Tipo:
	if arma.a_distancia:
		return Atributo.Tipo.DESTREZA
	if arma.sutil and personaje.destreza > personaje.fuerza:
		return Atributo.Tipo.DESTREZA
	return Atributo.Tipo.FUERZA


## Bonificador fijo al daño: Fuerza en cuerpo a cuerpo; nada a distancia. Una capacidad puede cambiar
## el atributo (p. ej. Destreza del Ladrón con armas sutiles).
static func bonificador_danio(personaje: DefinicionPersonaje, arma: DefinicionArma) -> int:
	for capacidad: Capacidad in personaje.capacidades:
		var atributo: Variant = capacidad.atributo_de_danio(personaje, arma)
		if atributo != null:
			return personaje.modificador(atributo)
	return 0 if arma.a_distancia else personaje.fuerza


## Prueba de habilidad. Con armadura, las de Fuerza y Destreza llevan el penalizador a pruebas (sin tipo),
## salvo que la Fuerza llegue al requisito o que la prueba tenga el rasgo ataque.
static func prueba_habilidad(personaje: DefinicionPersonaje, habilidad: Habilidad.Tipo, con_rasgo_ataque: bool = false) -> Prueba:
	var rango: Competencia.Rango = personaje.habilidades.get(habilidad, Competencia.Rango.NO_ENTRENADO)
	var prueba: Prueba = _prueba(Habilidad.nombre(habilidad), personaje, Habilidad.ATRIBUTO[habilidad], rango)
	var armadura: DefinicionArmadura = personaje.armadura
	if armadura != null and armadura.penalizador_pruebas < 0 and Habilidad.es_fisica(habilidad) \
			and not con_rasgo_ataque and personaje.fuerza < armadura.requisito_fuerza:
		prueba.modificadores.append(Modificador.new(armadura.penalizador_pruebas, Modificador.Tipo.SIN_TIPO, armadura.nombre))
	return prueba


static func ca(personaje: DefinicionPersonaje) -> int:
	return defensa(personaje).cd()


static func cd_clase(personaje: DefinicionPersonaje) -> int:
	return prueba_clase(personaje).cd()


## PG máximos: los de la ascendencia + (los de la clase + Constitución) por nivel.
static func pg_maximos(personaje: DefinicionPersonaje) -> int:
	return personaje.pg_ascendencia + (personaje.pg_clase_por_nivel + personaje.constitucion) * personaje.nivel


static func _prueba(nombre: String, personaje: DefinicionPersonaje, atributo: Atributo.Tipo, rango: Competencia.Rango) -> Prueba:
	return Prueba.new(nombre, Atributo.nombre(atributo), personaje.modificador(atributo), rango, personaje.nivel)


static func _rango_salvacion(personaje: DefinicionPersonaje, salvacion: Salvacion) -> Competencia.Rango:
	match salvacion:
		Salvacion.FORTALEZA: return personaje.fortaleza
		Salvacion.REFLEJOS: return personaje.reflejos
		_: return personaje.voluntad

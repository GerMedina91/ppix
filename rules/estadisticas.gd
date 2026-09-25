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
	var prueba: Prueba = Prueba.new("CA", Atributo.nombre(Atributo.Tipo.DESTREZA), destreza, personaje.defensa, personaje.nivel)
	if armadura != null and armadura.bonificador_ca != 0:
		prueba.modificadores.append(Modificador.new(armadura.bonificador_ca, Modificador.Tipo.OBJETO, armadura.nombre))
	return prueba


static func prueba_clase(personaje: DefinicionPersonaje) -> Prueba:
	return _prueba("CD de clase", personaje, personaje.atributo_clave, personaje.cd_clase)


## Prueba de ataque con un arma: Fuerza; Destreza si es a distancia; la mejor de las dos si es sutil.
static func prueba_ataque(personaje: DefinicionPersonaje, arma: DefinicionArma) -> Prueba:
	return _prueba("Golpe (%s)" % arma.nombre, personaje, atributo_de_ataque(personaje, arma), personaje.ataque)


static func atributo_de_ataque(personaje: DefinicionPersonaje, arma: DefinicionArma) -> Atributo.Tipo:
	if arma.a_distancia:
		return Atributo.Tipo.DESTREZA
	if arma.sutil and personaje.destreza > personaje.fuerza:
		return Atributo.Tipo.DESTREZA
	return Atributo.Tipo.FUERZA


## Bonificador fijo al daño: Fuerza en cuerpo a cuerpo; nada a distancia.
static func bonificador_danio(personaje: DefinicionPersonaje, arma: DefinicionArma) -> int:
	return 0 if arma.a_distancia else personaje.fuerza


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

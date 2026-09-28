class_name FuenteEstadisticas
extends RefCounted
## De dónde saca sus números un Combatiente. El combate solo usa esta interfaz, así no importa si
## los números salen de un personaje (atributos + competencias; a futuro, clase y ascendencia)
## o de una criatura (bloque de estadísticas). Subclases: FuentePersonaje, FuenteCriatura.


func nombre() -> String:
	return ""


func nivel() -> int:
	return 1


func pg_maximos() -> int:
	return 1


func velocidad_pies() -> int:
	return 0


func armas() -> Array[DefinicionArma]:
	return []


func prueba_ataque(_arma: DefinicionArma) -> Prueba:
	return Prueba.plana("Golpe")


func bonificador_danio(_arma: DefinicionArma) -> int:
	return 0


## true si el ataque con `arma` usa la Fuerza (lo mira debilitado).
func ataque_con_fuerza(arma: DefinicionArma) -> bool:
	return not arma.a_distancia


## true si el bonificador al daño con `arma` sale de la Fuerza (lo mira debilitado).
func danio_con_fuerza(arma: DefinicionArma) -> bool:
	return not arma.a_distancia


func trucos() -> Array[DefinicionConjuro]:
	return []


func conjuros_preparados() -> Array[DefinicionConjuro]:
	return []


func conjuros_foco() -> Array[DefinicionConjuro]:
	return []


## Ataque de conjuro; su cd() es la CD de conjuro. Sin lanzamiento: sin competencia.
func prueba_conjuro() -> Prueba:
	return Prueba.plana("Ataque de conjuro")


## La CA es defensa().cd().
func defensa() -> Prueba:
	return Prueba.plana("CA")


func prueba_percepcion() -> Prueba:
	return Prueba.plana("Percepción")


func prueba_salvacion(_salvacion: Estadisticas.Salvacion) -> Prueba:
	return Prueba.plana("Tirada de salvación")


## Capacidades que modifican Golpes y otras reglas (criaturas: ninguna por ahora).
func capacidades() -> Array[Capacidad]:
	return []


func prueba_habilidad(habilidad: Habilidad.Tipo) -> Prueba:
	return Prueba.plana(Habilidad.nombre(habilidad))


## Perfil de IA: si también ataca a personajes caídos.
func remata_caidos() -> bool:
	return false


## Rasgo de tipo (los personajes son humanoides).
func rasgo() -> RasgoCriatura.Tipo:
	return RasgoCriatura.Tipo.HUMANOIDE


## CD de Recordar conocimiento sobre este combatiente.
func cd_recordar() -> int:
	return RasgoCriatura.cd_recordar(nivel(), RasgoCriatura.Rareza.COMUN)


## Debilidad al tipo de daño (0 = ninguna).
func debilidad(_tipo: DefinicionArma.TipoDanio) -> int:
	return 0


## Acción de miedo de una criatura (null = no tiene).
func accion_miedo() -> DefinicionAccionMiedo:
	return null


## Resistencia al tipo de daño (0 = ninguna).
func resistencia(_tipo: DefinicionArma.TipoDanio) -> int:
	return 0


## true si a 0 PG queda inconsciente en vez de morir, aunque el daño sea letal (Player Core p. 410: el DJ lo
## decide para personajes y criaturas importantes). No aplica a los muertos vivientes.
func inconsciente_a_cero() -> bool:
	return false


func inmune_mental() -> bool:
	return false


## Lento permanente (acciones de menos al empezar cada turno).
func lento() -> int:
	return 0


## Muerto viviente (Curar lo daña en vez de curarlo).
func es_muerto_viviente() -> bool:
	return false


## true si usa las reglas de moribundo, herido e inconsciente (personajes); false si muere a 0 PG.
func usa_reglas_de_moribundo() -> bool:
	return false

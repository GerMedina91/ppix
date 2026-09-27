class_name BeneficioHabilidad
extends BeneficioRecuerdo
## Competencia en una habilidad, hasta entrenado (no pasa por la dote Entrenamiento en habilidad ni por su
## requisito de Inteligencia; ver docs/verificacion/m4_recuerdos.md).

@export var habilidad: Habilidad.Tipo = Habilidad.Tipo.MEDICINA


func aplicar(personaje: DefinicionPersonaje) -> void:
	if not ya_lo_tiene(personaje):
		personaje.habilidades[habilidad] = Competencia.Rango.ENTRENADO


func ya_lo_tiene(personaje: DefinicionPersonaje) -> bool:
	return personaje.habilidades.get(habilidad, Competencia.Rango.NO_ENTRENADO) >= Competencia.Rango.ENTRENADO


func descripcion() -> String:
	return "Entrenado en %s" % Habilidad.nombre(habilidad)

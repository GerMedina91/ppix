class_name EfectoPorGrado
extends Resource
## Condición que aplica un conjuro según el grado de éxito de la salvación del objetivo.

@export var grado: GradoExito.Grado = GradoExito.Grado.FALLO
@export var condicion: Condiciones.Tipo = Condiciones.Tipo.ASUSTADO
@export var valor: int = 1
## Duración en rondas, contadas al inicio de los turnos del lanzador (Player Core p. 302).
## 1 = "hasta el inicio de tu próximo turno"; 10 = 1 minuto; 0 = sin duración (la condición termina
## por sus propias reglas o cuando algo la quita).
@export var rondas: int = 0


func errores_de_datos() -> PackedStringArray:
	var errores: PackedStringArray = PackedStringArray()
	if valor <= 0:
		errores.append("Efecto por grado: el valor de la condición tiene que ser positivo")
	if rondas < 0:
		errores.append("Efecto por grado: la duración no puede ser negativa")
	return errores

extends Dados
## Doble de prueba: devuelve los valores dados en orden, sin azar.

var _valores: Array[int] = []


## Sin tipo en el parámetro: al construirse vía preload (llamada dinámica), GDScript no convierte
## un literal [1, 2] a Array[int].
func _init(valores: Array) -> void:
	super(0)
	_valores.assign(valores)


func tirar(caras: int) -> int:
	assert(not _valores.is_empty(), "DadosFijos: se acabaron los valores")
	var valor: int = _valores.pop_front()
	assert(valor >= 1 and valor <= caras, "DadosFijos: %d no es válido para d%d" % [valor, caras])
	return valor


func restantes() -> int:
	return _valores.size()

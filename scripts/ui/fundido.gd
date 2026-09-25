class_name Fundido
extends CanvasLayer
## Fundido a negro de pantalla completa para las transiciones. No bloquea el mouse.

@onready var _negro: ColorRect = $Negro


func _ready() -> void:
	_negro.color.a = 0.0


func fundir_a_negro(segundos: float) -> void:
	await _animar(1.0, segundos)


func aclarar(segundos: float) -> void:
	await _animar(0.0, segundos)


func _animar(alfa: float, segundos: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(_negro, "color:a", alfa, segundos)
	await tween.finished

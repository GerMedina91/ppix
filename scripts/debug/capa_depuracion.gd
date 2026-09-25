class_name CapaDepuracion
extends RefCounted
## Una capa del overlay de depuración. Para sumar información nueva (rangos, línea de visión...),
## heredar de esta clase, implementar `dibujar()` y registrarla con OverlayDepuracion.registrar().

var activa: bool = true


func nombre() -> String:
	return ""


func dibujar(_lienzo: OverlayDepuracion) -> void:
	pass

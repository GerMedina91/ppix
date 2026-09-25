class_name MiembroParty
extends Node2D
## Miembro de la party en el mapa. Solo presentación: se desplaza de celda en celda
## cuando se lo ordenan; no decide adónde ir (eso es de ControlParty).

signal paso_iniciado(desde: Vector2i, hasta: Vector2i)
signal paso_terminado(celda: Vector2i)

## Rectángulo placeholder de 32×56 (ver CLAUDE.md), con los pies en el centro del rombo.
## El origen del nodo es el centro del rombo, que también es su punto de y-sort.
const TAMANO_PLACEHOLDER: Vector2 = Vector2(32, 56)

@export var color_placeholder: Color = Color.WHITE

## Celda que ocupa, o hacia la que se está moviendo.
var celda: Vector2i = Vector2i.ZERO
var _moviendose: bool = false
var _tween: Tween


func _ready() -> void:
	add_to_group(OclusionParedes.GRUPO_VISIBLES)


## Rect del sprite en pantalla, para que las paredes que lo tapan se vuelvan transparentes.
func rect_visible_global() -> Rect2:
	return Rect2(global_position + _origen_placeholder(), TAMANO_PLACEHOLDER)


func esta_moviendose() -> bool:
	return _moviendose


## Ubica al miembro en una celda al instante (al entrar a un mapa).
func colocar(celda_nueva: Vector2i, posicion_global: Vector2) -> void:
	if _tween:
		_tween.kill()
	_moviendose = false
	celda = celda_nueva
	global_position = posicion_global


## Se desplaza a una celda vecina en `duracion` segundos y emite `paso_terminado` al llegar.
func dar_paso(celda_nueva: Vector2i, posicion_global: Vector2, duracion: float) -> void:
	# Si todavía no terminó el paso anterior, se corta y el nuevo arranca desde donde está.
	if _tween:
		_tween.kill()
	var celda_anterior: Vector2i = celda
	celda = celda_nueva
	_moviendose = true
	_tween = create_tween()
	_tween.tween_property(self, "global_position", posicion_global, duracion)
	_tween.finished.connect(_al_terminar_paso)
	paso_iniciado.emit(celda_anterior, celda_nueva)


func _al_terminar_paso() -> void:
	_moviendose = false
	paso_terminado.emit(celda)


func _draw() -> void:
	draw_rect(Rect2(_origen_placeholder(), TAMANO_PLACEHOLDER), color_placeholder)


func _origen_placeholder() -> Vector2:
	return Vector2(-TAMANO_PLACEHOLDER.x / 2.0, -TAMANO_PLACEHOLDER.y)

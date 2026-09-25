class_name CapaDepuracionOclusion
extends CapaDepuracion
## Dibuja lo que usa la transparencia de paredes: rects de los actores visibles,
## siluetas de las paredes candidatas y, resaltadas, las que tapan a alguien.

const COLOR_ACTOR: Color = Color(0.3, 0.9, 1.0)
const COLOR_CANDIDATA: Color = Color(0.8, 0.8, 0.8, 0.6)
const COLOR_TAPA: Color = Color(1.0, 0.25, 0.25)
const COLOR_TAPA_RELLENO: Color = Color(1.0, 0.25, 0.25, 0.3)
const TAMANO_CRUZ: float = 4.0


func nombre() -> String:
	return "Oclusión de paredes"


func dibujar(lienzo: OverlayDepuracion) -> void:
	for capa: Node in lienzo.get_tree().get_nodes_in_group(CapaParedes.GRUPO):
		var paredes: CapaParedes = capa as CapaParedes
		var tapando: Array[Vector2i] = paredes.celdas_transparentes()
		var siluetas: Dictionary[Vector2i, PackedVector2Array] = paredes.siluetas_candidatas()
		for celda: Vector2i in siluetas:
			if tapando.has(celda):
				lienzo.poligono_global(siluetas[celda], COLOR_TAPA, COLOR_TAPA_RELLENO)
			else:
				lienzo.poligono_global(siluetas[celda], COLOR_CANDIDATA)
	for actor: Node in lienzo.get_tree().get_nodes_in_group(OclusionParedes.GRUPO_VISIBLES):
		if actor.has_method(OclusionParedes.METODO_RECT):
			lienzo.rect_global(actor.call(OclusionParedes.METODO_RECT), COLOR_ACTOR)
			lienzo.cruz_global((actor as Node2D).global_position, TAMANO_CRUZ, COLOR_ACTOR)

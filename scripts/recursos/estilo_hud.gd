class_name EstiloHud
extends Resource
## Aspecto del combate en un solo lugar (placeholder hasta la dirección de arte): fuente, tamaños y colores
## del HUD, de los resaltados del suelo y de los textos flotantes. La lógica no tiene colores propios.
## Valores por defecto acá; se cambian en data/config/estilo_hud.tres (referenciado desde ConfigCombate),
## desde el inspector, sin tocar la lógica.

@export_group("Fuente")
## null = la fuente de Godot.
@export var fuente: Font
@export var tamano_fuente: int = 10
@export var tamano_texto_flotante: int = 12
@export var tamano_costo: int = 12
@export var borde_texto: int = 3
@export var color_borde_texto: Color = Color.BLACK

@export_group("Paneles")
@export var color_fondo: Color = Color(0.0, 0.0, 0.0, 0.55)
@export var margen: int = 6
@export var relleno_panel: int = 4
@export var ancho_registro: int = 520

@export_group("Texto del HUD")
@export var color_party: Color = Color(0.75, 0.9, 1.0)
@export var color_enemigo: Color = Color(1.0, 0.7, 0.7)
@export var color_activo: Color = Color(1.0, 0.85, 0.3)
@export var color_muerto: Color = Color(0.45, 0.45, 0.45)
@export var color_ayuda: Color = Color(0.6, 0.6, 0.6)
@export var color_conjuro: Color = Color(0.85, 0.7, 1.0)

@export_group("Resaltados del suelo")
@export var resaltado_activo: Color = Color(1.0, 0.85, 0.3, 0.5)
## Alcance según las Zancadas que cuesta llegar (1, 2 y 3).
@export var resaltado_zancadas: Array[Color] = [Color(0.3, 0.6, 1.0, 0.22), Color(0.3, 0.85, 0.7, 0.18), Color(0.7, 0.45, 1.0, 0.15)]
@export var resaltado_camino: Color = Color(0.4, 0.75, 1.0, 0.5)
@export var resaltado_objetivo: Color = Color(1.0, 0.25, 0.25, 0.45)
@export var resaltado_conjuro_oponente: Color = Color(0.75, 0.4, 1.0, 0.5)
@export var resaltado_conjuro_aliado: Color = Color(0.3, 0.9, 0.6, 0.45)
@export var resaltado_conjuro_movimiento: Color = Color(0.55, 0.45, 1.0, 0.25)
@export var resaltado_conjuro_area: Color = Color(1.0, 0.95, 0.6, 0.18)
@export var color_costo: Color = Color(1.0, 0.95, 0.6)

@export_group("Textos flotantes")
@export var flotante_danio: Color = Color(1.0, 0.4, 0.3)
@export var flotante_fallo: Color = Color(0.8, 0.8, 0.8)
@export var flotante_info: Color = Color(0.7, 0.85, 1.0)
@export var flotante_invalida: Color = Color(1.0, 0.8, 0.4)
@export var flotante_conjuro: Color = Color(0.85, 0.6, 1.0)
@export var flotante_curacion: Color = Color(0.5, 1.0, 0.6)

var _tema: Theme


static func por_defecto() -> EstiloHud:
	return EstiloHud.new()


## Fuente efectiva (la de Godot si no hay una propia).
func fuente_efectiva() -> Font:
	return fuente if fuente != null else ThemeDB.fallback_font


## Color del alcance a `zancadas` Zancadas (1 a 3).
func color_zancadas(zancadas: int) -> Color:
	return resaltado_zancadas[clampi(zancadas - 1, 0, resaltado_zancadas.size() - 1)]


## Theme de Godot para los controles del HUD: fuente, tamaño y fondo de los paneles.
func tema() -> Theme:
	if _tema != null:
		return _tema
	_tema = Theme.new()
	_tema.default_font = fuente
	_tema.default_font_size = tamano_fuente
	var panel: StyleBoxFlat = StyleBoxFlat.new()
	panel.bg_color = color_fondo
	panel.content_margin_left = relleno_panel
	panel.content_margin_right = relleno_panel
	panel.content_margin_top = relleno_panel / 2
	panel.content_margin_bottom = relleno_panel / 2
	_tema.set_stylebox("panel", "PanelContainer", panel)
	return _tema

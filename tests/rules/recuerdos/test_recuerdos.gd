extends GdUnitTestSuite
## Modelo de recuerdos (GDD 4.2 y 4.3): integrar, ver, soltar, capacidad, trueque con el Tasador, residuo,
## destino de enemigos y guardado a diccionario.

const GUERRERO: String = "res://data/builds/guerrero.tres"

var _config: ConfigRecuerdos
var _medicina: DefinicionRecuerdo
var _sigilo: DefinicionRecuerdo
var _religion: DefinicionRecuerdo
var _ocultismo: DefinicionRecuerdo
var _con_requisito: DefinicionRecuerdo
var _vivencia: DefinicionRecuerdo
var _doliente: DefinicionRecuerdo
var _catalogo: CatalogoRecuerdos


func _destreza(id: StringName, habilidad: Habilidad.Tipo, valor: int) -> DefinicionRecuerdo:
	var r: DefinicionRecuerdo = DefinicionRecuerdo.new()
	r.id = id
	r.valor = valor
	var b: BeneficioHabilidad = BeneficioHabilidad.new()
	b.habilidad = habilidad
	r.beneficio = b
	return r


func _otro(id: StringName, tipo: DefinicionRecuerdo.Tipo, valor: int) -> DefinicionRecuerdo:
	var r: DefinicionRecuerdo = DefinicionRecuerdo.new()
	r.id = id
	r.tipo = tipo
	r.valor = valor
	return r


func before_test() -> void:
	_config = ConfigRecuerdos.new()
	_medicina = _destreza(&"medicina", Habilidad.Tipo.MEDICINA, 20)
	_sigilo = _destreza(&"sigilo", Habilidad.Tipo.SIGILO, 20)
	_religion = _destreza(&"religion", Habilidad.Tipo.RELIGION, 30)
	_ocultismo = _destreza(&"ocultismo", Habilidad.Tipo.OCULTISMO, 30)
	_con_requisito = DefinicionRecuerdo.new()
	_con_requisito.id = &"con_requisito"
	_con_requisito.valor = 40
	var dote: BeneficioDote = BeneficioDote.new()
	dote.dote = Capacidad.new()
	dote.dote.id = &"dote_de_prueba"
	dote.requiere_habilidad = true
	dote.habilidad_requerida = Habilidad.Tipo.MEDICINA
	_con_requisito.beneficio = dote
	_vivencia = _otro(&"vivencia", DefinicionRecuerdo.Tipo.VIVENCIA, 10)
	_doliente = _otro(&"doliente", DefinicionRecuerdo.Tipo.DOLIENTE, 50)
	_catalogo = CatalogoRecuerdos.new()
	_catalogo.recuerdos = [_medicina, _sigilo, _religion, _ocultismo, _con_requisito, _vivencia, _doliente]


func _eco() -> DefinicionPersonaje:
	return ArmadorPersonaje.armar(load(GUERRERO))


# --- Integrar, ver, soltar ---

func test_la_capacidad_es_2_mas_nivel() -> void:
	assert_int(_config.capacidad(1)).is_equal(3)
	assert_int(_config.capacidad(5)).is_equal(7)


func test_integrar_un_recuerdo_de_destreza_y_aplicar_su_beneficio() -> void:
	var inv: InventarioRecuerdos = InventarioRecuerdos.new()
	inv.agregar_suelto(_medicina)
	var eco: DefinicionPersonaje = _eco()
	assert_str(inv.motivo_no_integrable(_medicina, eco, 3)).is_empty()
	inv.integrar(_medicina)
	assert_array(inv.integrados).is_equal([_medicina])
	assert_array(inv.sueltos).is_empty()
	_medicina.beneficio.aplicar(eco)
	assert_int(eco.habilidades[Habilidad.Tipo.MEDICINA]).is_equal(Competencia.Rango.ENTRENADO)


func test_no_se_integra_sin_capacidad_ni_lo_que_ya_se_tiene() -> void:
	var inv: InventarioRecuerdos = InventarioRecuerdos.new()
	var eco: DefinicionPersonaje = _eco()
	for r: DefinicionRecuerdo in [_medicina, _sigilo, _religion]:
		inv.agregar_suelto(r)
		inv.integrar(r)
	inv.agregar_suelto(_ocultismo)
	assert_str(inv.motivo_no_integrable(_ocultismo, eco, 3)).is_equal("sin capacidad (3/3)")
	var atletismo: DefinicionRecuerdo = _destreza(&"atletismo", Habilidad.Tipo.ATLETISMO, 20)
	inv.agregar_suelto(atletismo)
	assert_str(inv.motivo_no_integrable(atletismo, eco, 9)).is_equal("ya tenés ese beneficio")  # el guerrero ya es entrenado


func test_una_dote_con_requisito_pide_la_habilidad() -> void:
	var inv: InventarioRecuerdos = InventarioRecuerdos.new()
	var eco: DefinicionPersonaje = _eco()
	inv.agregar_suelto(_con_requisito)
	assert_str(inv.motivo_no_integrable(_con_requisito, eco, 3)).is_equal("requiere estar entrenado en Medicina")
	_medicina.beneficio.aplicar(eco)
	assert_str(inv.motivo_no_integrable(_con_requisito, eco, 3)).is_empty()
	_con_requisito.beneficio.aplicar(eco)
	assert_bool(eco.capacidades.any(func(c: Capacidad) -> bool: return c.id == &"dote_de_prueba")).is_true()


func test_ver_una_vivencia_la_consume_al_diario_sin_ocupar_capacidad() -> void:
	var inv: InventarioRecuerdos = InventarioRecuerdos.new()
	inv.agregar_suelto(_vivencia)
	inv.agregar_suelto(_doliente)
	assert_str(inv.motivo_no_integrable(_vivencia, _eco(), 0)).is_empty()  # sin capacidad libre igual se ve
	inv.integrar(_vivencia)
	inv.integrar(_doliente)
	assert_array(inv.vistos).is_equal([_vivencia, _doliente])
	assert_array(inv.integrados).is_empty()
	assert_array(inv.sueltos).is_empty()


func test_soltar_un_integrado_lo_pierde_para_siempre() -> void:
	var inv: InventarioRecuerdos = InventarioRecuerdos.new()
	inv.agregar_suelto(_medicina)
	inv.integrar(_medicina)
	assert_bool(inv.soltar_integrado(_medicina)).is_true()
	assert_array(inv.integrados).is_empty()
	assert_array(inv.sueltos).is_empty()


# --- Tasador ---

func test_vender_acredita_la_mitad_y_comprar_cuesta_el_valor() -> void:
	var inv: InventarioRecuerdos = InventarioRecuerdos.new()
	var tasador: Tasador = Tasador.new()
	tasador.agregar_al_stock(_ocultismo)  # valor 30
	for r: DefinicionRecuerdo in [_medicina, _sigilo, _religion]:  # 20 + 20 + 30 → crédito 10 + 10 + 15 = 35
		inv.agregar_suelto(r)
		assert_str(tasador.vender(r, inv, _config)).is_empty()
	assert_int(tasador.credito).is_equal(35)
	assert_int(tasador.stock.size()).is_equal(4)  # lo vendido entra a su stock
	assert_str(tasador.comprar(0, inv, _config)).is_empty()
	assert_int(tasador.credito).is_equal(5)
	assert_array(inv.sueltos).is_equal([_ocultismo])


func test_sin_credito_suficiente_no_compra() -> void:
	var inv: InventarioRecuerdos = InventarioRecuerdos.new()
	var tasador: Tasador = Tasador.new()
	tasador.agregar_al_stock(_doliente)
	assert_str(tasador.comprar(0, inv, _config)).is_equal("crédito insuficiente (0 de 50)")
	assert_int(tasador.stock.size()).is_equal(1)


func test_los_del_doliente_no_se_venden() -> void:
	var inv: InventarioRecuerdos = InventarioRecuerdos.new()
	inv.agregar_suelto(_doliente)
	assert_str(Tasador.new().vender(_doliente, inv, _config)).is_equal("ese recuerdo no se vende")
	assert_array(inv.sueltos).is_equal([_doliente])


# --- Residuo ---

func test_al_morir_los_sueltos_quedan_en_el_residuo_menos_los_del_doliente() -> void:
	var estado: EstadoRecuerdos = EstadoRecuerdos.new()
	for r: DefinicionRecuerdo in [_medicina, _vivencia, _doliente]:
		estado.inventario.agregar_suelto(r)
	estado.muerte_del_eco(&"mapa_b", Vector2i(4, 5), _config)
	assert_array(estado.inventario.sueltos).is_equal([_doliente])
	assert_that(estado.residuo.celda).is_equal(Vector2i(4, 5))
	assert_array(estado.residuo.recuerdos).is_equal([_medicina, _vivencia])
	assert_array(estado.recuperar_residuo()).is_equal([_medicina, _vivencia])
	assert_bool(estado.hay_residuo()).is_false()
	assert_array(estado.inventario.sueltos).is_equal([_doliente, _medicina, _vivencia])


func test_morir_otra_vez_manda_el_residuo_anterior_al_tasador_con_recargo() -> void:
	var estado: EstadoRecuerdos = EstadoRecuerdos.new()
	estado.inventario.agregar_suelto(_medicina)
	estado.muerte_del_eco(&"mapa_b", Vector2i(4, 5), _config)
	estado.inventario.agregar_suelto(_sigilo)
	estado.muerte_del_eco(&"mapa_a", Vector2i(1, 1), _config)
	assert_array(estado.residuo.recuerdos).is_equal([_sigilo])
	assert_int(estado.tasador.stock.size()).is_equal(1)
	assert_int(estado.tasador.precio_venta(estado.tasador.stock[0], _config)).is_equal(30)  # 20 + 50 %


func test_morir_sin_sueltos_no_deja_residuo() -> void:
	var estado: EstadoRecuerdos = EstadoRecuerdos.new()
	estado.muerte_del_eco(&"mapa_b", Vector2i(4, 5), _config)
	assert_bool(estado.hay_residuo()).is_false()


# --- Guardado ---

func test_todo_el_estado_va_y_vuelve_de_un_diccionario() -> void:
	var estado: EstadoRecuerdos = EstadoRecuerdos.new()
	estado.inventario.agregar_suelto(_sigilo)
	estado.inventario.agregar_suelto(_medicina)
	estado.inventario.integrar(_medicina)
	estado.inventario.agregar_suelto(_vivencia)
	estado.inventario.integrar(_vivencia)
	estado.tasador.agregar_al_stock(_doliente)
	estado.tasador.agregar_al_stock(_religion, 50)
	estado.tasador.credito = 12
	estado.inventario.agregar_suelto(_ocultismo)
	estado.muerte_del_eco(&"mapa_b", Vector2i(4, 5), _config)
	estado.registrar_destino(EstadoRecuerdos.id_enemigo(&"mapa_b", &"Enemigo1"), EstadoRecuerdos.Destino.PERDONADO)
	var datos: Dictionary = JSON.parse_string(JSON.stringify(estado.a_diccionario()))
	var cargado: EstadoRecuerdos = EstadoRecuerdos.desde_diccionario(datos, _catalogo)
	assert_array(cargado.inventario.integrados).is_equal([_medicina])
	assert_array(cargado.inventario.vistos).is_equal([_vivencia])
	assert_array(cargado.inventario.sueltos).is_empty()
	assert_array(cargado.residuo.recuerdos).is_equal([_sigilo, _ocultismo])
	assert_that(cargado.residuo.celda).is_equal(Vector2i(4, 5))
	assert_int(cargado.tasador.credito).is_equal(12)
	assert_int(cargado.tasador.stock[1].recargo).is_equal(50)
	assert_int(cargado.destinos[&"mapa_b/Enemigo1"]).is_equal(EstadoRecuerdos.Destino.PERDONADO)

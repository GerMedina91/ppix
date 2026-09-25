extends GdUnitTestSuite
## Validación de datos de reglas: errores explícitos con push_error (también en release).

const RUTA_TEMPORAL: String = "user://test_modificador_invalido.tres"


func after() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(RUTA_TEMPORAL))


func _modificador(valor: int, tipo: Modificador.Tipo, fuente: String) -> DefinicionModificador:
	var definicion: DefinicionModificador = DefinicionModificador.new()
	definicion.valor = valor
	definicion.tipo = tipo
	definicion.fuente = fuente
	return definicion


func test_bonificador_sin_tipo_creado_en_codigo_informa_error_y_se_anula() -> void:
	var mensaje: String = Modificador.error_de_datos(2, Modificador.Tipo.SIN_TIPO, "Bendición")
	await assert_error(func() -> void: Modificador.new(2, Modificador.Tipo.SIN_TIPO, "Bendición")).is_push_error(mensaje)
	assert_int(SumaModificadores.total([Modificador.new(2, Modificador.Tipo.SIN_TIPO, "Bendición")])).is_equal(0)


func test_penalizador_sin_tipo_es_valido() -> void:
	assert_array(_modificador(-1, Modificador.Tipo.SIN_TIPO, "Herida").errores_de_datos()).is_empty()
	await assert_error(func() -> void: Modificador.new(-1, Modificador.Tipo.SIN_TIPO, "Herida")).is_success()


func test_definicion_de_bonificador_sin_tipo_es_invalida() -> void:
	var errores: PackedStringArray = _modificador(2, Modificador.Tipo.SIN_TIPO, "Bendición").errores_de_datos()
	assert_array(Array(errores)).contains([Modificador.error_de_datos(2, Modificador.Tipo.SIN_TIPO, "Bendición")])


func test_definicion_sin_fuente_es_invalida() -> void:
	assert_array(Array(_modificador(1, Modificador.Tipo.CIRCUNSTANCIA, " ").errores_de_datos())).is_not_empty()


func test_validar_informa_cada_error_con_push_error() -> void:
	var definicion: DefinicionModificador = _modificador(2, Modificador.Tipo.SIN_TIPO, "Bendición")
	var esperado: String = ValidacionDatos.mensaje(str(definicion), Modificador.error_de_datos(2, Modificador.Tipo.SIN_TIPO, "Bendición"))
	await assert_error(func() -> void: ValidacionDatos.validar(definicion)).is_push_error(esperado)


func test_cargar_un_recurso_invalido_devuelve_null() -> void:
	ResourceSaver.save(_modificador(3, Modificador.Tipo.SIN_TIPO, "Bendición"), RUTA_TEMPORAL)
	var esperado: String = ValidacionDatos.mensaje(RUTA_TEMPORAL, Modificador.error_de_datos(3, Modificador.Tipo.SIN_TIPO, "Bendición"))
	await assert_error(func() -> void: ValidacionDatos.cargar(RUTA_TEMPORAL)).is_push_error(esperado)
	assert_object(ValidacionDatos.cargar(RUTA_TEMPORAL)).is_null()


func test_cargar_un_recurso_valido_lo_devuelve() -> void:
	assert_object(ValidacionDatos.cargar("res://data/personajes/personaje_de_prueba.tres")).is_not_null()


func test_armadura_con_valores_negativos_es_invalida() -> void:
	var armadura: DefinicionArmadura = DefinicionArmadura.new()
	armadura.bonificador_ca = -1
	armadura.tope_destreza = -2
	assert_int(armadura.errores_de_datos().size()).is_equal(2)


func test_personaje_con_nivel_fuera_de_rango_o_armadura_invalida() -> void:
	var personaje: DefinicionPersonaje = DefinicionPersonaje.new()
	personaje.nivel = 21
	personaje.armadura = DefinicionArmadura.new()
	personaje.armadura.bonificador_ca = -1
	assert_int(personaje.errores_de_datos().size()).is_equal(2)


func test_todos_los_recursos_de_data_son_validos() -> void:
	var invalidos: Array[String] = []
	for ruta: String in _tres_en("res://data"):
		var recurso: Resource = load(ruta)
		if recurso != null and recurso.has_method(ValidacionDatos.METODO) and not recurso.call(ValidacionDatos.METODO).is_empty():
			invalidos.append(ruta)
	assert_array(invalidos).is_empty()


func _tres_en(carpeta: String) -> Array[String]:
	var rutas: Array[String] = []
	for archivo: String in DirAccess.get_files_at(carpeta):
		if archivo.ends_with(".tres"):
			rutas.append(carpeta.path_join(archivo))
	for sub: String in DirAccess.get_directories_at(carpeta):
		rutas.append_array(_tres_en(carpeta.path_join(sub)))
	return rutas

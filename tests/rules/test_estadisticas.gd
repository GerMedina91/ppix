extends GdUnitTestSuite
## Números de prueba, no contenido de clases ni ascendencias.

const DadosFijos: GDScript = preload("res://tests/utiles/dados_fijos.gd")
const R_ENTRENADO: Competencia.Rango = Competencia.Rango.ENTRENADO
const R_EXPERTO: Competencia.Rango = Competencia.Rango.EXPERTO


## Nivel 3: Fue +4, Des +3, Con +2, Int 0, Sab +1, Car 0. Entrenado = +5, experto = +7 a nivel 3.
func _personaje() -> DefinicionPersonaje:
	var p: DefinicionPersonaje = DefinicionPersonaje.new()
	p.nivel = 3
	p.fuerza = 4
	p.destreza = 3
	p.constitucion = 2
	p.sabiduria = 1
	p.percepcion = R_ENTRENADO
	p.fortaleza = R_EXPERTO
	p.reflejos = R_ENTRENADO
	p.voluntad = R_ENTRENADO
	for categoria: DefinicionArmadura.Categoria in DefinicionArmadura.Categoria.values():
		p.defensas[categoria] = R_ENTRENADO
	p.cd_clase = R_ENTRENADO
	p.atributo_clave = Atributo.Tipo.FUERZA
	p.pg_ascendencia = 8
	p.pg_clase_por_nivel = 10
	return p


func _armadura(bonificador: int, tope: int) -> DefinicionArmadura:
	var a: DefinicionArmadura = DefinicionArmadura.new()
	a.nombre = "armadura de prueba"
	a.bonificador_ca = bonificador
	a.tope_destreza = tope
	return a


func test_percepcion_usa_sabiduria() -> void:
	assert_int(Estadisticas.prueba_percepcion(_personaje()).modificador_total()).is_equal(1 + 5)


func test_salvaciones_usan_su_atributo_y_su_competencia() -> void:
	var p: DefinicionPersonaje = _personaje()
	assert_int(Estadisticas.prueba_salvacion(p, Estadisticas.Salvacion.FORTALEZA).modificador_total()).is_equal(2 + 7)
	assert_int(Estadisticas.prueba_salvacion(p, Estadisticas.Salvacion.REFLEJOS).modificador_total()).is_equal(3 + 5)
	assert_int(Estadisticas.prueba_salvacion(p, Estadisticas.Salvacion.VOLUNTAD).modificador_total()).is_equal(1 + 5)


func test_ca_sin_armadura_suma_toda_la_destreza() -> void:
	assert_int(Estadisticas.ca(_personaje())).is_equal(10 + 3 + 5)


func test_ca_con_armadura_aplica_tope_de_destreza_y_bonificador_de_objeto() -> void:
	var p: DefinicionPersonaje = _personaje()
	p.armadura = _armadura(4, 1)
	assert_int(Estadisticas.ca(p)).is_equal(10 + 1 + 5 + 4)


func test_ca_con_armadura_sin_tope() -> void:
	var p: DefinicionPersonaje = _personaje()
	p.armadura = _armadura(1, 0)
	p.armadura.tiene_tope_destreza = false
	assert_int(Estadisticas.ca(p)).is_equal(10 + 3 + 5 + 1)


func test_desglose_de_la_ca_muestra_la_armadura() -> void:
	var p: DefinicionPersonaje = _personaje()
	p.armadura = _armadura(4, 1)
	assert_array(Estadisticas.defensa(p).desglose()).is_equal([
		{"fuente": "Destreza", "valor": 1},
		{"fuente": "competencia (entrenado)", "valor": 5},
		{"fuente": "armadura de prueba", "valor": 4},
	])


func test_cd_de_clase_usa_el_atributo_clave() -> void:
	assert_int(Estadisticas.cd_clase(_personaje())).is_equal(10 + 4 + 5)


func test_pg_maximos() -> void:
	assert_int(Estadisticas.pg_maximos(_personaje())).is_equal(8 + (10 + 2) * 3)


func test_salvacion_se_tira_contra_una_cd() -> void:
	var prueba: Prueba = Estadisticas.prueba_salvacion(_personaje(), Estadisticas.Salvacion.REFLEJOS)
	var resultado: ResultadoPrueba = prueba.resolver(DadosFijos.new([12]), 20)
	assert_int(resultado.total).is_equal(12 + 8)
	assert_int(resultado.grado).is_equal(GradoExito.Grado.EXITO)


func test_carga_el_personaje_de_prueba_desde_data() -> void:
	var p: DefinicionPersonaje = load("res://data/personajes/personaje_de_prueba.tres")
	assert_object(p).is_not_null()
	assert_str(p.nombre).starts_with("TODO_LORE")
	assert_int(Estadisticas.pg_maximos(p)).is_greater(0)

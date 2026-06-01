extends Node2D

const columnas = 13
const filas = 11
const vacio = 0
const destructible = 1
const indestructible = 2
const prob_indestructible = 10
const prob_destructible = 90
const escena_destructible = preload("res://Escenas/Juego/BloqueDestructible.tscn")
const escena_indestructible = preload("res://Escenas/Juego/BloqueIndestructible.tscn")
const escena_copa = preload("res://Escenas/Juego/CopaMundial.tscn")
const textura_suelo = preload("res://Assets/Bloques/barrera.png")

@onready var capa_suelo = $CapaSuelo
@onready var pausa = $Pausa

var matriz: Array = []
var bloques: Array = []
var idtiles: int = 0

const zonas_seguras = [
	Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2),
	Vector2i(1, 9), Vector2i(2, 9), Vector2i(1, 8),
	Vector2i(11, 1), Vector2i(10, 1), Vector2i(11, 2),
	Vector2i(11, 9), Vector2i(10, 9), Vector2i(11, 8),
	Vector2i(5, 5), Vector2i(5, 6), Vector2i(6, 5), Vector2i(6, 6),
	Vector2i(5, 4), Vector2i(6, 4), Vector2i(7, 4), Vector2i(7, 5), Vector2i(7, 6),
]

func _ready() -> void:
	pausa.visible = false
	idtiles = capa_suelo.tile_set.get_source_id(0)
	_generar_mapa()
	_colocar_copa()
	_conectar_enemigos()
	_conectar_jugador()
	await get_tree().physics_frame
	$NavigationRegion2D.bake_navigation_polygon()

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if get_tree().paused:
			get_tree().paused = false
			pausa.visible = false
		else:
			get_tree().paused = true
			pausa.visible = true

func _generar_mapa() -> void:
	matriz.clear()
	bloques.clear()
	for fila in range(filas):
		var fila_actual: Array = []
		var bloques_fila: Array = []
		for columna in range(columnas):
			var tipo = _determinar_tipo_celda(fila, columna)
			fila_actual.append(tipo)
			bloques_fila.append(_instanciar_celda(fila, columna, tipo))
		matriz.append(fila_actual)
		bloques.append(bloques_fila)

func _determinar_tipo_celda(fila: int, columna: int) -> int:
	if fila == 0 or fila == filas - 1 or columna == 0 or columna == columnas - 1:
		return indestructible
	if Vector2i(columna, fila) in zonas_seguras:
		return vacio
	if fila % 2 == 0 and columna % 2 == 0:
		return indestructible
	var azar = randi() % 100
	if azar < prob_indestructible:
		return indestructible
	elif azar < prob_indestructible + prob_destructible:
		return destructible
	else:
		return vacio

func _instanciar_celda(fila: int, columna: int, tipo: int) -> Node:
	capa_suelo.set_cell(Vector2i(columna, fila), idtiles, Vector2i(0, 0))
	var posicion = Vector2(columna * 64, fila * 64)
	match tipo:
		vacio:
			return null
		destructible:
			var bloque = escena_destructible.instantiate()
			add_child(bloque)
			bloque.position = posicion
			bloque.inicializar(textura_suelo)
			return bloque
		indestructible:
			var bloque = escena_indestructible.instantiate()
			add_child(bloque)
			bloque.position = posicion
			return bloque
	return null

func _colocar_copa() -> void:
	var copa = escena_copa.instantiate()
	add_child(copa)
	copa.position = Vector2(6 * 64, 5 * 64)

func _conectar_enemigos():
	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		enemigo.connect("enemigo_murio", _on_enemigo_murio)

func _conectar_jugador():
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador:
		jugador.connect("jugador_murio", _on_jugador_murio)

func _on_enemigo_murio():
	await get_tree().process_frame
	var enemigos_vivos = get_tree().get_nodes_in_group("enemigos").size()
	if enemigos_vivos == 0:
		get_tree().change_scene_to_file("res://Escenas/Juego/Victoria.tscn")

func _on_jugador_murio():
	get_tree().change_scene_to_file("res://Escenas/Juego/Derrota.tscn")

func obtener_celda(fila: int, columna: int) -> int:
	return matriz[fila][columna]

func destruir_celda(fila: int, columna: int) -> void:
	matriz[fila][columna] = vacio
	if bloques[fila][columna] != null:
		bloques[fila][columna].destruir()

extends CharacterBody2D

@export var velocidad : float = 80.0
@export var vida: float= 1
@export var escena_bomba : PackedScene
@export var distancia_deteccion : float = 200.0

signal enemigo_murio

var vida_actual
var esta_muerto = false
var tiempo_poner_bomba = 0.0
var jugador = null
enum Estado { ALEATORIO, PERSEGUIR, ESCONDERSE }
var estado_actual = Estado.ALEATORIO
var direcciones = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
var direccion_aleatoria = Vector2.RIGHT
var tiempo_cambio_direccion = 0.0
var tiempo_escondido = 0.0
var direccion_escape = Vector2.ZERO

@onready var sprite = $AnimatedSprite2D
@onready var navigation_agent = $NavigationAgent2D

func _ready():
	vida_actual = vida
	direccion_aleatoria = direcciones[randi() % direcciones.size()]
	tiempo_cambio_direccion = randf_range(1.0, 3.0)
	tiempo_poner_bomba = randf_range(2.0, 4.0)
	
	var paises_disponibles = ["argentina", "brasil", "alemania", "francia", "italia"]
	paises_disponibles.erase(DatosJuego.pais_jugador)
	paises_disponibles.shuffle()
	var pais_enemigo = paises_disponibles[randi() % paises_disponibles.size()]
	var animaciones_enemigo = load("res://Assets/Paises/" + pais_enemigo + ".tres")
	sprite.sprite_frames = animaciones_enemigo
	
	await get_tree().create_timer(0.5).timeout
	jugador = get_tree().get_first_node_in_group("jugador")

func _physics_process(delta):
	if esta_muerto:
		return
	if jugador == null or not is_instance_valid(jugador):
		return
	var distancia_al_jugador : float = global_position.distance_to(jugador.global_position)
	if estado_actual != Estado.ESCONDERSE:
		if distancia_al_jugador < distancia_deteccion:
			estado_actual = Estado.PERSEGUIR
		else:
			estado_actual = Estado.ALEATORIO
	match estado_actual:
		Estado.ALEATORIO:
			_mover_aleatorio(delta)
		Estado.PERSEGUIR:
			_mover_perseguir(delta)
		Estado.ESCONDERSE:
			_mover_esconderse(delta)
	move_and_slide()
	_actualizar_animacion()

func _mover_aleatorio(delta):
	tiempo_cambio_direccion -= delta
	if tiempo_cambio_direccion <= 0:
		direccion_aleatoria = direcciones[randi() % direcciones.size()]
		tiempo_cambio_direccion = randf_range(1.0, 3.0)
	if get_last_slide_collision():
		var cuerpo = get_last_slide_collision().get_collider()
		if cuerpo == null:
			return
		if cuerpo.is_in_group("destructibles"):
			poner_bomba()
			return
		direccion_aleatoria = direcciones[randi() % direcciones.size()]
	tiempo_poner_bomba -= delta
	if tiempo_poner_bomba <= 0.0:
		_revisar_bloque_cerca()
		tiempo_poner_bomba = randf_range(2.0, 4.0)
	velocity = direccion_aleatoria * velocidad * 0.5

func _mover_perseguir(delta):
	if jugador == null or not is_instance_valid(jugador):
		return
	var direccion = (jugador.global_position - global_position).normalized()
	velocity = direccion * velocidad
	if get_last_slide_collision():
		var cuerpo = get_last_slide_collision().get_collider()
		if cuerpo == null:
			return
		if cuerpo.is_in_group("destructibles"):
			poner_bomba()
			return
		var opciones = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
		opciones.erase(direccion.round())
		velocity = opciones[randi() % opciones.size()] * velocidad
	tiempo_poner_bomba -= delta
	if tiempo_poner_bomba <= 0.0:
		_revisar_bloque_cerca()
		tiempo_poner_bomba = randf_range(2.0, 4.0)
	var distancia = global_position.distance_to(jugador.global_position)
	if distancia < 80:
		poner_bomba()

func _mover_esconderse(delta):
	tiempo_escondido -= delta
	if tiempo_escondido <= 0.0:
		estado_actual = Estado.ALEATORIO
		direccion_escape = Vector2.ZERO
		return
	if jugador == null or not is_instance_valid(jugador):
		return
	if direccion_escape == Vector2.ZERO:
		direccion_escape = (global_position - jugador.global_position).normalized()
	if get_last_slide_collision():
		var opciones = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
		opciones.erase(direccion_escape.round())
		direccion_escape = opciones[randi() % opciones.size()]
	velocity = direccion_escape * velocidad

func _revisar_bloque_cerca():
	var bloques_destructibles = get_tree().get_nodes_in_group("destructibles")
	for bloque in bloques_destructibles:
		if global_position.distance_to(bloque.global_position) < 80:
			poner_bomba()
			return

func poner_bomba():
	if escena_bomba == null:
		return
	var bomba = escena_bomba.instantiate()
	bomba.global_position = Vector2(
		snapped(global_position.x, 32),
		snapped(global_position.y - 64, 32)
	)
	bomba.dueño = self
	get_parent().add_child(bomba)
	estado_actual = Estado.ESCONDERSE
	tiempo_escondido = 2.5

func _esquivar_explosiones():
	var explosiones = get_tree().get_nodes_in_group("explosiones")
	for explosion in explosiones:
		if global_position.distance_to(explosion.global_position) < 96:
			estado_actual = Estado.ESCONDERSE
			tiempo_escondido = 2.0
			direccion_escape = (global_position - explosion.global_position).normalized()
			return

func _actualizar_animacion():
	var dir = velocity.normalized()
	if dir == Vector2.ZERO:
		sprite.play("parado")
		return
	if abs(dir.x) > abs(dir.y):
		sprite.play("caminar")
		sprite.flip_h = (dir.x < 0)
	elif dir.y < 0:
		sprite.flip_h = false
		sprite.play("espalda")
	else:
		sprite.flip_h = false
		sprite.play("frente")

func recibir_danio():
	if esta_muerto:
		return
	vida_actual -= 1
	if vida_actual <= 0:
		esta_muerto = true
		velocity = Vector2.ZERO
		sprite.play("morir")
		await get_tree().create_timer(1.7).timeout
		enemigo_murio.emit()
		queue_free()

func _on_animated_sprite_2d_animation_finished():
	if sprite.animation == "morir":
		enemigo_murio.emit()
		queue_free()

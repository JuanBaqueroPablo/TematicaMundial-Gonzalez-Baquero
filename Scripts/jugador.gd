extends CharacterBody2D

@export var velocidad = 100
@export var vida = 1
@export var max_bombas = 1
@export var escena_bomba: PackedScene
var vida_actual
var bombas_puestas = 0
var dir_actual = "abajo"
var puede_poner_bomba = true
var invulnerable = false
var esta_muerto = false
var bomba_actual = null
signal jugador_murio

@onready var sprite = $AnimatedSprite2D

func _ready():
	velocidad = DatosJuego.velocidad
	vida = DatosJuego.vida
	vida_actual = DatosJuego.vida
	max_bombas = DatosJuego.max_bombas
	var ruta_animaciones_pais = "res://Assets/Paises/" + DatosJuego.pais_jugador + ".tres"
	var animaciones_pais = load(ruta_animaciones_pais)
	sprite.sprite_frames = animaciones_pais

func _physics_process(delta):
	if esta_muerto:
		return
	var dir = Vector2.ZERO
	if Input.is_key_pressed(KEY_LEFT):
		dir.x = -1
		dir_actual = "izquierda"
	elif Input.is_key_pressed(KEY_RIGHT):
		dir.x = 1
		dir_actual = "derecha"
	elif Input.is_key_pressed(KEY_UP):
		dir.y = -1
		dir_actual = "arriba"
	elif Input.is_key_pressed(KEY_DOWN):
		dir.y = 1
		dir_actual = "abajo"
	if dir.length() > 0:
		velocity = dir.normalized() * velocidad
		if dir_actual == "izquierda" or dir_actual == "derecha":
			sprite.play("caminar")
			sprite.flip_h = (dir_actual == "izquierda")
		elif dir_actual == "arriba":
			sprite.flip_h = false
			sprite.play("espalda")
		elif dir_actual == "abajo":
			sprite.flip_h = false
			sprite.play("frente")
	else:
		velocity = Vector2.ZERO
		sprite.play("parado")
	move_and_slide()
	if Input.is_action_just_pressed("ui_accept") and bombas_puestas < max_bombas:
		poner_bomba()
	if bomba_actual != null:
		var distancia = global_position.distance_to(bomba_actual.global_position)
		if distancia > 48:
			remove_collision_exception_with(bomba_actual)
			bomba_actual = null

func poner_bomba():
	if escena_bomba == null or bombas_puestas >= max_bombas:
		return
	var bomba = escena_bomba.instantiate()
	var pos_snapped = Vector2(
		snapped(global_position.x, 32),
		snapped(global_position.y - 64, 32)
	)
	bomba.global_position = pos_snapped
	bomba.connect("explotar", _on_bomba_exploto)
	get_parent().add_child(bomba)
	var static_body = bomba.get_node("StaticBody2D")
	add_collision_exception_with(static_body)
	bomba_actual = static_body
	bombas_puestas += 1
	puede_poner_bomba = false
	await get_tree().create_timer(DatosJuego.tiempo_bomba).timeout
	puede_poner_bomba = true

func _on_bomba_exploto():
	bombas_puestas -= 1

func recibir_danio():
	if invulnerable or esta_muerto:
		return
	invulnerable = true
	vida_actual -= 1
	if vida_actual <= 0:
		esta_muerto = true
		sprite.play("morir")
		await get_tree().create_timer(1.7).timeout
		jugador_murio.emit()
		queue_free()
	else:
		await get_tree().create_timer(1.0).timeout
		invulnerable = false

func _on_animated_sprite_2d_animation_finished():
	if sprite.animation == "morir":
		jugador_murio.emit()
		queue_free()

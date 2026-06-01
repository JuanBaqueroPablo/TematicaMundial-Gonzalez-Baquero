extends Area2D

signal explotar

var rango = 1
var tiempo = 3.0
var jugador = null
var dueño = null

@onready var sprite = $AnimatedSprite2D
@onready var temporizador = $Timer

@export var escena_explosion: PackedScene

func _ready():
	if DatosJuego.pais_jugador == "argentina":
		rango = 2
	sprite.play("latiendo")
	temporizador.wait_time = tiempo
	temporizador.one_shot = true
	temporizador.start()
	temporizador.timeout.connect(_explotar)

func _explotar():
	sprite.play("explotar")
	explotar.emit()
	if jugador:
		jugador.bomba_explotada()
	
	crear_explosion(global_position)
	
	var direcciones = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	for dir in direcciones:
		for i in range(1, rango + 1):
			var pos = global_position + dir * 32 * i
			var bloqueado = false
			for bloque in get_tree().get_nodes_in_group("indestructibles"):
				if bloque.global_position.distance_to(pos) < 40:
					bloqueado = true
					break
			if bloqueado:
				break
			crear_explosion(pos)
	
	queue_free()

func crear_explosion(pos: Vector2):
	if escena_explosion == null:
		return
	var exp = escena_explosion.instantiate()
	exp.global_position = pos
	exp.dueño = dueño
	get_parent().add_child(exp)

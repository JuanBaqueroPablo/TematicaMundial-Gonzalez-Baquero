extends StaticBody2D

@onready var sprite = $Sprite2D
@onready var colision = $CollisionShape2D

var textura_suelo: Texture2D

func inicializar(tex_suelo):
	textura_suelo = tex_suelo

func destruir():
	queue_free()

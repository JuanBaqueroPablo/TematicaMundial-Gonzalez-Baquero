extends Area2D

@onready var temporizador = $Timer
var rango = 1
var dueño = null

func _ready():
	temporizador.wait_time = 0.8
	temporizador.one_shot = true
	temporizador.start()
	temporizador.timeout.connect(queue_free)
	body_entered.connect(_en_contacto)
	queue_redraw()

func _en_contacto(cuerpo):
	if cuerpo == dueño:
		return
	if cuerpo.has_method("recibir_danio"):
		cuerpo.recibir_danio()
	if cuerpo.has_method("destruir"):
		cuerpo.destruir()

extends Control

func _ready():
	pass

func _on_btn_argentina_pressed():
	DatosJuego.pais_jugador = "argentina"
	DatosJuego.velocidad = 100
	DatosJuego.vida = 1
	DatosJuego.max_bombas = 1
	DatosJuego.tiempo_bomba = 5.0
	mostrar_info("Argentina", "Bombazo", "Rango de explosion x2")

func _on_btn_brasil_pressed():
	DatosJuego.pais_jugador = "brasil"
	DatosJuego.velocidad = 220
	DatosJuego.vida = 1
	DatosJuego.max_bombas = 1
	DatosJuego.tiempo_bomba = 5.0
	mostrar_info("Brasil", "Veloz", "Velocidad 220")

func _on_btn_alemania_pressed():
	DatosJuego.pais_jugador = "alemania"
	DatosJuego.velocidad = 100
	DatosJuego.vida = 1
	DatosJuego.max_bombas = 2
	DatosJuego.tiempo_bomba = 5.0
	mostrar_info("Alemania", "Doble Bomba", "2 bombas a la vez")

func _on_btn_uruguay_pressed():
	DatosJuego.pais_jugador = "uruguay"
	DatosJuego.velocidad = 100
	DatosJuego.vida = 2
	DatosJuego.max_bombas = 1
	DatosJuego.tiempo_bomba = 5.0
	mostrar_info("Uruguay", "Garra Charrua", "2 vidas")

func _on_btn_francia_pressed():
	DatosJuego.pais_jugador = "francia"
	DatosJuego.velocidad = 100
	DatosJuego.vida = 1
	DatosJuego.max_bombas = 1
	DatosJuego.tiempo_bomba = 1.5
	mostrar_info("Francia", "Bomba Rapida", "Explota en 1.5 seg")

func _on_btn_italia_pressed():
	DatosJuego.pais_jugador = "italia"
	DatosJuego.velocidad = 50
	DatosJuego.vida = 3
	DatosJuego.max_bombas = 1
	DatosJuego.tiempo_bomba = 5.0
	mostrar_info("Italia", "Resistente", "3 golpes para morir, menor velocidad")

func mostrar_info(nombre, habilidad, efecto):
	$VBoxContainer/LabelNombre.text = nombre
	$VBoxContainer/LabelHabilidad.text = "Habilidad: " + habilidad
	$VBoxContainer/LabelEfecto.text = "Efecto: " + efecto
	$VBoxContainer/BtnConfirmar.visible = true

func _on_btn_confirmar_pressed():
	get_tree().change_scene_to_file("res://Escenas/Juego/mapa.tscn")

func _on_btn_volver_pressed():
	get_tree().change_scene_to_file("res://Escenas/Juego/inicio.tscn")

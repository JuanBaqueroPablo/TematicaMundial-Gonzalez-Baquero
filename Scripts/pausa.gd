extends CanvasLayer

func _on_btn_continuar_pressed():
	get_tree().paused = false
	visible = false

func _on_btn_controles_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Escenas/Juego/controles.tscn")

func _on_btn_salir_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Escenas/Menu/Juego/inicio.tscn")

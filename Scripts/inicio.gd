extends Control

func _on_btn_jugar_pressed():
	get_tree().change_scene_to_file("res://Escenas/Juego/seleccion_paises.tscn")

func _on_btn_controles_pressed():
	get_tree().change_scene_to_file("res://Escenas/Juego/controles.tscn")

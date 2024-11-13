extends Control

@onready var start : Button = $VBoxContainer/Start
@onready var options : Button = $VBoxContainer/Options
@onready var exit : Button = $VBoxContainer/Exit


func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/mainGame.tscn")

func _on_options_pressed():
	pass # Replace with function body.

func _on_exit_pressed():
	get_tree().quit()

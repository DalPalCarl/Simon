extends Node3D

@onready var gameAnimPlayer : AnimationPlayer = $MemoryGame/AnimationPlayer
@onready var worldAnimPlayer : AnimationPlayer = $AnimationPlayer

func _ready():
	press_buttons()
	worldAnimPlayer.play("fadeIn")

func _on_start_pressed():
	worldAnimPlayer.play("fadeOut")

func _on_exit_pressed():
	get_tree().quit()

func press_buttons():
	await get_tree().create_timer(6.0).timeout
	var randButton = randi_range(0, 3)
	match randButton:
		0:
			gameAnimPlayer.play("R")
		1:
			gameAnimPlayer.play("G")
		2:
			gameAnimPlayer.play("B")
		3:
			gameAnimPlayer.play("Y")
	press_buttons()



func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fadeOut":
		get_tree().change_scene_to_file("res://scenes/mainGame.tscn")

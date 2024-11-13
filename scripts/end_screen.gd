extends Control

@onready var minutes : Label = $minutes
@onready var seconds : Label = $seconds

func _ready():
	minutes.text = str(snappedf(Score.score, 0.01)) + " seconds"

func _on_animation_player_animation_finished(anim_name):
	get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")

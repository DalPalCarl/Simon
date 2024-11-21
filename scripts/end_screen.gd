extends Control

@onready var minutes : Label = $minutes
@onready var seconds : Label = $seconds

func _ready():
	var minuteVal = int(Score.score / 60)
	var secondVal = int(Score.score) % 60
	if minuteVal < 1:
		minutes.text = ""
	elif minuteVal == 1:
		minutes.text = "1 minute"
	else:
		minutes.text = str(snapped(minuteVal, 1)) + " minutes"
	seconds.text = str(snappedf(Score.score, 0.01)) + " seconds"

func _on_animation_player_animation_finished(anim_name):
	get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")

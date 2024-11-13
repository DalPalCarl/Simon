extends Control

@onready var timer : Label = $Time
var time : float = 0.0

func _ready():
	timer.text = "0.0"

func _process(delta):
	timer.text = str(get_parent().timeSurvived)


func _on_simon_5_player_fail():
	self.process_mode = Node.PROCESS_MODE_DISABLED

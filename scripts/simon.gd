extends Node3D

var hellStarted : bool = false
@onready var mvmtTimer : Timer = $MovementTimer

func _ready():
	pass

func _process(delta):
	pass

func _on_world_move_simon():
	pass

func _on_movement_timer_timeout():
	print("Timeout!")

func _on_world_begin_hell():
	hellStarted = true
	mvmtTimer.start()

func _on_memory_game_emit_light():
	mvmtTimer.start()

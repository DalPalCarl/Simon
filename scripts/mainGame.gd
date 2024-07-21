extends Node3D

signal beginHell
signal moveSimon
@onready var simon = $Simon
@onready var memory_game = $MemoryGame
@onready var movement_buttons : CanvasLayer = $MButtons
@onready var eyelidsAnim : AnimationPlayer = $Eyelids/AnimationPlayer
@onready var playerSounds : AnimationPlayer = $playerSounds
@onready var environment : AnimationPlayer = $Environment
@onready var bookshelf = $CornerPositions/Bookshelf
@onready var backCorner = $CornerPositions/BackCorner
@onready var bed = $CornerPositions/Bed
@onready var closet = $CornerPositions/Closet

@onready var mvmtTimer : Timer = $Simon/MovementTimer
@onready var footsteps : AudioStreamPlayer = $footsteps

@onready var bcCam : Camera3D = $BackCornerCam
@onready var bsCam : Camera3D = $BookshelfCam
@onready var bedCam : Camera3D = $BedCam
@onready var cCam : Camera3D = $ClosetCam

@onready var corners = [backCorner, bookshelf, bed, closet]
@onready var cameras = [bcCam, bsCam, bedCam, cCam]
@onready var names = ["Corner", "Bookshelf", "Bed", "Closet"]

@onready var introTimer = $introTimer
@onready var newscasterVoiceTimer = $NewsCaster

var player_pos
var prev_pos

var monster_pos
var monster_ready : bool = false
var isHell : bool = false

func _ready():
	player_pos = 0
	prev_pos = 0
	introTimer.start()
	newscasterVoiceTimer.start()
	update_position()

func _on_left_pressed():
	mvmtTimer.stop()
	if player_pos == 0:
		player_pos -= 1
	eyelidsAnim.play("eye_close")
	await get_tree().create_timer(0.5).timeout
	playerSounds.play(names[prev_pos] + "_to_" + names[player_pos])
	prev_pos = player_pos
	update_position()

func _on_right_pressed():
	if player_pos == 3:
		player_pos = 0
	else:
		player_pos += 1
	eyelidsAnim.play("eye_close")
	await get_tree().create_timer(0.5).timeout
	playerSounds.play(names[prev_pos] + "_to_" + names[player_pos])
	prev_pos = player_pos
	update_position()

func update_position():
	movement_buttons.visible = false
	movement_buttons.get_child(0).text = names[(player_pos+3)%4]
	movement_buttons.get_child(1).text = names[(player_pos+1)%4]
	memory_game.position = corners[player_pos].position
	memory_game.rotation = corners[player_pos].rotation
	cameras[player_pos].current = true

func monster_move():
	#Monster movement will depend on where Simon is positionally
	
	# Distance from player: 2
	if ((monster_pos + 2) % 4) == player_pos:
		if randf() >= 0.5:
			if monster_pos == 3:
				monster_pos = 0
			else:
				monster_pos += 1
		else:
			if monster_pos == 0:
				monster_pos = 3
			else:
				monster_pos -= 1
		simon.position = corners[monster_pos].position
	
	# Distance from player: 1
	elif ((monster_pos + 1) % 4) == player_pos or ((monster_pos + 3) % 4) == player_pos:
		monster_pos = player_pos
		simon.position = corners[monster_pos].position
		at_player_position()
	
	simon.look_at(cameras[player_pos].global_position, Vector3.UP)

func at_player_position():
	# Distance from player: 0
	# In this case, the player has to play the game correctly without messing up until
	# Simon goes away
	
	await get_tree().create_timer(6.0 + randf_range(0.0, 14.0)).timeout
	monster_pos += (randi_range(1,3) % 4)

func _on_player_sounds_animation_finished(_anim_name):
	eyelidsAnim.play_backwards("eye_close")

func _on_intro_timer_timeout():
	beginHell.emit()
	environment.play("flicker_lights_off")
	await environment.animation_finished
	$CeilingFan.stop_fans()
	await get_tree().create_timer(3.0).timeout
	$Breakin.play()
	await get_tree().create_timer(6.0).timeout
	$DoorOpenClose.play()
	await get_tree().create_timer(3.0).timeout
	movement_buttons.visible = true
	monster_pos = (player_pos+2)%4
	simon.position = corners[monster_pos].position
	monster_ready = true

func _on_news_caster_timeout():
	movement_buttons.visible = false

func _on_memory_game_fail():
	if monster_ready:
		if randf() > 0.5:
			monster_move()

func _on_movement_timer_timeout():
	if monster_ready:
		if randf() > 0.72:
			monster_move()

func _on_memory_game_emit_light():
	mvmtTimer.start()

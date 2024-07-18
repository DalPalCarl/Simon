extends Node3D

@onready var memory_game = $MemoryGame
@onready var movement_buttons : CanvasLayer = $MButtons
@onready var eyelidsAnim : AnimationPlayer = $Eyelids/AnimationPlayer
@onready var playerSounds : AnimationPlayer = $playerSounds
@onready var environment : AnimationPlayer = $Environment
@onready var bookshelf = $CornerPositions/Bookshelf
@onready var backCorner = $CornerPositions/BackCorner
@onready var bed = $CornerPositions/Bed
@onready var closet = $CornerPositions/Closet

@onready var footsteps : AudioStreamPlayer = $footsteps

@onready var bcCam : Camera3D = $BackCornerCam
@onready var bsCam : Camera3D = $BookshelfCam
@onready var bedCam : Camera3D = $BedCam
@onready var cCam : Camera3D = $ClosetCam

@onready var corners = [backCorner, bookshelf, bed, closet]
@onready var cameras = [bcCam, bsCam, bedCam, cCam]
@onready var names = ["Corner", "Bookshelf", "Bed", "Closet"]

@onready var introTimer = $introTimer

var pos
var prev_pos

func _ready():
	pos = 0
	prev_pos = 0
	introTimer.start()
	update_position()

func _on_left_pressed():
	if pos == 0:
		pos = 3
	else:
		pos -= 1
	eyelidsAnim.play("eye_close")
	await get_tree().create_timer(0.5).timeout
	playerSounds.play(names[prev_pos] + "_to_" + names[pos])
	prev_pos = pos
	update_position()

func _on_right_pressed():
	if pos == 3:
		pos = 0
	else:
		pos += 1
	eyelidsAnim.play("eye_close")
	await get_tree().create_timer(0.5).timeout
	playerSounds.play(names[prev_pos] + "_to_" + names[pos])
	prev_pos = pos
	update_position()

func update_position():
	movement_buttons.visible = false
	if pos == 0:
		movement_buttons.get_child(0).text = names[3]
		movement_buttons.get_child(1).text = names[pos+1]
	elif pos == 3:
		movement_buttons.get_child(0).text = names[pos-1]
		movement_buttons.get_child(1).text = names[0]
	else:
		movement_buttons.get_child(0).text = names[pos-1]
		movement_buttons.get_child(1).text = names[pos+1]
	memory_game.position = corners[pos].position
	memory_game.rotation = corners[pos].rotation
	cameras[pos].current = true
	


func _on_player_sounds_animation_finished(_anim_name):
	eyelidsAnim.play_backwards("eye_close")


func _on_intro_timer_timeout():
	environment.play("flicker_lights_off")
	await environment.animation_finished
	$CeilingFan.stop_fans()
	await get_tree().create_timer(3.0).timeout
	$Breakin.play()
	await get_tree().create_timer(6.0).timeout
	$DoorOpenClose.play()
	

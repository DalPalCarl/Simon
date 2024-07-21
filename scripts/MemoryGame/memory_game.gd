extends Node3D

signal fail
signal emitLight
signal showMButtons
signal hideMButtons
@onready var seq_timer : Timer = $Timer
@onready var anim_Player : AnimationPlayer = $AnimationPlayer
@onready var buttonG : MeshInstance3D = $buttonGreen
@onready var buttonR : MeshInstance3D = $buttonRed
@onready var buttonY : MeshInstance3D = $buttonYellow
@onready var buttonB : MeshInstance3D = $buttonBlue

var sequence = []
var player_sequence = []
var displaying = true
var paused : bool = false

func _ready():
	await get_tree().create_timer(3.0).timeout
	start_new_round()

func _process(_delta):
	if Input.is_action_just_pressed("Exit"):
		get_tree().quit()

func start_new_round():
	add_random_color_to_sequence()
	display_sequence()

func add_random_color_to_sequence():
	var colors = ["B", "G", "R", "Y"]
	var rand_color = colors[randi() % 4]
	sequence.append(rand_color)

func display_sequence():
	displaying = true
	hideMButtons.emit()
	player_sequence.clear()
	seq_timer.start(1.0)
	for i in range(sequence.size()):
		if paused:
			break
		await get_tree().create_timer(1.0).timeout
		anim_Player.play(sequence[i])
	await get_tree().create_timer(0.5).timeout
	displaying = false
	showMButtons.emit()

func button_pressed(color):
	if color != sequence[player_sequence.size()]:
		failstate()
	else:
		player_sequence.append(color)
		if player_sequence.size() == sequence.size():
			print("Correct!")
			start_new_round()

func failstate():
	anim_Player.stop()
	fail.emit()
	hideMButtons.emit()
	$failSound.play()
	displaying = true
	await get_tree().create_timer(2.0).timeout
	sequence.clear()
	player_sequence.clear()
	start_new_round()
	
func _on_button_blue_blue_pressed():
	if !displaying:
		if anim_Player.is_playing():
			anim_Player.stop()
		anim_Player.play("B")
		emitLight.emit()
		if !displaying:
			button_pressed("B")

func _on_button_red_red_pressed():
	if !displaying:
		if anim_Player.is_playing():
			anim_Player.stop()
		anim_Player.play("R")
		emitLight.emit()
		if !displaying:
			button_pressed("R")

func _on_button_yellow_yellow_pressed():
	if !displaying:
		if anim_Player.is_playing():
			anim_Player.stop()
		anim_Player.play("Y")
		emitLight.emit()
		if !displaying:
			button_pressed("Y")

func _on_button_green_green_pressed():
	if !displaying:
		if anim_Player.is_playing():
			anim_Player.stop()
		anim_Player.play("G")
		emitLight.emit()
		if !displaying:
			button_pressed("G")


func _on_world_begin_hell():
	paused = true
	displaying = true
	await get_tree().create_timer(18.0).timeout
	paused = false
	displaying = false
	sequence.clear()
	player_sequence.clear()
	start_new_round()

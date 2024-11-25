extends Node3D

signal beginHell
signal moveSimon
signal jumpscare

@onready var simon = $Simon5
@onready var timerScore : Label = $timerLabel/TimerScore
@onready var testLabel : Label = $timerLabel/TestLabel
@onready var testMvmtTimer : Label = $timerLabel/TestMvmtTimer
@onready var memory_game = $MemoryGame
@onready var radio = $Radio
@onready var movement_buttons : CanvasLayer = $MButtons
@onready var eyelidsAnim : AnimationPlayer = $Eyelids/AnimationPlayer
@onready var playerSounds : AnimationPlayer = $playerSounds
@onready var environment : AnimationPlayer = $Environment
@onready var bookshelf = $CornerPositions/Bookshelf
@onready var backCorner = $CornerPositions/BackCorner
@onready var bed = $CornerPositions/Bed
@onready var closet = $CornerPositions/Closet

@onready var mvmtTimer : Timer = $MovementTimer
@onready var primedTimer : Timer = $PrimedTimer
@onready var footsteps : AudioStreamPlayer = $footsteps

@onready var bcCam : Camera3D = $BackCornerCam
@onready var bsCam : Camera3D = $BookshelfCam
@onready var bedCam : Camera3D = $BedCam
@onready var cCam : Camera3D = $ClosetCam

@onready var corners = [backCorner, bookshelf, bed, closet]
@onready var cameras = [bcCam, bsCam, bedCam, cCam]
@onready var names = ["Corner", "Bookshelf", "Bed", "Closet"]

@onready var introTimer : Timer = $introTimer
@onready var newscasterVoiceTimer = $NewsCaster

@onready var drone : AudioStreamPlayer = $stringsDrone
var timeSurvived : float = 0.0

enum States {
	INACTIVE,
	ACTIVE,
	PRIMED,
	SCARE
}
var simon_state : States = States.INACTIVE

var player_pos
var prev_pos
var monster_pos
var isLit : bool = false
var dead : bool = false
var showingButtons : bool = true

func _ready():
	player_pos = 0
	prev_pos = 0
	introTimer.start()
	newscasterVoiceTimer.start()
	update_position()

func _process(delta):
	#When primed (simon is at player), the player cannot:
	# 1 - mess up sequence
	# 2 - wait too long for input
	# 3 - move locations
	# or they will die.  We want the drone to play, and we want the primed
	# state to last for a random time between 6 and 20 sec, and after the
	# timer runs out, we 
	if (simon_state == States.ACTIVE or simon_state == States.PRIMED) and !dead:
		timeSurvived += delta
		timerScore.text = str(snappedf(timeSurvived, 0.01))
	if Input.is_action_just_pressed("Debug"):
		radio.queue_free()
		newscasterVoiceTimer.start(1.0)
		introTimer.start(1.0)
	
	testLabel.text = str(simon_state)
	testMvmtTimer.text = str(mvmtTimer.time_left)

func state_transition(prev_state : States, new_state : States):
	if prev_state == States.INACTIVE:
		simon_state = States.ACTIVE
		mvmtTimer.start(6.0)
	elif prev_state == States.ACTIVE:
		simon_state = new_state
		drone.play()
		primedTimer.start(6.0 + randf_range(0.0, 14.0))
	elif prev_state == States.PRIMED:
		if new_state == States.ACTIVE:
			simon_state = new_state
			environment.play("droneFadeOut")
		else:
			simon_state = States.SCARE
			mvmtTimer.stop()
			primedTimer.stop()
			drone.stop()
			hideMButtons()
			if player_pos == 1 or player_pos == 0:
				if randf() >= 0:
					mvmtTimer.stop()
					memory_game.special_scare()
					dead = true
				else:
					player_death()

func _on_left_pressed():
	if simon_state == States.PRIMED:
		mvmt_scare()
	else:
		player_pos = (player_pos + 3) % 4
		move_player()

func _on_right_pressed():
	if simon_state == States.PRIMED:
		mvmt_scare()
	else:
		player_pos = (player_pos + 1) % 4
		move_player()

func mvmt_scare():
	hideMButtons()
	mvmtTimer.stop()
	eyelidsAnim.play("eye_close")
	state_transition(simon_state, States.SCARE)
	await get_tree().create_timer(0.6).timeout
	$Eyelids.hide()
	player_death()

func move_player():
	hideMButtons()
	mvmtTimer.stop()
	eyelidsAnim.play("eye_close")
	await get_tree().create_timer(0.5).timeout
	playerSounds.play(names[prev_pos] + "_to_" + names[player_pos])
	prev_pos = player_pos
	update_position()

func update_position():
	movement_buttons.get_child(0).text = names[(player_pos+3)%4]
	movement_buttons.get_child(1).text = names[(player_pos+1)%4]
	memory_game.position = corners[player_pos].position
	memory_game.rotation = corners[player_pos].rotation
	cameras[player_pos].current = true

func monster_move():
	#Monster movement will depend on where Simon is positionally
	# Distance from player: 2
	if ((monster_pos + 2) % 4) == player_pos:
		if randf() > 0.5:
			monster_pos = (monster_pos+1)%4
		else:
			monster_pos = (monster_pos+3)%4
		#simon.position = corners[monster_pos].position
		simon.anim_update(player_pos, monster_pos)
	
	# Distance from player: 1
	elif ((monster_pos + 1) % 4) == player_pos or ((monster_pos + 3) % 4) == player_pos:
		monster_pos = player_pos
		#simon.position = corners[monster_pos].position
		simon.anim_update(player_pos, monster_pos)
		at_player_position()
	
	# Distance from player: 0
	else:
		state_transition(simon_state, States.SCARE)
		player_death()

func at_player_position():
	# Distance from player: 0
	# In this case, the player has to play the game correctly without messing up until
	# Simon goes away
	state_transition(simon_state, States.PRIMED)

func _on_environment_animation_finished(anim_name):
	if anim_name == "droneFadeOut":
		drone.stop()
		drone.volume_db = -5

func player_death():
	memory_game.paused = true
	mvmtTimer.stop()
	jumpscare.emit()
	dead = true

func _on_player_sounds_animation_finished(_anim_name):
	eyelidsAnim.play_backwards("eye_close")
	await eyelidsAnim.animation_finished
	showMButtons()
	mvmtTimer.start()

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
	monster_pos = (player_pos+2)%4
	simon.anim_update(player_pos, monster_pos)
	state_transition(simon_state, States.ACTIVE)
	mvmtTimer.start()
	showingButtons = true

func _on_news_caster_timeout():
	showingButtons = false
	hideMButtons()

func _on_memory_game_fail():
	if simon_state == States.PRIMED:
		state_transition(simon_state, States.SCARE)
	elif simon_state == States.ACTIVE:
		if randf() > 0.2:
			monster_move()

func _on_movement_timer_timeout():
	if simon_state == States.ACTIVE:
		monster_move()
		mvmtTimer.start(6.0)
	elif simon_state == States.PRIMED:
		state_transition(simon_state, States.SCARE)
	

func _on_memory_game_emit_light():
	if !dead:
		isLit = true
		mvmtTimer.start(6.0)
		await get_tree().create_timer(1.0).timeout
		isLit = false
	else:
		simon.crawling_scare(player_pos)

func hideMButtons():
	movement_buttons.hide()

func showMButtons():
	if showingButtons:
		movement_buttons.show()

func _on_primed_timer_timeout():
	state_transition(simon_state, States.ACTIVE)
	monster_pos = (monster_pos + randi_range(1,3)) % 4
	simon.anim_update(player_pos, monster_pos)

extends Node3D

signal playerFail
@onready var audioCues = $Armature/AudioCues
@onready var anim_player = $AnimationPlayer
@onready var names = ["Corner", "Bookshelf", "Bed", "Closet"]
@onready var scareCam : Camera3D = $Camera3D
@onready var jsSound : AudioStreamPlayer = $Jumpscare
@onready var scareLight : SpotLight3D = $SpotLight3D

@onready var mLocations : Node3D = get_parent().get_node("MonsterLocations")
@onready var bc_primer : Node3D = mLocations.get_node("BackCorner_primer")
@onready var bc_special : Node3D = mLocations.get_node("BackCorner_specialScare")
@onready var bc_left : Node3D = mLocations.get_node("BackCorner_left")
@onready var bc_right : Node3D = mLocations.get_node("BackCorner_right")
@onready var bc_opp : Node3D = mLocations.get_node("BackCorner_opp")
@onready var bs_primer : Node3D = mLocations.get_node("Bookshelf_primer")
@onready var bs_special : Node3D = mLocations.get_node("Bookshelf_specialScare")
@onready var bs_left : Node3D = mLocations.get_node("Bookshelf_left")
@onready var bs_right : Node3D = mLocations.get_node("Bookshelf_right")
@onready var bs_opp : Node3D = mLocations.get_node("Bookshelf_opp")
@onready var bed_primer : Node3D = mLocations.get_node("Bed_primer")
@onready var bed_special : Node3D = mLocations.get_node("Bed_specialScare")
@onready var bed_left : Node3D = mLocations.get_node("Bed_left")
@onready var bed_right : Node3D = mLocations.get_node("Bed_right")
@onready var bed_opp : Node3D = mLocations.get_node("Bed_opp")
@onready var c_primer : Node3D = mLocations.get_node("Closet_primer")
@onready var c_right : Node3D = mLocations.get_node("Closet_right")
@onready var c_special : Node3D = mLocations.get_node("Closet_specialScare")

func _ready():
	pass

func _process(_delta):
	pass

func anim_update(p_pos, s_pos):
	if p_pos == 0: #BackCorner
		if s_pos == 3: #left
			self.position = bc_left.position
			self.rotation = bc_left.global_rotation
			anim_player.play("standing")
		elif s_pos == 1: #right
			self.position = bc_right.position
			self.rotation = bc_right.global_rotation
			anim_player.play("standing")
		elif s_pos == p_pos: #primer
			self.position = bc_primer.position
			self.rotation = bc_primer.global_rotation
			anim_player.play("backcorner_crouching")
		else: #opp
			self.position = bc_opp.position
			self.rotation = bc_opp.global_rotation
			anim_player.play("standing")
	elif p_pos == 1: #Bookshelf
		if s_pos == 0: #left
			self.position = bs_left.position
			self.rotation = bs_left.global_rotation
			anim_player.play("standing")
		elif s_pos == 2: #right
			self.position = bs_right.position
			self.rotation = bs_right.global_rotation
			anim_player.play("standing")
		elif s_pos == p_pos: #primer
			self.position = bs_primer.position
			self.rotation = bs_primer.global_rotation
			anim_player.play("backcorner_crouching")
		else: #opp
			self.position = bs_opp.position
			self.rotation = bs_opp.global_rotation
			anim_player.play("standing")
	elif p_pos == 2: #Bed
		if s_pos == 1: #left
			self.position = bed_left.position
			self.rotation = bed_left.global_rotation
			anim_player.play("standing")
		elif s_pos == 3: #right
			self.position = bed_right.position
			self.rotation = bed_right.global_rotation
			anim_player.play("standing")
		elif s_pos == p_pos: #primer
			self.position = bed_primer.position
			self.rotation = bed_primer.global_rotation
			get_parent().bedCue.play()
			anim_player.play("bed_onBed")
		else:
			self.position = bed_opp.position
			self.rotation = bed_opp.global_rotation
			anim_player.play("standing")
	else: #Closet
		if s_pos == 2: #left
			pass
		elif s_pos == 0: #right
			self.position = c_right.position
			self.rotation = c_right.global_rotation
			anim_player.play("standing")
		elif s_pos == p_pos: #primer
			self.position = c_primer.position
			self.rotation = c_primer.global_rotation
			anim_player.play("closet_hand_begin")
			await anim_player.animation_finished
			anim_player.play("closet_hand_anim")
		else: #opp
			pass

func _on_world_jumpscare():
	jumpscare()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Jumpscare":
		get_tree().change_scene_to_file("res://scenes/end_screen.tscn")
	elif anim_name == "crawling" or anim_name == "closet_specialScare" or anim_name == "bed_specialScare":
		jumpscare()

func jumpscare():
	playerFail.emit()
	scareCam.current = true
	scareLight.show()
	jsSound.play()
	anim_player.play("Jumpscare")
	Score.checkScore(get_parent().timeSurvived)

func special_scare(pos : int):
	if pos == 0:
		self.position = bc_special.position
		self.rotation = bc_special.rotation
		anim_player.play("crawling")
	elif pos == 1:
		self.position = bs_special.position
		self.rotation = bs_special.rotation
		anim_player.play("crawling")
	elif pos == 2:
		self.position = bed_special.position
		self.rotation = bed_special.rotation
		anim_player.play("bed_specialScare")
	else:
		self.position = c_special.position
		self.rotation = c_special.rotation
		anim_player.play("closet_specialScare")

extends Node3D

@onready var blades : MeshInstance3D = $Blades
var SPEED = 250.0

func _physics_process(delta):
	blades.rotate_y(deg_to_rad(1) * delta * SPEED)

func stop_fans():
	self.set_physics_process(false)

extends MeshInstance3D

signal redPressed
var moused : bool = false

func _process(_delta):
	if moused and Input.is_action_just_pressed("Click"):
		redPressed.emit()

func _on_area_3d_mouse_entered():
	moused = true
	if !get_parent().displaying:
		self.get_surface_override_material(0).emission_energy_multiplier = 1

func _on_area_3d_mouse_exited():
	moused = false
	if !get_parent().displaying:
		self.get_surface_override_material(0).emission_energy_multiplier = 0

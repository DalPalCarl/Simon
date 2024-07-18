extends CanvasLayer

@onready var lButton : Button = $Left
@onready var rButton : Button = $Right

func _on_hide_m_buttons():
	self.visible = false

func _on_show_m_buttons():
	self.visible = true

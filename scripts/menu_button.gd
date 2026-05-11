extends Button

func _ready() -> void:
	# Connect the built-in click signals
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

func _on_button_down() -> void:
	# Tints the Button AND its child Label to a medium grey
	# Color(Red, Green, Blue) values go from 0.0 to 1.0
	modulate = Color(0.6, 0.6, 0.6) 

func _on_button_up() -> void:
	# Returns the Button and Label to their normal colors
	modulate = Color(1.0, 1.0, 1.0)

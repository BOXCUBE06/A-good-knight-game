extends Control

@onready var play_button: Button = %PlayButton
@onready var exit_button: Button = %ExitButton

# 1. Change this path to point to your new Intro scene
const INTRO_SCENE = "res://scenes/intro_sequence.tscn" 

func _ready() -> void:
	# Connect the buttons
	play_button.pressed.connect(_on_play_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func _on_play_pressed() -> void:
	# 2. Trigger the transition to the Intro sequence
	SceneTransition.change_scene(INTRO_SCENE)

func _on_exit_pressed() -> void:
	# 3. Terminate the game
	get_tree().quit()

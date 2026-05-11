extends Control

const DIALOGUE = preload("res://Dialogues/intro.dialogue")
const CUSTOM_BALLOON = preload("res://Dialogues/balloon.tscn")
const START_LEVEL = "res://scenes/starting_area.tscn"

func _ready() -> void:
	# Spawn the dialogue box over the black screen
	var balloon = CUSTOM_BALLOON.instantiate()
	add_child(balloon)
	balloon.start(DIALOGUE, "start")
	
	# Wait until the player finishes the dialogue
	await DialogueManager.dialogue_ended
	
	# Trigger the standard fade-to-black transition
	SceneTransition.change_scene(START_LEVEL)

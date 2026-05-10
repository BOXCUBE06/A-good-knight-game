extends Node2D


# Called when the node enters the scene tree for the first time.
const DIALOGUE = preload("res://Dialogues//test.dialogue")
# Replace with the actual path to the balloon scene you just edited
const CUSTOM_BALLOON = preload("res://Dialogues//balloon.tscn") 

func _ready() -> void:
	var balloon = CUSTOM_BALLOON.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(DIALOGUE, "start")

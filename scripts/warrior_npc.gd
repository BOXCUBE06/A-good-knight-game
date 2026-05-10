extends Node2D

const DIALOGUE = preload("res://Dialogues/quest.dialogue")
const CUSTOM_BALLOON = preload("res://Dialogues//balloon.tscn")

var player_near: bool = false
var player_node: Node2D = null
var has_talked: bool = false # Add this state tracker

func _ready() -> void:
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Knight": 
		player_near = true
		player_node = body

func _on_body_exited(body: Node2D) -> void:
	if body == player_node:
		player_near = false
		player_node = null

func _unhandled_input(event: InputEvent) -> void:
	if player_near and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		
		if get_tree().current_scene.has_node("Balloon"):
			return
			
		if player_node:
			player_node.is_interacting = true
			
		var balloon = CUSTOM_BALLOON.instantiate()
		get_tree().current_scene.add_child(balloon)
		
		# Check which dialogue to run
		if not has_talked:
			balloon.start(DIALOGUE, "start")
			has_talked = true # Set to true so next time it runs second_talk
		else:
			balloon.start(DIALOGUE, "second_talk")

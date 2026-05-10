extends Node2D

const DIALOGUE = preload("res://Dialogues/weapon_npc.dialogue")
const CUSTOM_BALLOON = preload("res://Dialogues//balloon.tscn")

var player_near: bool = false
var player_node: Node2D = null # We will store the player here!

func _ready() -> void:
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	# Works with either the exact name or your player layer/group
	if body.name == "Knight": 
		player_near = true
		player_node = body # Save the exact player node

func _on_body_exited(body: Node2D) -> void:
	if body == player_node:
		player_near = false
		player_node = null # Clear it when they walk away

func _unhandled_input(event: InputEvent) -> void:
	if player_near and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		
		if get_tree().current_scene.has_node("Balloon"):
			return
			
		# ---- NEW: Freeze the player! ----
		if player_node:
			player_node.is_interacting = true
			
		var balloon = CUSTOM_BALLOON.instantiate()
		get_tree().current_scene.add_child(balloon)
		balloon.start(DIALOGUE, "start")

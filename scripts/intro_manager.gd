extends Node

const DIALOGUE = preload("res://Dialogues/boss_intro.dialogue")
const CUSTOM_BALLOON = preload("res://Dialogues/balloon.tscn")

@onready var black_screen: ColorRect = %BlackScreen
@onready var anim_player: AnimationPlayer = %AnimationPlayer
@onready var knight: CharacterBody2D = %Knight
# @onready var boss = %Minotaur # If you make your boss a unique name too

func _ready() -> void:
	play_intro_sequence()

func play_intro_sequence() -> void:
	# 1. Freeze the Knight and keep screen black
	knight.is_interacting = true
	black_screen.modulate.a = 1.0 
	
	# 2. Play narration
	await play_dialogue("narration")
	
	# 3. Fade out black screen to reveal the boss area
	anim_player.play("fade_in")
	await anim_player.animation_finished
	
	# 4. Play the conversation
	knight.is_interacting = true
	await play_dialogue("conversation")
	
	# 5. Start Battle
	start_battle()

func play_dialogue(title: String) -> void:
	var balloon = CUSTOM_BALLOON.instantiate()
	add_child(balloon)
	balloon.start(DIALOGUE, title)
	
	await balloon.tree_exited

func start_battle() -> void:
	print("Battle Start!")
	# Trigger boss AI here

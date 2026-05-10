extends Node2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var minotaur_sound: AudioStreamPlayer = $GoatScream

const DIALOGUE = preload("res://Dialogues/cutscene.dialogue")
const CUSTOM_BALLOON = preload("res://Dialogues/balloon.tscn")

func _ready() -> void:
	# Start the sequence
	play_cutscene()

func play_cutscene() -> void:
	# 1. Knight falls down the slope
	anim_player.play("knight_fall")
	await anim_player.animation_finished
	
	# 2. Kneeling man begs for help
	await play_dialogue("man_help")
	
	# 3. Play sound effect and wait 1 second for dramatic effect
	minotaur_sound.play()
	await get_tree().create_timer(1.0).timeout 
	
	# 4. Kneeling man panics
	await play_dialogue("man_panic")
	
	# 5. Minotaur jumps and crushes him
	anim_player.play("minotaur_crush")
	await anim_player.animation_finished
	
	# 6. Minotaur roars text
	await play_dialogue("minotaur_roar")
	
	# 7. Minotaur runs away
	anim_player.play("minotaur_run")
	await anim_player.animation_finished
	
	# 8. Knight reacts
	await play_dialogue("knight_react")
	
	# 9. Knight chases
	anim_player.play("knight_chase")
	await anim_player.animation_finished
	
	


# Helper function to spawn dialogue and pause the script until it closes
func play_dialogue(title: String) -> void:
	var balloon = CUSTOM_BALLOON.instantiate()
	add_child(balloon)
	balloon.start(DIALOGUE, title)
	
	# Wait until the balloon node is destroyed (player finished reading)
	await balloon.tree_exited

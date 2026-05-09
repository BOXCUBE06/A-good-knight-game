extends Node

@export var grass_sounds: Array[AudioStream]
@export var wood_sounds: Array[AudioStream]

@onready var footstep_audio = $FootstepAudio
@onready var floor_checker = $FloorChecker

var current_terrain: String = "grass" 
var grass_index: int = 0
var wood_index: int = 0

func play_footstep() -> void:
	update_terrain()
	
	var sound_to_play: AudioStream = null
	
	if current_terrain == "wood" and wood_sounds.size() > 0:
		sound_to_play = wood_sounds[wood_index]
		wood_index = (wood_index + 1) % wood_sounds.size()
	elif current_terrain == "grass" and grass_sounds.size() > 0:
		sound_to_play = grass_sounds[grass_index]
		grass_index = (grass_index + 1) % grass_sounds.size()
		
	if sound_to_play:
		footstep_audio.stream = sound_to_play
		footstep_audio.pitch_scale = randf_range(0.9, 1.1) 
		footstep_audio.play()

func update_terrain() -> void:
	if floor_checker.is_colliding():
		var collider = floor_checker.get_collider()
		
		# THIS WILL PRINT THE NAME OF THE FLOOR TO YOUR OUTPUT CONSOLE
		print("RayCast is touching: ", collider.name) 
		
		if collider.is_in_group("Wood"):
			current_terrain = "wood"
		else:
			current_terrain = "grass" 
	else:
		print("RayCast is touching NOTHING")
		current_terrain = "grass"

extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func change_scene(target_path: String) -> void:
	# 1. Fade to black
	animation_player.play("fade")
	await animation_player.animation_finished
	
	# 2. Change the scene while the screen is black
	get_tree().change_scene_to_file(target_path)
	
	# 3. Fade back to normal
	animation_player.play_backwards("fade")

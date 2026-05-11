extends Area2D

const CUTSCENE_PATH = "res://scenes/cut_scene.tscn"

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Knight":
		# call_deferred safely waits for the physics step to end before executing
		get_tree().call_deferred("change_scene_to_file", CUTSCENE_PATH)

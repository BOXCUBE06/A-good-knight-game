extends Area2D

# Ensure this path matches the exact location of your next level
const NEXT_LEVEL = "res://scenes/1_st_level.tscn"

func _on_body_entered(body: Node2D) -> void:
	# Check if the object entering the area is the Player
	if body.name == "Knight":
		# Disable the collision so the player can't trigger it twice
		$CollisionShape2D.set_deferred("disabled", true)
		
		# Call the global transition script
		SceneTransition.change_scene(NEXT_LEVEL)

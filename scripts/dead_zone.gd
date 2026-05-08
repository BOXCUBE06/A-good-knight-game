extends Area2D

@export var respawn_point: Marker2D
@export var damage_amount: int = 30

func _on_body_entered(body: Node2D) -> void:
	# Verify it is the player
	if body.name == "Knight" or body.is_in_group("Player"):
		
		# Apply Damage
		if body.has_method("take_damage"):
			body.take_damage(damage_amount, body.global_position.x)
			
		# Teleport to Spawn
		if respawn_point:
			body.global_position = respawn_point.global_position
		else:
			print("!!! ERROR: Respawn point not assigned in Deadzone inspector !!!")

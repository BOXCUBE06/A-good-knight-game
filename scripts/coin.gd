extends Area2D

# Prevents the player from triggering the animation twice while it's playing
var is_collected: bool = false 

func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return
		
	is_collected = true
	
	# 1. Turn off collision immediately so it can't be grabbed again
	$CollisionShape2D.set_deferred("disabled", true)
	
	GameState.coins += 1
	
	# 2. Create the Tween
	var tween = create_tween()
	
	# Step A: Pop UP (Moves Y up by 30 pixels over 0.2 seconds)
	# EASE_OUT makes it slow down at the peak of the jump
	tween.tween_property(self, "position:y", position.y - 30, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	# Step B: Fall DOWN (Moves Y down by 10 pixels over 0.2 seconds)
	# EASE_IN makes it speed up as it falls
	tween.tween_property(self, "position:y", position.y + 10, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	
	# Step C: Fade OUT (Changes transparency to 0 over 0.2 seconds)
	# parallel() means this happens AT THE SAME TIME as Step B
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.2)
	
	# Step D: Delete the coin from the game entirely once the animation is done
	tween.tween_callback(queue_free)

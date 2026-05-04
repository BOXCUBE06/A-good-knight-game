extends CharacterBody2D

# --- Variables ---
var health: int = 20
var is_dead: bool = false
var is_hurt: bool = false

# --- Nodes ---
@onready var sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Stop processing movement logic if dead
	if is_dead:
		return
		
	# Apply gravity so the goblin doesn't float
	if not is_on_floor():
		velocity += get_gravity() * delta

	# If the goblin is currently playing the hurt animation, stop it from moving
	if is_hurt:
		velocity.x = move_toward(velocity.x, 0, 200 * delta)
		move_and_slide()
		return

	# Default state (you can add your run/chase logic here later)
	sprite.play("idle")
	move_and_slide()

# --- Damage Logic ---
func take_damage(amount: int, attacker_x: float) -> void:
	if is_dead:
		return
		
	health -= amount
	
	if health <= 0:
		die()
	else:
		trigger_hurt()

func trigger_hurt() -> void:
	is_hurt = true
	sprite.play("hurt")
	
	# Wait for the hurt animation to completely finish
	await sprite.animation_finished
	
	# Return to normal state only if it didn't die while hurt
	if not is_dead:
		is_hurt = false

func die() -> void:
	is_dead = true
	velocity.x = 0 # Stop all horizontal movement
	
	sprite.play("death")
	
	# Safely turn off the hitboxes so the player's sword doesn't keep hitting the corpse
	if has_node("hurtbox/CollisionShape2D"):
		$hurtbox/CollisionShape2D.set_deferred("disabled", true)
	if has_node("hitbox/CollisionShape2D"):
		$hitbox/CollisionShape2D.set_deferred("disabled", true)
	if has_node("AttackArea/CollisionShape2D"):
		$AttackArea/CollisionShape2D.set_deferred("disabled", true)
		
	# Wait for the death animation to finish, then delete the goblin from the game
	await sprite.animation_finished
	queue_free()


func _on_hurt_box_area_entered(area: Area2D) -> void:
	print("Goblin bumped into: ", area.name)
	var target = area.get_parent()
	if target.has_method("take_damage"):
		# Deals 5 contact damage and passes X position for knockback
		target.take_damage(5, global_position.x)

extends CharacterBody2D

# --- Constants ---
const SPEED = 40.0
const ATTACK_RANGE = 40.0 # How close the player must be to trigger the attack animation

# --- Variables ---
var health: int = 20
var is_dead: bool = false
var is_hurt: bool = false
var is_attacking: bool = false
var direction: int = 1 # 1 for Right, -1 for Left

# --- Nodes ---
@onready var sprite = $AnimatedSprite2D
@onready var wall_check = $WallCheck
@onready var ledge_check = $LedgeCheck
@onready var detection_area = $DetectionArea # The big circle Area2D
@onready var attack_shape = $AttackArea/CollisionShape2D
@onready var attack_area = $AttackArea

func _ready() -> void:
	# Ensure the attack hitbox is off at the start
	attack_shape.disabled = true

func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	if not is_on_floor():
		velocity += get_gravity() * delta

	# --- FIXED: STOP ALL MOVEMENT DURING ATTACK ---
	if is_hurt or is_attacking:
		velocity.x = 0  
		move_and_slide()
		return

	# --- 1. DETECTION LOGIC ---
	var target = get_player_in_range()
	
	if target:
		var dist_to_player = global_position.distance_to(target.global_position)
		
		# If within range, stop and attack
		if dist_to_player <= ATTACK_RANGE:
			trigger_attack()
		else:
			# If player is seen but far away, chase them
			var dir_to_player = sign(target.global_position.x - global_position.x)
			if dir_to_player != 0: # Prevents direction from becoming 0 if they overlap perfectly
				direction = dir_to_player
			
			velocity.x = direction * SPEED
			sprite.play("run")
	else:
		# --- 2. PATROL LOGIC ---
		if is_on_wall() or not ledge_check.is_colliding():
			direction *= -1
			# Removed the raycast flipping from here. It is now handled globally below.
		
		velocity.x = direction * SPEED
		sprite.play("run")

	# --- 3. GLOBAL FLIPPING LOGIC ---
	sprite.flip_h = (direction == -1)
	
	# Flip the attack shape
	attack_shape.position.x = abs(attack_shape.position.x) * direction
	
	# FIX: Flip BOTH the starting position AND the target direction of the wall check
	wall_check.position.x = abs(wall_check.position.x) * direction
	wall_check.target_position.x = abs(wall_check.target_position.x) * direction
	
	# Flip the starting position of the ledge check (assuming it points straight down)
	ledge_check.position.x = abs(ledge_check.position.x) * direction

	move_and_slide()

# --- AI Helper Functions ---

func get_player_in_range():
	# Looks through all overlapping areas in the big DetectionArea
	for area in detection_area.get_overlapping_areas():
		if area.name == "HurtBox": # Make sure this matches your Knight's node name
			return area.get_parent()
	return null

func trigger_attack() -> void:
	is_attacking = true
	sprite.play("attack") # Make sure your AnimationPlayer/AnimatedSprite has this
	
	# Wait for the frame where the sword hits (optional: use AnimationPlayer signals instead)
	await get_tree().create_timer(0.3).timeout 
	if not is_dead and not is_hurt:
		attack_shape.disabled = false
		await get_tree().create_timer(0.1).timeout
		attack_shape.disabled = true
		
	await sprite.animation_finished
	is_attacking = false

# --- Damage Logic (Keep your existing functions) ---
func take_damage(amount: int, attacker_x: float) -> void:
	if is_dead: return
	health -= amount
	if health <= 0: die()
	else: trigger_hurt()

func trigger_hurt() -> void:
	is_hurt = true
	is_attacking = false 
	
	# Change this line:
	attack_shape.set_deferred("disabled", true) #
	
	sprite.play("hurt")
	await sprite.animation_finished
	if not is_dead:
		is_hurt = false

func die() -> void:
	is_dead = true
	velocity.x = 0
	sprite.play("death")
	
	# Update these lines as well to be safe:
	$HurtBox/CollisionShape2D.set_deferred("disabled", true) #[cite: 1]
	$AttackArea/CollisionShape2D.set_deferred("disabled", true) #[cite: 1]
	
	await sprite.animation_finished
	queue_free()

func _on_hurt_box_area_entered(area: Area2D) -> void:
	# This handles the "Bump" damage if they just touch
	if area.name == "HurtBox" and not is_dead:
		var target = area.get_parent()
		if target.has_method("take_damage"):
			target.take_damage(5, global_position.x)


func _on_attack_area_area_entered(area: Area2D) -> void:
	# Check if the thing we hit is the Knight's HurtBox
	if area.name == "HurtBox": 
		var knight = area.get_parent()
		if knight.has_method("take_damage"):
			# Deal damage and pass global_position for knockback
			knight.take_damage(10, global_position.x)

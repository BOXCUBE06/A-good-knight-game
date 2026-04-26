extends CharacterBody2D

# Constants
const SPEED = 200.0        # Reduced from 300
const ROLL_SPEED = 250.0   # Adjusted for shorter duration
const JUMP_VELOCITY = -350.0

# State variables
var is_rolling = false
var is_turning = false

@onready var sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle Input Actions
	if is_on_floor() and not is_rolling and not is_turning:
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
		elif Input.is_action_just_pressed("roll"):
			start_roll()

	# Handle Horizontal Movement
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if is_rolling:
		# Lock velocity based on the direction we were facing when we started
		var roll_dir = -1.0 if sprite.flip_h else 1.0
		velocity.x = roll_dir * ROLL_SPEED
	elif is_turning:
		# Slow down slightly while turning
		velocity.x = move_toward(velocity.x, 0, SPEED * 0.5)
	elif direction != 0:
		# Determine if the player is pressing the opposite direction
		var is_changing_direction = (direction > 0 and sprite.flip_h) or (direction < 0 and not sprite.flip_h)
		
		# ONLY trigger the turn pause if the player is on the ground
		if is_changing_direction and is_on_floor():
			trigger_turn(direction)
		else:
			# If in the air (or just moving forward), instantly flip and apply speed
			velocity.x = direction * SPEED
			sprite.flip_h = (direction < 0)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	update_animations(direction)

func start_roll():
	is_rolling = true
	# Play roll at 1.5x speed to make it shorter/snappier
	sprite.play("roll", 1.5) 
	await sprite.animation_finished 
	is_rolling = false

func trigger_turn(new_direction):
	is_turning = true
	# Play the turn animation at 2.0x speed to halve the pause duration
	sprite.play("turn", 2.0)
	await sprite.animation_finished
	
	# NOW we flip it and finish the turn logic
	sprite.flip_h = (new_direction < 0)
	is_turning = false

func update_animations(direction):
	# Don't interrupt special states
	if is_rolling or is_turning:
		return

	if not is_on_floor():
		# This standard if/else fixes the 'void' return error
		if velocity.y < 0:
			sprite.play("jump")
		else:
			sprite.play("fall")
	elif direction != 0:
		sprite.play("run")
	else:
		sprite.play("idle")

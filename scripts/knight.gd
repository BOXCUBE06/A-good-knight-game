extends CharacterBody2D

# Constants
const SPEED = 200.0
const ROLL_SPEED = 220.0
const JUMP_VELOCITY = -350.0

# Collision Constants
const COL_X_RIGHT = 0.0
const COL_X_LEFT = 10.0

# State variables
var is_rolling = false
var is_turning = false
var is_attacking = false 
var combo_step = 0       
var last_pressed_dir = 1.0

@onready var sprite = $AnimatedSprite2D
@onready var collision = $Hitbox
@onready var anim = $AnimationPlayer 
@onready var attack_area = $AttackArea # Flips the attack hitbox

func _input(event):
	if event.is_action_pressed("attack"):
		if not is_attacking:
			is_attacking = true
			combo_step = 1
			anim.play("attack")
		elif combo_step == 1:
			combo_step = 2

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Allow jumping and rolling only if not attacking, turning, or rolling
	if is_on_floor() and not is_rolling and not is_turning and not is_attacking:
		if Input.is_action_pressed("jump"):
			velocity.y = JUMP_VELOCITY
		elif Input.is_action_just_pressed("roll"):
			start_roll()

	if Input.is_action_just_pressed("right"):
		last_pressed_dir = 1.0
	elif Input.is_action_just_pressed("left"):
		last_pressed_dir = -1.0

	var direction := 0.0
	var left_held := Input.is_action_pressed("left")
	var right_held := Input.is_action_pressed("right")

	if left_held and right_held:
		direction = last_pressed_dir
	elif right_held:
		direction = 1.0
		last_pressed_dir = 1.0
	elif left_held:
		direction = -1.0
		last_pressed_dir = -1.0

	if is_rolling:
		var roll_dir = -1.0 if sprite.flip_h else 1.0
		velocity.x = roll_dir * ROLL_SPEED
	elif is_turning:
		velocity.x = move_toward(velocity.x, 0, SPEED * 0.5)
	elif is_attacking and is_on_floor():
		# Stop moving ONLY if attacking on the ground
		velocity.x = move_toward(velocity.x, 0, SPEED)
	elif direction != 0:
		var is_changing_direction = (direction > 0 and sprite.flip_h) or (direction < 0 and not sprite.flip_h)
		
		# Only trigger turn animation if on the floor and not attacking
		if is_changing_direction and is_on_floor() and not is_attacking:
			trigger_turn(direction)
		else:
			velocity.x = direction * SPEED
			# Prevent the player from flipping backwards mid swing
			if not is_attacking:
				set_facing(direction < 0) 
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	update_animations(direction)

func start_roll():
	is_rolling = true
	sprite.play("roll", 1.5) 
	await sprite.animation_finished 
	is_rolling = false

func trigger_turn(new_direction):
	is_turning = true
	sprite.play("turn", 2.0)
	await sprite.animation_finished
	
	set_facing(new_direction < 0)
	is_turning = false

func set_facing(is_facing_left: bool):
	sprite.flip_h = is_facing_left
	if is_facing_left:
		# Body Hitbox
		collision.position.x = COL_X_LEFT
		
		# Attack Area Flip & Move
		attack_area.scale.x = -1
		attack_area.position.x = 10.5  # <--- CHANGE THIS NUMBER to pull it closer!
	else:
		# Body Hitbox
		collision.position.x = COL_X_RIGHT
		
		# Attack Area Flip & Move
		attack_area.scale.x = 1
		attack_area.position.x = 0.0    # <--- Normal position when facing right

func update_animations(direction):
	if is_rolling or is_turning or is_attacking:
		return

	if not is_on_floor():
		if velocity.y < 0:
			sprite.play("jump")
		else:
			sprite.play("fall")
	elif direction != 0:
		sprite.play("run")
	else:
		sprite.play("idle")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		if combo_step == 2:
			anim.play("attack2")
		else:
			is_attacking = false
			combo_step = 0
	elif anim_name == "attack2":
		is_attacking = false
		combo_step = 0


func _on_attack_area_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	if enemy.has_method("take_damage"):
		enemy.take_damage(10)

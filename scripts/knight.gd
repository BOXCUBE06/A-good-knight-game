extends CharacterBody2D

# Constants
const SPEED = 200.0
const ROLL_SPEED = 220.0
const JUMP_VELOCITY = -350.0

# Collision Constants
const COL_X_RIGHT = 0.0
const COL_X_LEFT = 10.0

# State variables
var is_dead = false
var is_hurt = false
var is_rolling = false
var is_turning = false
var is_attacking = false
var is_knocked_back: bool = false
var combo_step = 0       
var last_pressed_dir = 1.0

@onready var sprite = $AnimatedSprite2D
@onready var collision = $Hitbox
@onready var anim = $AnimationPlayer 
@onready var attack_area = $AttackArea 
@onready var health_component = $HealthComponentKnight
@onready var hurtbox = $HurtBox

func _ready() -> void:
	# Connect the component signals to the knight's physical reaction functions
	health_component.took_damage.connect(_on_health_component_took_damage)
	health_component.died.connect(_on_health_component_knight_died)

func _input(event):
	# Stop all player inputs immediately if dead, hurt, or knocked back
	if is_dead or is_hurt or is_knocked_back:
		return
		
	if event.is_action_pressed("attack"):
		if not is_attacking:
			is_attacking = true
			combo_step = 1
			anim.play("attack")
		elif combo_step == 1:
			combo_step = 2

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# Always apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# --- NEW: CONTROL LOCK DURING KNOCKBACK ---
	if is_knocked_back:
		# Apply heavy air/ground friction so the knight slides to a halt
		velocity.x = move_toward(velocity.x, 0, 400 * delta)
		move_and_slide()
		
		# Give control back ONLY when the animation is done AND the knight hits the ground
		if not is_hurt and is_on_floor():
			is_knocked_back = false
			
		return # Stop everything below (player inputs) from executing

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
		velocity.x = move_toward(velocity.x, 0, SPEED)
	elif direction != 0:
		var is_changing_direction = (direction > 0 and sprite.flip_h) or (direction < 0 and not sprite.flip_h)
		
		if is_changing_direction and is_on_floor() and not is_attacking:
			trigger_turn(direction)
		else:
			velocity.x = direction * SPEED
			if not is_attacking:
				set_facing(direction < 0) 
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	update_animations(direction)

# --- MOVEMENT & ANIMATION FUNCTIONS ---

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
		# Move the physical body
		collision.position.x = COL_X_LEFT
		
		# Move the hurtbox to match the body!
		hurtbox.position.x = COL_X_LEFT 
		
		# Attack Area 
		attack_area.scale.x = -1
		attack_area.position.x = 10.0  # Flipped left (Negative)
	else:
		# Move the physical body back
		collision.position.x = COL_X_RIGHT
		
		# Move the hurtbox back!
		hurtbox.position.x = COL_X_RIGHT
		
		# Attack Area 
		attack_area.scale.x = 1
		attack_area.position.x = 0.0 

func update_animations(direction):
	if is_rolling or is_turning or is_attacking or is_hurt or is_dead or is_knocked_back:
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

# --- COMBAT & DAMAGE FUNCTIONS ---

func _on_attack_area_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	if enemy.has_method("take_damage"):
		enemy.take_damage(10, global_position.x)

func take_damage(amount: int, attacker_x: float) -> void:
	if is_dead or is_hurt: 
		return
	# Bridge the incoming damage to the component
	health_component.apply_damage(amount, attacker_x)

func _on_health_component_took_damage(attacker_x: float) -> void:
	var push_direction = sign(global_position.x - attacker_x)
	if push_direction == 0:
		push_direction = 1.0 
		
	# Apply knockback force
	velocity.x = push_direction * 300.0  
	velocity.y = -200.0                  
	
	is_attacking = false
	combo_step = 0
	is_rolling = false
	is_turning = false
	
	# NEW: Activate our control lock flags
	is_hurt = true
	is_knocked_back = true
	
	sprite.play("hurt") 
	await sprite.animation_finished
	
	# Flinch animation is finished playing
	is_hurt = false
	
	# The is_knocked_back flag is handled above in _physics_process once the player lands!

func _on_health_component_knight_died() -> void:
	is_dead = true
	sprite.play("death")
	
	# Turn off collision safely
	if has_node("HurtBox/CollisionShape2D"):
		$HurtBox/CollisionShape2D.set_deferred("disabled", true)
	if has_node("AttackArea/CollisionShape2D"):
		$AttackArea/CollisionShape2D.set_deferred("disabled", true)

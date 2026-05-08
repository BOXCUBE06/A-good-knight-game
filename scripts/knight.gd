extends CharacterBody2D

# Constants
const SPEED = 150.0
const ROLL_SPEED = 180.0
const JUMP_VELOCITY = -350.0

# Collision Constants
const COL_X_RIGHT = 0.0
const COL_X_LEFT = 10.0

# State variables
var is_dead = false
var is_rolling = false
var is_turning = false
var is_attacking = false
var combo_step = 0        
var last_pressed_dir = 1.0

# --- NEW: I-Frame State ---
var is_invincible: bool = false

# Potion Inventory
var potions_in_inventory: int = 3 

signal potion_count_changed(new_count: int)

@onready var sprite = $AnimatedSprite2D
@onready var collision = $Hitbox
@onready var anim = $AnimationPlayer 
@onready var attack_area = $AttackArea 
@onready var health_component = $HealthComponentKnight
@onready var hurtbox = $HurtBox

func _ready() -> void:
	pass # We deleted the old signal connections!

func _input(event):
	# Stop player inputs immediately if dead
	if is_dead:
		return
		
	if event.is_action_pressed("attack"):
		if not is_attacking:
			is_attacking = true
			combo_step = 1
			anim.play("attack")
		elif combo_step == 1:
			combo_step = 2
			
	# Potion Input
	if event.is_action_pressed("heal"):
		use_potion()

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# Always apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Check for jump and roll inputs
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

	# Process movement states
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

# --- INVENTORY FUNCTIONS ---

func use_potion() -> void:
	# Check the GameState for potions
	if GameState.knight_potions > 0:
		
		# Assuming 100 is your Max HP
		if GameState.knight_health < 100: 
			
			GameState.knight_health += 30
			if GameState.knight_health > 100:
				GameState.knight_health = 100
				
			# Drop the global potion count (This instantly updates the HUD!)
			GameState.knight_potions -= 1
			print("Healed! Potions left: ", GameState.knight_potions)
			
		else:
			print("Cannot use potion: Health is already full!")
	else:
		print("Out of potions!")

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
		collision.position.x = COL_X_LEFT
		hurtbox.position.x = COL_X_LEFT 
		attack_area.scale.x = -1
		attack_area.position.x = 10.0 
	else:
		collision.position.x = COL_X_RIGHT
		hurtbox.position.x = COL_X_RIGHT
		attack_area.scale.x = 1
		attack_area.position.x = 0.0 

func update_animations(direction):
	if is_rolling or is_turning or is_attacking or is_dead:
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
	# Get the root of the enemy (Minotaur or Goblin)
	var enemy = area.owner 
	if enemy and enemy.has_method("take_damage"):
		enemy.take_damage(10, global_position.x)
		
func take_damage(amount: int, _attacker_x: float) -> void:
	# Add is_rolling to the ignore list
	if is_dead or is_invincible or is_rolling: 
		return
	
	# Update the Global GameState
	GameState.knight_health -= amount
	GameState.print_status()
	
	# Trigger the visual flicker
	trigger_iframes()
	
	# Check for Death
	if GameState.knight_health <= 0:
		is_dead = true
		sprite.play("death")
		
		# Turn off hitboxes so dead bodies don't deal/take damage
		if has_node("HurtBox/CollisionShape2D"):
			$HurtBox/CollisionShape2D.set_deferred("disabled", true)
		if has_node("AttackArea/CollisionShape2D"):
			$AttackArea/CollisionShape2D.set_deferred("disabled", true)

func _on_health_component_took_damage(_attacker_x: float) -> void:
	# Trigger the visual indicator and programmatic invulnerability
	trigger_iframes()

# --- I-FRAME LOGIC ---

func trigger_iframes() -> void:
	is_invincible = true
	
	# Loop 6 times to create a rapid flicker over 1.2 seconds
	for i in range(6):
		sprite.modulate.a = 0.2 # 20% opacity
		await get_tree().create_timer(0.1).timeout
		
		sprite.modulate.a = 1.0 # 100% opacity
		await get_tree().create_timer(0.1).timeout
		
	is_invincible = false

func _on_health_component_knight_died() -> void:
	is_dead = true
	sprite.play("death")
	
	if has_node("HurtBox/CollisionShape2D"):
		$HurtBox/CollisionShape2D.set_deferred("disabled", true)
	if has_node("AttackArea/CollisionShape2D"):
		$AttackArea/CollisionShape2D.set_deferred("disabled", true)


func _on_hurt_box_area_entered(area: Area2D) -> void:
	# Add is_rolling to the ignore list
	if is_dead or is_invincible or is_rolling:
		return
		
	# 1. If the thing hitting us is a weapon (AttackArea)
	if area.name == "AttackArea":
		take_damage(10, area.global_position.x) # Deals 10
		
	# 2. If it's just the enemy's body (HurtBox or HurtArea)
	else:
		take_damage(5, area.global_position.x) # Deals 5

func _on_animated_sprite_2d_frame_changed() -> void:
	if $AnimatedSprite2D.animation == "run":
		# Increase the distance between the two frames (e.g., 0 and 4, or 1 and 5)
		if $AnimatedSprite2D.frame == 0 or $AnimatedSprite2D.frame == 4:
			$FootstepManager.play_footstep()

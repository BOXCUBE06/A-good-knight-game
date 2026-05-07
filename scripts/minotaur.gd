extends CharacterBody2D

# --- BOSS STATS ---
@export var max_health: int = 250
var current_health: int
var next_phase_threshold: int = 200 # Boss triggers special attack at 200, 150, 100, 50

# --- MOVEMENT SETTINGS ---
@export var walk_speed: float = 120.0
@export var charge_speed: float = 350.0
@export var attack_range: float = 35.0

# --- ARENA LIMITS & TARGET ---
@export var stage_left_x: float = 472.0
@export var stage_right_x: float = 899.0
@export var player: Node2D

# --- STATE MACHINE ---
enum State { CHASE, NORMAL_ATTACK, REPOSITION, CHARGE_LEFT, CHARGE_RIGHT, STUNNED, DEAD }
var current_state = State.CHASE

var is_invincible: bool = false
var can_attack: bool = true

# --- NODE REFERENCES ---
@onready var sprite = $AnimatedSprite2D
@onready var anim_player = $AnimationPlayer
@onready var stun_effect = $Stun

func _ready() -> void:
	current_health = max_health
	stun_effect.visible = false # Hide the stun birds/stars initially
	
	# Fallback just in case you forget to assign the player in the Inspector
	if player == null:
		player = get_tree().get_first_node_in_group("Player")

func _physics_process(delta: float) -> void:
	if current_state == State.DEAD or player == null:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	# Check what "Job" the boss is currently doing
	match current_state:
		State.CHASE:
			chase_player()
			
		State.NORMAL_ATTACK:
			# Stand still while swinging
			velocity.x = move_toward(velocity.x, 0, walk_speed)
			
		State.REPOSITION:
			# Run to the right edge of the screen
			move_to_position(stage_right_x, walk_speed)
			if abs(global_position.x - stage_right_x) < 10.0:
				start_charge(State.CHARGE_LEFT)
				
		State.CHARGE_LEFT:
			move_to_position(stage_left_x, charge_speed)
			if abs(global_position.x - stage_left_x) < 10.0:
				start_charge(State.CHARGE_RIGHT)
				
		State.CHARGE_RIGHT:
			move_to_position(stage_right_x, charge_speed)
			if abs(global_position.x - stage_right_x) < 10.0:
				trigger_stun()
				
		State.STUNNED:
			# Slide to a halt and wait
			velocity.x = move_toward(velocity.x, 0, walk_speed * delta)

	move_and_slide()

# --- AI BEHAVIORS ---

func chase_player():
	var dist = player.global_position.x - global_position.x
	var direction = sign(dist)
	
	if abs(dist) < attack_range:
		if can_attack:
			flip_sprite(direction) 
			current_state = State.NORMAL_ATTACK
			anim_player.play("attack", -1, 0.5) 
	else:
		velocity.x = direction * walk_speed
		
		# Stop attack animation if it's playing
		if anim_player.is_playing() and anim_player.current_animation == "attack":
			anim_player.stop()
		
		# ONLY play the run animation if it isn't already playing
		if sprite.animation != "run":
			sprite.play("run")
			
		# Force the stun effect off while chasing
		stun_effect.visible = false
			
		flip_sprite(direction)
		
func move_to_position(target_x: float, current_speed: float):
	var dist = target_x - global_position.x
	var direction = sign(dist)
	velocity.x = direction * current_speed
	
	# Stop attack animation if it's currently overriding the sprite
	if anim_player.is_playing() and anim_player.current_animation == "attack":
		anim_player.stop() 
		
	# --- THE FIX ---
	# ONLY force the run animation if he is just repositioning.
	# If he is charging, do nothing so the AnimationPlayer can handle it!
	if current_state == State.REPOSITION:
		if sprite.animation != "run":
			sprite.play("run") 
		
	# Force the stun effect off while moving
	stun_effect.visible = false
		
	flip_sprite(direction)
	
func flip_sprite(direction: float):
	if direction != 0:
		# --- THE FIX: Swapped to < 0 ---
		sprite.flip_h = (direction < 0) 
		
		# KEEP THIS EXACTLY THE SAME (The hitboxes are already perfect)
		if direction > 0:
			$AttackArea.scale.x = 1 # Flips your keyframed animations to the Right
		else:
			$AttackArea.scale.x = -1  # Keeps your keyframed animations on the Left

func start_charge(direction_state):
	current_state = direction_state
	anim_player.play("charge") # Triggers the AnimationPlayer we just built!

func trigger_stun():
	current_state = State.STUNNED
	anim_player.play("stun") 
	
	stun_effect.visible = true
	if stun_effect.has_method("play"):
		stun_effect.play() 
	
	# Wait for 3 seconds seamlessly
	await get_tree().create_timer(3.0).timeout
	
	# --- THE FIX ---
	# 1. Turn off the floating stars
	stun_effect.visible = false
	if stun_effect.has_method("stop"):
		stun_effect.stop()
		
	# 2. Stop the AnimationPlayer so his body stops blinking
	if anim_player.is_playing() and anim_player.current_animation == "stun":
		anim_player.stop()
	
	# 3. Only go back to chasing if he didn't die while stunned
	if current_state == State.STUNNED:
		current_state = State.CHASE

# --- DAMAGE & HEALTH ---

func take_damage(amount: int, _attacker_x: float) -> void:
	if is_invincible or current_state == State.DEAD:
		return
		
	# Update Global Health
	GameState.minotaur_health -= amount
	GameState.print_status() # This prints the HP to your console
	
	if GameState.minotaur_health <= 0:
		die()
	elif GameState.minotaur_health <= next_phase_threshold and current_state == State.CHASE:
		next_phase_threshold -= 50
		current_state = State.REPOSITION

func die():
	current_state = State.DEAD
	stun_effect.visible = false
	anim_player.play("death")
	set_collision_layer_value(3, false)

# Make sure your AnimationPlayer's 'animation_finished' signal is connected to this!
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack" and current_state == State.NORMAL_ATTACK:
		current_state = State.CHASE
		
		# FORCE A 1.5 SECOND COOLDOWN BEFORE NEXT ATTACK
		can_attack = false
		await get_tree().create_timer(1.5).timeout 
		can_attack = true

# The helper function called by your AnimationPlayer timeline!
func set_invincible(state: bool) -> void:
	is_invincible = state

# Add this at the bottom of minotaur.gd
@export var attack_damage: int = 25 # How much health the Minotaur takes from the Knight

func _on_attack_area_area_entered(area: Area2D) -> void:
	# 'area' here is the Knight's HurtBox
	var knight = area.owner 
	
	if knight and knight.has_method("take_damage"):
		# Axe damage
		knight.take_damage(15, global_position.x)
		

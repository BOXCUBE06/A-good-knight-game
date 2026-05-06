extends Node2D

@onready var player = $Knight # Change "Player" to whatever your knight's node is named
@onready var player_health = $Knight/HealthComponentKnight
@onready var hud = $HUD # Change this path if your HUD is located somewhere else

func _ready() -> void:
	# --- CONNECT HEALTH ---
	# Listen for damage/healing and update the HUD
	player_health.health_changed.connect(hud.update_health)
	
	# Force the HUD to show the correct starting health immediately
	hud.update_health(player_health.current_health, player_health.max_health)
	
	# --- CONNECT POTIONS ---
	# Listen for when a potion is used and update the HUD
	player.potion_count_changed.connect(hud.update_potions)
	
	# Force the HUD to show the correct starting potions immediately
	hud.update_potions(player.potions_in_inventory)

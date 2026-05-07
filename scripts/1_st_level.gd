extends Node2D

@onready var player = $Knight 
@onready var hud = $HUD 

func _ready() -> void:
	# --- HEALTH ---
	# (Deleted! The HUD now listens to GameState automatically. No Level code needed.)
	
	# --- POTIONS ---
	# We still need to connect the Potions because they live on the Player.
	# Check if the HUD has the function before calling it to prevent crashes
	if hud.has_method("update_potions"):
		player.potion_count_changed.connect(hud.update_potions)
		hud.update_potions(player.potions_in_inventory)

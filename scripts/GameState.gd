extends Node

# --- Health ---
var knight_health: int = 100:
	set(value):
		knight_health = value
		knight_hp_changed.emit(knight_health)

var minotaur_health: int = 250:
	set(value):
		minotaur_health = value
		minotaur_hp_changed.emit(minotaur_health)

# --- Inventory ---
signal potions_changed(new_count)

var knight_potions: int = 3:
	set(value):
		knight_potions = value
		potions_changed.emit(knight_potions)

signal coins_changed(new_count)

var coins: int = 0:
	set(value):
		coins = value
		coins_changed.emit(coins)

# Signals
signal knight_hp_changed(new_hp)
signal minotaur_hp_changed(new_hp)

func print_status():
	print("--- BATTLE LOG ---")
	print("Knight HP: ", knight_health, " | Potions: ", knight_potions, " | Coins: ", coins)
	print("Minotaur HP: ", minotaur_health)
	print("------------------")

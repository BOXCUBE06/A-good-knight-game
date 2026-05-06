extends CanvasLayer # Make sure this matches your root node's type

# Grab references directly to your Label nodes
@onready var life_label = $"MarginContainer/HBoxContainer/Stats/LifeBox/Life Count"
@onready var potion_label = $"MarginContainer/HBoxContainer/Stats/PotionBox/Potion Count"
@onready var coin_label = $"MarginContainer/HBoxContainer/Stats/CoinBox/Coin Count"

# Function to update the health text
func update_health(current: int, max_amount: int) -> void:
	# Convert the integer to a String so the Label can display it
	life_label.text = str(current)

# Function to update the potion text
func update_potions(count: int) -> void:
	potion_label.text = str(count)
	
# Optional: Function for coins when you add them later!
func update_coins(count: int) -> void:
	coin_label.text = str(count)

extends CanvasLayer

@onready var life_label = $"MarginContainer/HBoxContainer/Stats/LifeBox/Life Count"
@onready var potion_label = $"MarginContainer/HBoxContainer/Stats/PotionBox/Potion Count"
@onready var coin_label = $"MarginContainer/HBoxContainer/Stats/CoinBox/Coin Count"

func _ready():
	if life_label == null or potion_label == null:
		print("!!! ERROR: Check label paths!")
		return

	# Connect GameState signals directly
	GameState.knight_hp_changed.connect(_on_knight_hp_changed)
	GameState.potions_changed.connect(_on_potions_changed) # <--- ADD THIS
	
	# Set initial text
	life_label.text = str(GameState.knight_health)
	potion_label.text = str(GameState.knight_potions) # <--- ADD THIS

func _on_knight_hp_changed(new_hp):
	if life_label:
		life_label.text = str(new_hp)

# <--- ADD THIS FUNCTION --->
func _on_potions_changed(new_count):
	if potion_label:
		potion_label.text = str(new_count)

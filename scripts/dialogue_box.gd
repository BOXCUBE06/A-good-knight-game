extends CanvasLayer

@onready var buy_button_1: Button = %BuyButton1
@onready var close_button: Button = %CloseButton

const SHOP_DIALOGUE = preload("res://Dialogues/shop.dialogue")
const CUSTOM_BALLOON = preload("res://Dialogues//balloon.tscn")

# Replace this with your actual global player stats reference
var player_coins: int = 5 
var item_1_cost: int = 10

func _ready() -> void:
	buy_button_1.pressed.connect(_on_buy_button_1_pressed)
	close_button.pressed.connect(_on_close_button_pressed)
	
	# Trigger the welcome dialogue
	show_dialogue("welcome")

func _on_buy_button_1_pressed() -> void:
	if player_coins >= item_1_cost:
		player_coins -= item_1_cost
		# Add your inventory logic here (e.g., Global.add_item("sword"))
		show_dialogue("success")
	else:
		show_dialogue("not_enough")

func show_dialogue(title: String) -> void:
	if get_tree().current_scene.has_node("Balloon"):
		return
		
	var balloon = CUSTOM_BALLOON.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(SHOP_DIALOGUE, title)
	
	
func _on_close_button_pressed() -> void:
	queue_free()

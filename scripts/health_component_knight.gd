extends Node
class_name HealthComponentKnight

signal took_damage(attacker_x: float)
signal died

@export var max_health: int = 100
var current_health: int

func _ready() -> void:
	current_health = max_health

func apply_damage(amount: int, attacker_x: float) -> void:
	if current_health <= 0:
		return
		
	current_health -= amount
	print("Entity took damage! Health: ", current_health)
	
	if current_health <= 0:
		died.emit()
	else:
		took_damage.emit(attacker_x)

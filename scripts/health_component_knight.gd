extends Node
class_name HealthComponentKnight

signal took_damage(attacker_x: float)
signal died
signal health_changed(current: int, max: int) # <--- ADD THIS

@export var max_health: int = 100
var current_health: int

func _ready() -> void:
	current_health = max_health
	# Optional: Emit right at the start so the HUD initializes correctly
	health_changed.emit(current_health, max_health) 

func apply_damage(amount: int, attacker_x: float) -> void:
	if current_health <= 0:
		return
		
	current_health -= amount
	health_changed.emit(current_health, max_health) # <--- ADD THIS
	
	if current_health <= 0:
		died.emit()
	else:
		took_damage.emit(attacker_x)
		
func heal(amount: int) -> bool:
	if current_health >= max_health:
		return false 
		
	current_health += amount
	if current_health > max_health:
		current_health = max_health
		
	health_changed.emit(current_health, max_health) # <--- ADD THIS
	return true

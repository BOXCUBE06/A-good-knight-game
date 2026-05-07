extends Node
class_name HealthComponentKnight

# We can keep max_health here as a limit
@export var max_health: int = 100

func heal(amount: int) -> bool:
	# 1. Check the REAL global health to see if we are already full
	if GameState.knight_health >= max_health:
		return false 
		
	# 2. Add the potion amount to the REAL global health
	GameState.knight_health += amount
	
	# 3. Cap it so you don't overheal past 100
	if GameState.knight_health > max_health:
		GameState.knight_health = max_health
		
	# GameState's internal code will automatically fire the signal to update your HUD!
	return true

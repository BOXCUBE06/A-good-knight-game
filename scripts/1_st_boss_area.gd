extends Node2D

# This script lives globally and tracks the health of everyone
var knight_health: int = 100
var minotaur_health: int = 250

func update_health():
	print("--- BATTLE STATUS ---")
	print("Knight HP: ", knight_health)
	print("Minotaur HP: ", minotaur_health)
	print("---------------------")

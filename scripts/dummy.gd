extends Area2D

@onready var sprite = $Sprite2D

func _on_area_entered(area: Area2D) -> void:
	print("Dummy hit by: ", area.name)
	blink_white()

func blink_white() -> void:
	sprite.modulate = Color(10, 10, 10, 1) 
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE

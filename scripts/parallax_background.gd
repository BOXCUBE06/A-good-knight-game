extends ParallaxBackground

@export var scroll_speed: float = 50.0

func _process(delta: float) -> void:
	# Move the background to the left constantly
	scroll_offset.x -= scroll_speed * delta

extends ParallaxLayer

# The @export keyword lets us change this number in the Inspector panel!
@export var scroll_speed: float = -15.0 

func _process(delta: float) -> void:
	# This constantly moves the layer a little bit every frame
	motion_offset.x += scroll_speed * delta

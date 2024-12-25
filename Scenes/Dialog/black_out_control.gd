@tool
class_name BlackOutControl
extends ColorRect

@export var fade_speed:float = 1
@export var fade_to_black:bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if fade_to_black:
		self.self_modulate.a = 1
	else:
		self.self_modulate.a = 0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if fade_to_black and self.self_modulate.a < 1:
		self_modulate.a = self_modulate.a + (delta * fade_speed)
	elif self_modulate.a > 0:
		self_modulate.a = self_modulate.a - (delta * fade_speed)
	pass

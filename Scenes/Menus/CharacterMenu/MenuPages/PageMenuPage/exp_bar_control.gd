@tool
class_name ExpBarControl
extends TextureRect

@export var full_rect:Control
@export var color_rect:ColorRect


@export var percent_full:float:
	set(val):
		printerr("Set Val:" + str(val))
		percent_full = val
		if color_rect:
			color_rect.size.x = full_rect.size.x * percent_full

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

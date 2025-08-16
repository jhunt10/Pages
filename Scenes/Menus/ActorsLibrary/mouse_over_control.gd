extends Control

@export var label:RichTextLabel
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.global_position = get_global_mouse_position()

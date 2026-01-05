@tool
class_name CampOptionsContainer
extends VBoxContainer

@export var resize_options:bool
var cached_size

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if resize_options or cached_size != self.size:
		cached_size = self.size
		resize_options = false
		for child in get_children():
			if child is FitScaleLabel:
				child._size_dirty = true
	pass

@tool
class_name FitScaleLabel
extends Control
@export var label:Label
@export var text:String:
	set(val):
		text = val
		if label:
			label.size = Vector2.ZERO
			label.text = text
			_size_dirty = true
@export var _size_dirty:bool
@export var center_x:bool=false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if label and _size_dirty:
		_size_dirty = false
		label.scale = Vector2(1, 1)
		label.custom_minimum_size = Vector2i.ZERO
		var label_scale = min(1, self.size.x / label.size.x, self.size.y / label.size.y)
		label.scale = Vector2(label_scale, label_scale)
		var new_x = 0
		if center_x:
			new_x = (self.size.x - (label_scale * label.size.x)) / 2
		var new_y = (self.size.y - (label_scale * label.size.y)) / 2
		label.position = Vector2i(new_x, new_y)
		print("Size Dirty: Self: %s | Label: %s | New Scale: %s" % [self.size, label.size, label_scale])
		#if label_scale == 1:
			#label.custom_minimum_size = self.size
		#else:
			#label.custom_minimum_size = Vector2i.ZERO
	pass

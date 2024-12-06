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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if label and _size_dirty:
		print("Size Dirty: Self: %s | Label: %s" % [self.size, label.size])
		_size_dirty = false
		label.scale = Vector2(1, 1)
		var label_scale = min(1, self.size.x / label.size.x)
		label.scale = Vector2(label_scale, label_scale)
		label.position.y = (self.size.y - (label_scale * label.size.y)) / 2
	pass

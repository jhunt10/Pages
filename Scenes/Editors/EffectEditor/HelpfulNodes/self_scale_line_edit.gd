@tool
class_name SelfScalingLineEdit
extends LineEdit

@export var resize:bool = false
@export var scale_mode:bool = false
@export var hidden_text_edit:TextEdit

@export var _padding: int = 8
var _parent_width_diff:int = 0
var _orig_min_size:Vector2i


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if resize:
		resize = false
		_sync_size()
	pass

func _input(event: InputEvent) -> void:
	if self.has_focus() and event is InputEventKey:
		_sync_size()

func set_sized_text(val:String):
	self.text = val
	self._sync_size()

func _sync_size():
	if !hidden_text_edit:
		printerr("SelfScalingLineEdit '%s' No Hidden TextEdit found." % [self.name])
		return
	
	hidden_text_edit.text = self.text
	var new_size = Vector2i(max(self._orig_min_size.x, hidden_text_edit.get_line_width(0) + (2 * _padding)),
							max(self._orig_min_size.y, self.size.y))
	if scale_mode:
		var new_scale = self.size.x / new_size.x
		self.scale = Vector2(new_scale, new_scale)
	else:
		var diff = new_size.x - self.size.x
		self.custom_minimum_size = new_size
	var parent = self.get_parent()
	if parent and parent is HBoxContainer:
		parent.reset_size()

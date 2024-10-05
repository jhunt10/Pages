class_name SelfScalingLineEdit
extends LineEdit

@onready var hidden_text_edit:TextEdit = $TextEdit

var _padding: int = 0
var _parent_width_diff:int = 0
var _orig_min_size:Vector2i


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	var key_input = event as InputEventKey
	if not self.has_focus() or not key_input:
		return
	_sync_size()
	
	
	

func _sync_size():
	hidden_text_edit.text = self.text
	var new_size = Vector2i(max(self._orig_min_size.x, hidden_text_edit.get_line_width(0) + (2 * _padding)),
							max(self._orig_min_size.y, self.size.y))
	var diff = new_size.x - self.size.x
	self.custom_minimum_size = new_size
	var parent:HBoxContainer = self.get_parent()
	if parent:
		parent.reset_size()

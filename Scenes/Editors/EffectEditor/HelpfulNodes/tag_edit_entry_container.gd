@tool
class_name TagEditEntryContainer
extends BackPatchContainer

@onready var delete_button:Button = $InnerContainer/DeleteButton
@onready var line_edit:SelfScalingLineEdit = $InnerContainer/SSLineEdit

var _set_text:String = ''
var _editable:bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	delete_button.pressed.connect(queue_free)
	if _set_text != '':
		self.set_text(_set_text, _editable)
	pass # Replace with function body.

func set_text(text:String, editable:bool):
	_editable = editable
	if delete_button:
		delete_button.visible = editable
	_set_text = text
	if line_edit:
		line_edit.set_sized_text(_set_text)
		line_edit.editable = _editable
	self.resize_self_around_child()
		
		
func get_text()->String:
	return line_edit.text

func lose_focus_if_has():
	if line_edit.has_focus():
		line_edit.release_focus()

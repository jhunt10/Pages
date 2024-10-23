@tool
class_name CostEditEntryContainer
extends BackPatchContainer

@onready var name_line_edit:SelfScalingLineEdit = $InnerContainer/SelfScalingLineEdit
@onready var cost_spin_box:SpinBox = $InnerContainer/SpinBox
@onready var delete_button:Button = $InnerContainer/Button

func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	delete_button.pressed.connect(self.queue_free)

func set_values(name:String, value:int):
	$InnerContainer/SelfScalingLineEdit.text = name
	$InnerContainer/SelfScalingLineEdit.resize = true
	$InnerContainer/SpinBox.set_value_no_signal(value)

func get_cost_key()->String:
	return name_line_edit.text

func get_cost_value()->int:
	return cost_spin_box.value

func check_for_change(data:Dictionary):
	var key = get_cost_key()
	if !data.keys.has(key):
		return true
	if data.get(key) != get_cost_value():
		return true
	return false

func lose_focus_if_has():
	if name_line_edit.has_focus():
		name_line_edit.release_focus()
	if cost_spin_box.has_focus():
		cost_spin_box.apply()
		cost_spin_box.release_focus()
	var spin_edit = cost_spin_box.get_line_edit()
	if spin_edit and spin_edit.has_focus():
		cost_spin_box.apply()
		spin_edit.release_focus()

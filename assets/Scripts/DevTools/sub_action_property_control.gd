class_name SubActionPropInputControl
extends Control

@onready var label:Label = $VBoxContainer/Label
@onready var option_button:LoadedOptionButton = $VBoxContainer/LoadedOptionButton
@onready var line_edit:LineEdit = $VBoxContainer/LineEdit
@onready var move_value_container = $VBoxContainer/MoveValueContainer

var _prop_type:BaseSubAction.SubActionPropType

var _ready_name:String
var _ready_type:BaseSubAction.SubActionPropType
var _ready_value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#if _ready_name != '':
		#set_prop(_ready_name, _ready_type, _ready_value)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func get_prop_name():
	return label.text.trim_prefix('*').trim_suffix(": ")

func get_prop_value():
	if _prop_type == BaseSubAction.SubActionPropType.TargetKey:
		return option_button.get_current_option_text()
	elif _prop_type == BaseSubAction.SubActionPropType.DamageKey:
		return option_button.get_current_option_text()
	elif _prop_type == BaseSubAction.SubActionPropType.MoveValue:
		move_value_container.visible = true
		var arr = []
		for n in range(4):
			arr.append((move_value_container.get_child(n) as SpinBox).value)
		return arr
	elif _prop_type == BaseSubAction.SubActionPropType.StringVal:
		return line_edit.text
	return null
	
	
func lose_focus_if_has():
	if move_value_container.visible:
		for child:SpinBox in move_value_container.get_children():
			if child.has_focus():
				child.release_focus()
			var line_edit = child.get_line_edit()
			if line_edit.has_focus():
				child.apply()
				line_edit.release_focus()
	
func set_prop(prop_name:String, prop_type:BaseSubAction.SubActionPropType, prop_value, is_unknown:bool):
	option_button.visible = false
	line_edit.visible = false
	move_value_container.visible = false
	label.text = prop_name + ": "
	if is_unknown:
		label.text = "*" + prop_name + ": "
	self._prop_type = prop_type
	
	if prop_type == BaseSubAction.SubActionPropType.TargetKey:
		option_button.visible = true
		option_button.get_options_func = get_target_options
		if prop_value is String and prop_value != '':
			option_button.load_options(prop_value)
	elif prop_type == BaseSubAction.SubActionPropType.DamageKey:
		option_button.visible = true
		option_button.get_options_func = get_damage_options
		if prop_value is String and prop_value != '':
			option_button.load_options(prop_value)
	elif prop_type == BaseSubAction.SubActionPropType.MoveValue:
		move_value_container.visible = true
		if prop_value is Array and prop_value.size() >= 1:
			(move_value_container.get_child(0) as SpinBox).set_value_no_signal(prop_value[0])
		if prop_value is Array and prop_value.size() >= 2:
			(move_value_container.get_child(1) as SpinBox).set_value_no_signal(prop_value[1])
		if prop_value is Array and prop_value.size() >= 3:
			(move_value_container.get_child(2) as SpinBox).set_value_no_signal(prop_value[2])
		if prop_value is Array and prop_value.size() >= 4:
			(move_value_container.get_child(3) as SpinBox).set_value_no_signal(prop_value[3])
	elif prop_type == BaseSubAction.SubActionPropType.StringVal:
		line_edit.visible = true
		if prop_value:
			line_edit.text = str(prop_value)
	else:
		line_edit.visible = true
		line_edit.text = "Unknown Prop Type: " + str(prop_type)

func get_target_options():
	return PageEditControl.Instance.get_target_params().keys()
	
func get_damage_options():
	return PageEditControl.Instance.get_damage_datas().keys()

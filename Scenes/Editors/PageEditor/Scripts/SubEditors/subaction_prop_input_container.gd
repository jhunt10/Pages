class_name SubActionPropInputContainer
extends HBoxContainer

@onready var prop_name_label:Label = $PropNameLabel
@onready var option_button:LoadedOptionButton = $PropInputsContainer/LoadedOptionButton
@onready var move_value_container:MoveInputContainer = $PropInputsContainer/MoveInputContainer
@onready var line_edit:LineEdit = $PropInputsContainer/LineEdit
@onready var spin_box:SpinBox = $PropInputsContainer/SpinBox

var _parent_subaction_edit_entry:SubActionEditEntryContainer
var _prop_name:String
var _prop_type:BaseSubAction.SubActionPropType

func lose_focus_if_has():
	if move_value_container.visible:
		move_value_container.lose_focus_if_has()
	if line_edit.visible and line_edit.has_focus():
		line_edit.release_focus()
	if spin_box.visible:
		if spin_box.has_focus():
			spin_box.release_focus()
		var spin_line = spin_box.get_line_edit()
		if spin_line.has_focus():
			spin_line.release_focus()

func set_props(parent, prop_name:String, prop_type:BaseSubAction.SubActionPropType, prop_value):
	option_button.visible = false
	move_value_container.visible = false
	line_edit.visible = false
	spin_box.visible = false
	
	_parent_subaction_edit_entry = parent
	option_button.visible = false
	line_edit.visible = false
	move_value_container.visible = false
	prop_name_label.text = prop_name + ": "
	self._prop_name = prop_name
	self._prop_type = prop_type
	
	if prop_type == BaseSubAction.SubActionPropType.TargetKey:
		option_button.visible = true
		option_button.get_options_func = get_target_options
		option_button.no_option_text = "Self"
		option_button.allways_show_none = true
		if prop_value is String and prop_value != '':
			option_button.load_options(prop_value)
		else:
			option_button.load_options()
	elif _prop_type == BaseSubAction.SubActionPropType.EnumVal:
		option_button.visible = true
		option_button.get_options_func = get_enum_options
		if prop_value is String and prop_value != '':
			option_button.load_options(prop_value)
	elif _prop_type == BaseSubAction.SubActionPropType.EffectKey:
		option_button.visible = true
		option_button.get_options_func = get_effect_options
		if prop_value is String and prop_value != '':
			option_button.load_options(prop_value)
	elif prop_type == BaseSubAction.SubActionPropType.DamageKey:
		option_button.visible = true
		option_button.get_options_func = get_damage_options
		if prop_value is String and prop_value != '':
			option_button.load_options(prop_value)
	elif prop_type == BaseSubAction.SubActionPropType.MissileKey:
		option_button.visible = true
		option_button.get_options_func = get_missile_options
		if prop_value is String and prop_value != '':
			option_button.load_options(prop_value)
	elif prop_type == BaseSubAction.SubActionPropType.MoveValue:
		move_value_container.visible = true
		move_value_container.set_value(prop_value)
	elif prop_type == BaseSubAction.SubActionPropType.StringVal:
		line_edit.visible = true
		if prop_value:
			line_edit.text = str(prop_value)
	elif prop_type == BaseSubAction.SubActionPropType.IntVal:
		spin_box.visible = true
		if prop_value:
			spin_box.set_value_no_signal(int(prop_value))
	else:
		line_edit.visible = true
		line_edit.text = "Unknown Prop Type: " + str(prop_type)

func get_prop_value():
	if _prop_type == BaseSubAction.SubActionPropType.EnumVal:
		return option_button.get_current_option_text()
	if _prop_type == BaseSubAction.SubActionPropType.TargetKey:
		return option_button.get_current_option_text()
	elif _prop_type == BaseSubAction.SubActionPropType.EffectKey:
		return option_button.get_current_option_text()
	elif _prop_type == BaseSubAction.SubActionPropType.DamageKey:
		return option_button.get_current_option_text()
	elif _prop_type == BaseSubAction.SubActionPropType.MissileKey:
		return option_button.get_current_option_text()
	elif _prop_type == BaseSubAction.SubActionPropType.MoveValue:
		return move_value_container.get_val()
	elif _prop_type == BaseSubAction.SubActionPropType.StringVal:
		return line_edit.text
	elif _prop_type == BaseSubAction.SubActionPropType.IntVal:
		return spin_box.value
	return null

func get_target_options():
	return []

func get_damage_options():
	return []

func get_effect_options():
	return []

func get_missile_options():
	return []

func get_enum_options():
	return _parent_subaction_edit_entry

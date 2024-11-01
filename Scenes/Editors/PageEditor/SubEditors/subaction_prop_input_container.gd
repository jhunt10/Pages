class_name SubActionPropInputContainer
extends HBoxContainer

@onready var prop_name_label:Label = $PropNameLabel
@onready var option_button:LoadedOptionButton = $PropInputsContainer/LoadedOptionButton
@onready var move_value_container:MoveInputContainer = $PropInputsContainer/MoveInputContainer
@onready var line_edit:LineEdit = $PropInputsContainer/LineEdit
@onready var spin_box:SpinBox = $PropInputsContainer/SpinBox

var _parent_subaction_edit_entry:SubActionEditEntryContainer
var _parent_subaction_editor:SubActionSubEditorControl:
	get: return _parent_subaction_edit_entry._parent_subaction_subeditor
	
var _prop_name:String
var _prop_type:BaseSubAction.SubActionPropTypes

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

func set_props(parent, prop_name:String, prop_type:BaseSubAction.SubActionPropTypes, prop_value):
	parent.root_editor_control.edit_entry_key_changed.connect(on_entry_key_change)
	_parent_subaction_edit_entry = parent
	option_button.visible = false
	line_edit.visible = false
	move_value_container.visible = false
	spin_box.visible = false
	prop_name_label.text = prop_name + ": "
	self._prop_name = prop_name
	self._prop_type = prop_type
	
	if prop_type == BaseSubAction.SubActionPropTypes.TargetParamKey:
		option_button.visible = true
		option_button.get_options_func = get_target_param_options
		if prop_value is String and prop_value != '':
			option_button.load_options(prop_value)
		else:
			option_button.load_options()
	elif prop_type == BaseSubAction.SubActionPropTypes.SetTargetKey:
		line_edit.visible = true
		if prop_value:
			line_edit.text = str(prop_value)
	elif _prop_type == BaseSubAction.SubActionPropTypes.TargetKey:
		option_button.visible = true
		option_button.get_options_func = get_target_key_option
		if prop_value is String and prop_value != '':
			option_button.load_options(prop_value)
	elif _prop_type == BaseSubAction.SubActionPropTypes.EffectKey:
		option_button.visible = true
		option_button.get_options_func = get_effect_options
		if prop_value is String and prop_value != '':
			option_button.load_options(prop_value)
	elif prop_type == BaseSubAction.SubActionPropTypes.DamageKey:
		option_button.visible = true
		option_button.get_options_func = get_damage_options
		if prop_value is String and prop_value != '':
			option_button.load_options(prop_value)
	elif prop_type == BaseSubAction.SubActionPropTypes.MissileKey:
		option_button.visible = true
		option_button.get_options_func = get_missile_options
		if prop_value is String and prop_value != '':
			option_button.load_options(prop_value)
	elif _prop_type == BaseSubAction.SubActionPropTypes.EnumVal:
		option_button.visible = true
		option_button.get_options_func = get_enum_options
		if prop_value is String and prop_value != '':
			option_button.load_options(prop_value)
	elif prop_type == BaseSubAction.SubActionPropTypes.MoveValue:
		move_value_container.visible = true
		move_value_container.set_value(prop_value)
	elif prop_type == BaseSubAction.SubActionPropTypes.StringVal:
		line_edit.visible = true
		if prop_value:
			line_edit.text = str(prop_value)
	elif prop_type == BaseSubAction.SubActionPropTypes.IntVal:
		spin_box.visible = true
		if prop_value:
			spin_box.set_value_no_signal(int(prop_value))
	else:
		line_edit.visible = true
		line_edit.text = "Unknown Prop Type: " + str(prop_type)

func get_prop_value():
	if _prop_type == BaseSubAction.SubActionPropTypes.EnumVal:
		return option_button.get_current_option_text()
	if _prop_type == BaseSubAction.SubActionPropTypes.TargetParamKey:
		return option_button.get_current_option_text()
	elif _prop_type == BaseSubAction.SubActionPropTypes.SetTargetKey:
		return line_edit.text
	if _prop_type == BaseSubAction.SubActionPropTypes.TargetKey:
		return option_button.get_current_option_text()
	elif _prop_type == BaseSubAction.SubActionPropTypes.EffectKey:
		return option_button.get_current_option_text()
	elif _prop_type == BaseSubAction.SubActionPropTypes.DamageKey:
		return option_button.get_current_option_text()
	elif _prop_type == BaseSubAction.SubActionPropTypes.MissileKey:
		return option_button.get_current_option_text()
	elif _prop_type == BaseSubAction.SubActionPropTypes.MoveValue:
		return move_value_container.get_val()
	elif _prop_type == BaseSubAction.SubActionPropTypes.StringVal:
		return line_edit.text
	elif _prop_type == BaseSubAction.SubActionPropTypes.IntVal:
		return spin_box.value
	return null

func clear():
	if _prop_type == BaseSubAction.SubActionPropTypes.EnumVal:
		option_button.load_options("")
	if _prop_type == BaseSubAction.SubActionPropTypes.TargetParamKey:
		option_button.load_options("")
	elif _prop_type == BaseSubAction.SubActionPropTypes.SetTargetKey:
		line_edit.text = ""
	elif _prop_type == BaseSubAction.SubActionPropTypes.TargetKey:
		option_button.load_options("")
	elif _prop_type == BaseSubAction.SubActionPropTypes.EffectKey:
		option_button.load_options("")
	elif _prop_type == BaseSubAction.SubActionPropTypes.DamageKey:
		option_button.load_options("")
	elif _prop_type == BaseSubAction.SubActionPropTypes.MissileKey:
		option_button.load_options("")
	elif _prop_type == BaseSubAction.SubActionPropTypes.MoveValue:
		move_value_container.set_value([0,0,0,0])
	elif _prop_type == BaseSubAction.SubActionPropTypes.StringVal:
		line_edit.text = ""
	elif _prop_type == BaseSubAction.SubActionPropTypes.IntVal:
		spin_box.value = 0


func on_entry_key_change(editor_key:String, old_key:String, new_key:String):
	if ((_prop_type == BaseSubAction.SubActionPropTypes.DamageKey and editor_key == "DamageDatas") or
		(_prop_type == BaseSubAction.SubActionPropTypes.MissileKey and editor_key == "MissileDatas") or
		(_prop_type == BaseSubAction.SubActionPropTypes.TargetParamKey and editor_key == "TargetParams")):
		if option_button.get_current_option_text() == old_key:
			option_button.load_options(new_key)

func get_target_key_option()->Array:
	return _parent_subaction_editor.get_target_key_options()

func get_target_param_options():
	return PageEditorControl.Instance.get_subeditor_option_keys("TargetParams")

func get_damage_options():
	return PageEditorControl.Instance.get_subeditor_option_keys("DamageDatas")

func get_effect_options():
	return EffectLibary._effects_data.keys()

func get_missile_options():
	return PageEditorControl.Instance.get_subeditor_option_keys("MissileDatas")

func get_enum_options():
	return _parent_subaction_edit_entry

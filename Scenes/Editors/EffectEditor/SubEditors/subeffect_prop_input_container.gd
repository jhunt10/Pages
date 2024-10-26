class_name SubEffectPropInputContainer
extends HBoxContainer

@onready var prop_name_label:Label = $PropNameLabel
@onready var option_button:LoadedOptionButton = $PropInputsContainer/LoadedOptionButton
#@onready var move_value_container:MoveInputContainer = $PropInputsContainer/MoveInputContainer
@onready var line_edit:LineEdit = $PropInputsContainer/LineEdit
@onready var spin_box:SpinBox = $PropInputsContainer/SpinBox

var _parent_subeffect_edit_entry:SubEffectEditEntryContainer
var _prop_name:String
var _prop_type:BaseSubEffect.SubEffectPropTypes
var _prop_enum_options:Array = []

func lose_focus_if_has():
	if line_edit.visible and line_edit.has_focus():
		line_edit.release_focus()
	if spin_box.visible:
		if spin_box.has_focus():
			spin_box.release_focus()
		var spin_line = spin_box.get_line_edit()
		if spin_line.has_focus():
			spin_line.release_focus()

func set_props(parent, prop_name:String, prop_type:BaseSubEffect.SubEffectPropTypes, prop_value):
	parent.root_editor_control.edit_entry_key_changed.connect(on_entry_key_change)
	_parent_subeffect_edit_entry = parent
	option_button.visible = false
	line_edit.visible = false
	spin_box.visible = false
	prop_name_label.text = prop_name + ": "
	self._prop_name = prop_name
	self._prop_type = prop_type
	
	if _prop_type == BaseSubEffect.SubEffectPropTypes.EnumVal:
		option_button.visible = true
		option_button.get_options_func = get_enum_options
		if prop_value is String and prop_value != '':
			option_button.load_options(prop_value)
	elif prop_type == BaseSubEffect.SubEffectPropTypes.DamageKey:
		option_button.visible = true
		option_button.get_options_func = get_damage_options
		if prop_value is String and prop_value != '':
			option_button.load_options(prop_value)
	elif prop_type == BaseSubEffect.SubEffectPropTypes.DamageModKey:
		option_button.visible = true
		option_button.get_options_func = get_damage_mod_options
		if prop_value is String and prop_value != '':
			option_button.load_options(prop_value)
	elif prop_type == BaseSubEffect.SubEffectPropTypes.StatModKey:
		option_button.visible = true
		option_button.get_options_func = get_stat_mod_options
		if prop_value is String and prop_value != '':
			option_button.load_options(prop_value)
	elif prop_type == BaseSubEffect.SubEffectPropTypes.StringVal:
		line_edit.visible = true
		if prop_value:
			line_edit.text = str(prop_value)
	elif prop_type == BaseSubEffect.SubEffectPropTypes.IntVal:
		spin_box.visible = true
		if prop_value:
			spin_box.set_value_no_signal(int(prop_value))
	else:
		line_edit.visible = true
		line_edit.text = "Unknown Prop Type: " + BaseSubEffect.SubEffectPropTypes.keys()[prop_type]

func get_prop_value():
	if _prop_type == BaseSubEffect.SubEffectPropTypes.EnumVal:
		return option_button.get_current_option_text()
	elif _prop_type == BaseSubEffect.SubEffectPropTypes.DamageKey:
		return option_button.get_current_option_text()
	elif _prop_type == BaseSubEffect.SubEffectPropTypes.DamageModKey:
		return option_button.get_current_option_text()
	elif _prop_type == BaseSubEffect.SubEffectPropTypes.StatModKey:
		return option_button.get_current_option_text()
	elif _prop_type == BaseSubEffect.SubEffectPropTypes.StringVal:
		return line_edit.text
	elif _prop_type == BaseSubEffect.SubEffectPropTypes.IntVal:
		return spin_box.value
	return null

func clear():
	if _prop_type == BaseSubEffect.SubEffectPropTypes.EnumVal:
		option_button.load_options("")
	elif _prop_type == BaseSubEffect.SubEffectPropTypes.DamageKey:
		option_button.load_options("")
	elif _prop_type == BaseSubEffect.SubEffectPropTypes.DamageModKey:
		option_button.load_options("")
	elif _prop_type == BaseSubEffect.SubEffectPropTypes.StatModKey:
		option_button.load_options("")
	elif _prop_type == BaseSubEffect.SubEffectPropTypes.StringVal:
		line_edit.text = ""
	elif _prop_type == BaseSubEffect.SubEffectPropTypes.IntVal:
		spin_box.value = 0


func on_entry_key_change(editor_key:String, old_key:String, new_key:String):
	if ((_prop_type == BaseSubEffect.SubEffectPropTypes.DamageKey and editor_key == "DamageDatas")):
		if option_button.get_current_option_text() == old_key:
			option_button.load_options(new_key)

func get_damage_options()->Array:
	return _parent_subeffect_edit_entry.root_editor_control.get_subeditor_option_keys("DamageDatas")

func get_damage_mod_options()->Array:
	return _parent_subeffect_edit_entry.root_editor_control.get_subeditor_option_keys("DamageMods")

func get_stat_mod_options()->Array:
	return _parent_subeffect_edit_entry.root_editor_control.get_subeditor_option_keys("StatMods")

func get_enum_options():
	return _prop_enum_options

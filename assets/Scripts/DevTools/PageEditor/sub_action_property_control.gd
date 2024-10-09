class_name SubActionPropInputControl
extends Control

@onready var label:Label = $VBoxContainer/Label
@onready var option_button:LoadedOptionButton = $VBoxContainer/LoadedOptionButton
@onready var line_edit:LineEdit = $VBoxContainer/LineEdit
@onready var spin_box:SpinBox = $VBoxContainer/SpinBox
@onready var move_value_container:MoveInputContainer = $VBoxContainer/MoveInputContainer

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
	
	
func lose_focus_if_has():
	if move_value_container.visible:
		move_value_container.lose_focus_if_has()
	
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
		option_button.no_option_text = "Self"
		option_button.allways_show_none = true
		if prop_value is String and prop_value != '':
			option_button.load_options(prop_value)
		else:
			option_button.load_options()
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

func get_target_options():
	return PageEditControl.Instance.get_target_params().keys()
	
func get_damage_options():
	return PageEditControl.Instance.get_damage_datas().keys()
	
func get_effect_options():
	return MainRootNode.Instance.effect_libary._effects_data.keys()
	
func get_missile_options():
	return PageEditControl.Instance.get_missile_datas().keys()

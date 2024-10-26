class_name SubEffectPropInputControl
extends Control

@onready var input_container:HBoxContainer = $HBoxContainer
@onready var label:Label = $HBoxContainer/Label
@onready var option_button:LoadedOptionButton = $HBoxContainer/LoadedOptionButton
@onready var line_edit:LineEdit = $HBoxContainer/LineEdit
@onready var spin_box:SpinBox = $HBoxContainer/SpinBox

@onready var trigger_input_container:VBoxContainer = $TriggersInputContainer
@onready var trigger_option_button:LoadedOptionButton = $TriggersInputContainer/HBoxContainer/LoadedOptionButton
@onready var triggers_label:Label = $TriggersInputContainer/HBoxContainer/Label
@onready var trigger_container:FlowContainer = $TriggersInputContainer/FlowContainer
var _triggers:Dictionary = {}

var _prop_type:BaseSubEffect.SubEffectPropTypes
var _enum_options:Array = []
var _ready_name:String
var _ready_type:BaseSubEffect.SubEffectPropTypes
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
	if _prop_type == BaseSubEffect.SubEffectPropTypes.Triggers:
		return _triggers.keys()
	elif _prop_type == BaseSubEffect.SubEffectPropTypes.StatModKey:
		return option_button.get_current_option_text()
	elif _prop_type == BaseSubEffect.SubEffectPropTypes.DamageKey:
		return option_button.get_current_option_text()
	elif _prop_type == BaseSubEffect.SubEffectPropTypes.SubEffectKey:
		return option_button.get_current_option_text()
	elif _prop_type == BaseSubEffect.SubEffectPropTypes.EnumVal:
		return option_button.get_current_option_text()
	elif _prop_type == BaseSubEffect.SubEffectPropTypes.StringVal:
		return line_edit.text
	elif _prop_type == BaseSubEffect.SubEffectPropTypes.IntVal:
		return spin_box.value
	return null
	
	
func lose_focus_if_has():
	if line_edit.has_focus():
		line_edit.release_focus()
	if spin_box.has_focus():
		spin_box.release_focus()
	if spin_box.get_line_edit().has_focus():
		spin_box.get_line_edit().release_focus()
	pass
	
func set_prop(prop_name:String, prop_type:BaseSubEffect.SubEffectPropTypes, prop_value, is_unknown:bool=false, enum_options:Array=[]):
	_enum_options = enum_options
	option_button.visible = false
	line_edit.visible = false
	spin_box.visible = false
	trigger_input_container.visible = false
	label.text = prop_name + ": "
	if is_unknown:
		label.text = "*" + prop_name + ": "
	self._prop_type = prop_type
	
	if prop_type == BaseSubEffect.SubEffectPropTypes.StatModKey:
		option_button.visible = true
		option_button.get_options_func = get_stat_mod_options
		if prop_value is String and prop_value != '':
			option_button.load_options(prop_value)
		else:
			option_button.load_options()
	elif prop_type == BaseSubEffect.SubEffectPropTypes.DamageKey:
		option_button.visible = true
		option_button.get_options_func = get_damage_mod_options
		if prop_value is String and prop_value != '':
			option_button.load_options(prop_value)
		else:
			option_button.load_options()
	elif prop_type == BaseSubEffect.SubEffectPropTypes.EnumVal:
		option_button.visible = true
		option_button.get_options_func = get_enum_options
		if prop_value is String and prop_value != '':
			option_button.load_options(prop_value)
		else:
			option_button.load_options()
	elif prop_type ==  BaseSubEffect.SubEffectPropTypes.StringVal:
		line_edit.visible = true
		if prop_value:
			line_edit.text = str(prop_value)
	elif prop_type ==  BaseSubEffect.SubEffectPropTypes.IntVal:
		spin_box.visible = true
		if prop_value:
			spin_box.set_value_no_signal(int(prop_value))
			
	elif prop_type ==  BaseSubEffect.SubEffectPropTypes.Triggers:
		input_container.visible = false
		trigger_input_container.visible = true
		trigger_option_button.get_options_func = get_triggers
		triggers_label.text = prop_name
		trigger_option_button.item_selected.connect(on_trigger_selected)
		for trigger in prop_value:
			_add_trigger(trigger)
	else:
		line_edit.visible = true
		line_edit.text = "Unknown Prop Type: " + str(prop_type)

func get_stat_mod_options():
	return EffectEditorControl.Instance.get_stat_mods()
	
func get_damage_mod_options():
	return []
	
func get_sub_effect_keys():
	return []
	
func get_enum_options():
	return _enum_options

func get_triggers():
	return BaseEffect.EffectTriggers.keys()

func on_trigger_selected(index):
	var trigger_name = trigger_option_button.get_item_text(index)
	_add_trigger(trigger_name)
	trigger_option_button.selected = -1

func _add_trigger(trigger_name):
	if not trigger_name is String:
		trigger_name = BaseEffect.EffectTriggers.keys()[int(trigger_name)]
	
	if _triggers.keys().has(trigger_name):
		return
	var new_trigger = HBoxContainer.new()
	var new_button = Button.new()
	new_button.text = "X"
	new_button.pressed.connect(on_delete_trigger.bind(trigger_name))
	new_trigger.add_child(new_button)
	var new_label = Label.new()
	new_label.text = trigger_name
	new_trigger.add_child(new_label)
	trigger_container.add_child(new_trigger)
	_triggers[trigger_name] = new_trigger

func on_delete_trigger(trigger_name):
	if _triggers.keys().has(trigger_name):
		var node = _triggers[trigger_name]
		node.queue_free()
		_triggers.erase(trigger_name)

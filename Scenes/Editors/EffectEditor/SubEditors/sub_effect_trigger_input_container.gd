class_name SubEffectTriggerInputContainer
extends VBoxContainer

@onready var title_label:Label = $TitleContainer/PropNameLabel
@onready var add_option_button:LoadedOptionButton = $TitleContainer/AddOptionButton
@onready var premade_trigger_entry:TriggerEditEntryContainer = $PremadeTriggerEntry
@onready var entries_container:FlowContainer = $EntriesContainer

func _ready() -> void:
	add_option_button.get_options_func = get_trigger_options
	add_option_button.item_selected.connect(on_add_trigger)
	premade_trigger_entry.visible = false
	
func set_props(parent, prop_name:String, prop_type:BaseSubEffect.SubEffectPropTypes, prop_value):
	if !title_label: title_label = $TitleContainer/PropNameLabel
	title_label.text = prop_name + ":"
	if prop_value and prop_value is Array:
		for val in prop_value:
			_add_trigger(val)

func lose_focus_if_has():
	pass

func get_prop_value():
	return get_triggers()

func clear():
	for child in entries_container.get_children():
		child.queue_free()

func check_for_change(arr):
	var has_triggers = get_triggers()
	if !arr:
		return has_triggers.size() == 0
	if arr.size() != has_triggers.size():
		#TODO: Actual checking
		return true
	return false

func get_triggers()->Array:
	var out_list = []
	for child:TriggerEditEntryContainer in entries_container.get_children():
		out_list.append(child.label.text)
	return out_list

func get_trigger_options()->Array:
	return BaseEffect.EffectTriggers.keys()

func on_add_trigger(index):
	var option = add_option_button.get_current_option_text()
	_add_trigger(option)

func _add_trigger(name:String):
	var new_trigger:TriggerEditEntryContainer = premade_trigger_entry.duplicate()
	entries_container.add_child(new_trigger)
	new_trigger.set_label(name)
	new_trigger.visible = true
	

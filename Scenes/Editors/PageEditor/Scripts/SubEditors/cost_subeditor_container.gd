@tool
class_name CostSubEditorContainer
extends BaseSubEditorContainer

@export var add_button:Button
@export var premade_cost_entry:CostEditEntryContainer
@export var entry_container:FlowContainer


var _cost_entries:Array = []

func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	premade_cost_entry.visible = false

func lose_focus_if_has():
	for cost_entry:CostEditEntryContainer in _cost_entries:
		cost_entry.lose_focus_if_has()

func has_change():
	for cost_entry:CostEditEntryContainer in _cost_entries:
		if cost_entry.check_for_change(_loaded_data):
			return true
	return false

func load_data(object_key:String, data:Dictionary):
	super(object_key, data)
	for key in data.keys():
		var val = data[key]
		if not val is float:
			continue
		var new_entry:CostEditEntryContainer = premade_cost_entry.duplicate()
		new_entry.visible = true
		new_entry.set_values(key, val)
		entry_container.add_child(new_entry)
		_cost_entries.append(new_entry)

func build_save_data()->Dictionary:
	var dict = {}
	for cost_entry:CostEditEntryContainer in _cost_entries:
		dict[cost_entry.get_cost_key()] = cost_entry.get_cost_value()
	return dict

@tool
class_name CostSubEditorContainer
extends BaseSubEditorContainer

@export var add_button:Button
@export var premade_cost_entry:CostEditEntryContainer
@export var entry_container:FlowContainer


func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	premade_cost_entry.visible = false
	add_button.pressed.connect(create_new_entry.bind("", 0))

func lose_focus_if_has():
	for cost_entry:CostEditEntryContainer in entry_container.get_children():
		cost_entry.lose_focus_if_has()

func has_change():
	var loaded_keys = _loaded_data.keys()
	for cost_entry:CostEditEntryContainer in entry_container.get_children():
		if cost_entry.check_for_change(_loaded_data):
			return true
		var cost_key = cost_entry.get_cost_key()
		if loaded_keys.has(cost_key):
			loaded_keys.erase(cost_key)
	# Keys that were loaed but are now gone
	if loaded_keys.size() > 0:
		return true
	return false

func clear():
	for cost_entry:CostEditEntryContainer in entry_container.get_children():
		cost_entry.queue_free()

func load_data(object_key:String, data:Dictionary):
	super(object_key, data)
	for key in data.keys():
		var val = data[key]
		if not val is float:
			continue
		create_new_entry(key, val)

func create_new_entry(key, val):
	var new_entry:CostEditEntryContainer = premade_cost_entry.duplicate()
	new_entry.visible = true
	new_entry.set_values(key, val)
	entry_container.add_child(new_entry)

func build_save_data()->Dictionary:
	var dict = {}
	for cost_entry:CostEditEntryContainer in entry_container.get_children():
		dict[cost_entry.get_cost_key()] = cost_entry.get_cost_value()
	return dict

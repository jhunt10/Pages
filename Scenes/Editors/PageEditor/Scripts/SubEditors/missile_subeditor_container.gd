@tool
class_name MissileSubEditorContainer
extends BaseSubEditorContainer

@export var add_button:Button
@export var premade_edit_entry:MissileEditEntryContainer
@export var entries_container:VBoxContainer

func get_key_to_input_mapping()->Dictionary:
	var dict = {}
	for entry:MissileEditEntryContainer in entries_container.get_children():
		var key = entry.key_line_edit.text
		dict[key] = entry
	return dict

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint(): return
	add_button.pressed.connect(on_add_button)
	premade_edit_entry.visible = false

func clear():
	_loaded_data.clear()
	for child in entries_container.get_children():
		child.queue_free()

func has_change():
	var loaded_keys = _loaded_data.keys()
	for entry:MissileEditEntryContainer in entries_container.get_children():
		if entry.has_change():
			return true
		var key = entry.key_line_edit.text
		if loaded_keys.has(key):
			loaded_keys.erase(key)
	# Keys that were loaed but are now gone
	if loaded_keys.size() > 0:
		return true
	return false

func load_data(object_key:String, data:Dictionary):
	_loaded_data = data.duplicate(true)
	for key in data:
		create_new_entry(key, data[key])

func create_new_entry(key:String, data:Dictionary):
	var new_entry:MissileEditEntryContainer = premade_edit_entry.duplicate()
	entries_container.add_child(new_entry)
	new_entry.visible = true
	new_entry.root_editor_control = root_editor_control
	if key == "":
		key = "MissileDatas" + str((entries_container.get_child_count()))
	new_entry.load_data(key, data)

func on_add_button():
	create_new_entry("", {})

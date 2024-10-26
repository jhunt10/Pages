@tool
class_name BaseListSubEditorConatiner
extends BaseSubEditorContainer

@export var default_entry_name:String
@export var add_button:Button
@export var premade_edit_entry:BaseSubEditEntryContainer
@export var entries_container:Container


func get_key_to_input_mapping()->Dictionary:
	var dict = {}
	for entry:BaseSubEditEntryContainer in entries_container.get_children():
		var key = entry.get_entry_key()
		dict[key] = entry
	return dict

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	if add_button:
		add_button.pressed.connect(on_add_button)
	premade_edit_entry.visible = false

func clear():
	_loaded_data.clear()
	for child in entries_container.get_children():
		child.queue_free()
	super()

func has_change():
	var loaded_keys = _loaded_data.keys()
	var entries = entries_container.get_children()
	if _loaded_data.size() != entries.size():
		return true
	for entry:BaseSubEditEntryContainer in entries:
		if entry.has_change():
			return true
		var key = entry.get_entry_key()
		if loaded_keys.has(key):
			loaded_keys.erase(key)
	# Keys that were loaed but are now gone
	if loaded_keys.size() > 0:
		return true
	return false

func load_data(object_key:String, data:Dictionary):
	_object_key = object_key
	_loaded_data = data.duplicate(true)
	for key in data:
		create_new_entry(key, data[key])

func create_new_entry(key:String, data:Dictionary)->String:
	var new_entry:BaseSubEditEntryContainer = premade_edit_entry.duplicate()
	entries_container.add_child(new_entry)
	new_entry.visible = true
	if key == "":
		key = default_entry_name + str((entries_container.get_child_count()))
	new_entry.root_editor_control = self.root_editor_control
	new_entry.load_data(key, data)
	new_entry.key_changed.connect(on_entry_key_change)
	return key

func on_add_button():
	create_new_entry("", {})

func on_entry_key_change(old_key:String, new_key:String):
	set_show_change(has_change())
	root_editor_control.edit_entry_key_changed.emit(self._object_key, old_key, new_key)

@tool
class_name DamageSubEditorContainer
extends BaseSubEditorContainer

@export var add_button:Button
@export var premade_edit_entry:DamageEditEntryContainer
@export var damage_entries_container:VBoxContainer

func get_key_to_input_mapping()->Dictionary:
	var dict = {}
	for entry:DamageEditEntryContainer in damage_entries_container.get_children():
		var key = entry.damage_key_line_edit.text
		dict[key] = entry
	return dict

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint(): return
	add_button.pressed.connect(on_add_button)
	premade_edit_entry.visible = false

func clear():
	_loaded_data.clear()
	for child in damage_entries_container.get_children():
		damage_entries_container.remove_child(child)
	

func load_data(object_key:String, data:Dictionary):
	_loaded_data = data
	for key in data:
		create_new_entry(key, data[key])

func create_new_entry(key:String, data:Dictionary):
	var new_entry:DamageEditEntryContainer = premade_edit_entry.duplicate()
	damage_entries_container.add_child(new_entry)
	new_entry.visible = true
	if key == "":
		key = "DamgeData" + str((damage_entries_container.get_child_count()+1))
	new_entry.load_data(key, data)

func on_add_button():
	create_new_entry("", {})

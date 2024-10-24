@tool
class_name TargetSubEditorContainer
extends BaseSubEditorContainer

@export var options_button:LoadedOptionButton
@export var delete_button:Button
@export var target_edit_entry_container:TargetEditEntryContainer

func get_key_to_input_mapping()->Dictionary:
	var dict = {}
	return dict

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint(): return
	delete_button.pressed.connect(on_delete_button)

func clear():
	_loaded_data.clear()
	

func has_change():
	#TODO
	return false

func load_data(object_key:String, data:Dictionary):
	_loaded_data = data.duplicate(true)
	if data.size() > 0:
		load_entry(data.keys()[0])

func load_entry(key:String):
	var data = _loaded_data.get(key, {})
	target_edit_entry_container.load_data(key, data)

func on_delete_button():
	pass

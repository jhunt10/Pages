@tool
class_name BaseSubEditorContainer
extends BackPatchContainer

signal data_changed

@export var root_editor_control:RootEditorControler

var _loaded_data:Dictionary = {}


func get_key_to_input_mapping()->Dictionary:
	return {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint(): return
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	if Engine.is_editor_hint(): return
	pass

func lose_focus_if_has():
	var mapping = get_key_to_input_mapping()
	for key in mapping.keys():
		var input_node = get_key_to_input_mapping().get(key)
		_input_lose_focus_if_has(key, input_node)

func has_change():
	var mapping = get_key_to_input_mapping()
	for key in mapping.keys():
		var input_node = get_key_to_input_mapping().get(key)
		if _check_input_has_changed(key, _loaded_data, input_node):
			return true
	return false

func load_data(object_key:String, data:Dictionary):
	_loaded_data = data
	var mapping = get_key_to_input_mapping()
	for key in mapping.keys():
		var input_node = get_key_to_input_mapping().get(key)
		_load_input(key, _loaded_data, input_node)

func build_save_data()->Dictionary:
	var dict = {}
	var mapping = get_key_to_input_mapping()
	for key in mapping.keys():
		var input_node = get_key_to_input_mapping().get(key)
		_save_input(key, dict, input_node)
	return dict




func _load_input(key, data, input_node):
	if input_node is LineEdit or input_node is TextEdit:
		input_node.text = data.get(key, "")
	elif input_node is LoadedOptionButton:
		input_node.load_options(data.get(key, ""))
	elif input_node is TagEditContainer:
		input_node.load_optional_tags(data.get(key, []))
	elif input_node is MoveInputContainer:
		input_node.set_value(data.get(key, null))
	else:
		printerr("%s: Unknown input type: '%s'." % [self.name, input_node])

func _input_lose_focus_if_has(key, input_node):
	if input_node is LineEdit or input_node is TextEdit:
		if input_node.has_focus():
			input_node.release_focus()
	elif input_node.has_method("lose_focus_if_has"):
		input_node.lose_focus_if_has()
	elif input_node is LoadedOptionButton:
		return
	else:
		printerr("Unknown input type: '%s'." % [input_node])

func _check_input_has_changed(key, data, input_node)->bool:
	if input_node is LineEdit or input_node is TextEdit:
		return input_node.text != data.get(key, "")
	elif input_node is LoadedOptionButton:
		return input_node.get_current_option_text() != data.get(key, "")
	elif input_node is TagEditContainer:
		return input_node.chack_for_change(data.get(key, []))
	elif input_node is MoveInputContainer:
		return input_node.get_val() == data.get(key, "")
	else:
		printerr("%s: Unknown input type: '%s'." % [self.name, input_node])
	return false

func _save_input(key, data, input_node):
	if input_node is LineEdit or input_node is TextEdit:
		data[key] = input_node.text
	elif input_node is LoadedOptionButton:
		data[key] = input_node.get_current_option_text()
	elif input_node is TagEditContainer:
		data[key] = input_node.get_tags()
	elif input_node is MoveInputContainer:
		data[key] = input_node.get_val()
	else:
		printerr("%s: Unknown input type: '%s'." % [self.name, input_node])

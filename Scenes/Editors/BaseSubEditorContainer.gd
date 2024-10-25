@tool
class_name BaseSubEditorContainer
extends BackPatchContainer

signal data_changed

@export var title_label:Label
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

func set_show_change(show:bool):
	if !title_label:
		return
	var raw_title = title_label.text.trim_prefix("*")
	if show:
		title_label.text = "*" + raw_title
	else:
		title_label.text = raw_title

func lose_focus_if_has():
	var mapping = get_key_to_input_mapping()
	for key in mapping.keys():
		var input_node = get_key_to_input_mapping().get(key)
		_input_lose_focus_if_has(key, input_node)

func has_change():
	var mapping = get_key_to_input_mapping()
	var loaded_keys = _loaded_data.keys()
	for key in mapping.keys():
		var input_node = get_key_to_input_mapping().get(key)
		if _check_input_has_changed(key, _loaded_data, input_node):
			print("Change found in %s" % [key])
			return true
	return false

func clear():
	var mapping = get_key_to_input_mapping()
	for key in mapping.keys():
		var input_node = get_key_to_input_mapping().get(key)
		_clear_input(key, input_node)
	_loaded_data.clear()

func load_data(object_key:String, data:Dictionary):
	_loaded_data = data.duplicate(true)
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
	elif input_node is SpinBox:
		input_node.set_value_no_signal(data.get(key, 0))
	elif input_node is CheckBox:
		input_node.button_pressed = data.get(key, false)
	elif input_node is LoadedOptionButton:
		input_node.load_options(data.get(key, ""))
	elif input_node is TagEditContainer:
		input_node.load_optional_tags(data.get(key, []))
	elif input_node is MoveInputContainer:
		input_node.set_value(data.get(key, null))
	else:
		printerr("%s._load_input: Key '%s' has unknown input type: '%s'." % [self.name, key, input_node])

func _input_lose_focus_if_has(key, input_node):
	if input_node is LineEdit or input_node is TextEdit:
		if input_node.has_focus():
			input_node.release_focus()
	elif input_node is SpinBox:
		input_node.apply
		var line = input_node.get_line_edit()
		if line.has_focus():
			line.release_focus()
	elif input_node is CheckBox:
		if input_node.has_focus():
			input_node.release_focus()
	elif input_node.has_method("lose_focus_if_has"):
		input_node.lose_focus_if_has()
	elif input_node is LoadedOptionButton:
		return
	else:
		printerr("%s._input_lose_focus_if_has: Key '%s' has unknown input type: '%s'." % [self.name, key, input_node])

func _check_input_has_changed(key, data, input_node)->bool:
	if input_node is LineEdit or input_node is TextEdit:
		return input_node.text != data.get(key, "")
	elif input_node is SpinBox:
		return input_node.value != data.get(key, 0)
	elif input_node is CheckBox:
		return input_node.button_pressed != data.get(key, false)
	elif input_node is LoadedOptionButton:
		return input_node.get_current_option_text() != data.get(key, "")
	elif input_node is TagEditContainer:
		return input_node.check_for_change(data.get(key, []))
	elif input_node is MoveInputContainer:
		return input_node.check_for_change(data.get(key, null))
	elif input_node is SubActionPropInputContainer:
		return input_node.get_prop_value() != data.get(key, "")
	elif input_node is BaseSubEditorContainer:
		return input_node.has_change()
	else:
		printerr("%s._check_input_has_changed: Key '%s' has unknown input type: '%s'." % [self.name, key, input_node])
	return false

func _save_input(key, data, input_node):
	if input_node is LineEdit or input_node is TextEdit:
		data[key] = input_node.text
	elif input_node is SpinBox:
		data[key] = input_node.value
	elif input_node is CheckBox:
		data[key] = input_node.button_pressed
	elif input_node is LoadedOptionButton:
		data[key] = input_node.get_current_option_text()
	elif input_node is TagEditContainer:
		data[key] = input_node.get_tags()
	elif input_node is MoveInputContainer:
		data[key] = input_node.get_val()
	elif input_node is SubActionPropInputContainer:
		data[key] = input_node.get_prop_value() 
	elif input_node is BaseSubEditorContainer:
		data[key] = input_node.build_save_data() 
	else:
		printerr("%s._save_input: Key '%s' has unknown input type: '%s'." % [self.name, key, input_node])

func _clear_input(key, input_node):
	if input_node is LineEdit or input_node is TextEdit:
		input_node.text = ""
	elif input_node is SpinBox:
		input_node.value = 0
	elif input_node is CheckBox:
		input_node.button_pressed = false
	elif input_node is LoadedOptionButton:
		input_node.load_options("")
	elif input_node is TagEditContainer:
		input_node.load_optional_tags([])
	elif input_node is MoveInputContainer:
		input_node.set_value([0,0,0,0])
	elif input_node is SubActionPropInputContainer:
		input_node.clear() 
	else:
		printerr("%s._clear_input: Key '%s' has unknown input type: '%s'." % [self.name, key, input_node])
	

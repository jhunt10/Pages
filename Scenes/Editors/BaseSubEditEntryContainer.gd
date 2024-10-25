@tool
class_name BaseSubEditEntryContainer
extends BaseSubEditorContainer

signal key_changed(old_key:String, new_key:String)

func _get_key_input()->LineEdit:
	return null
func _get_delete_button()->Button:
	return null

func get_entry_key()->String:
	var key_input = _get_key_input()
	if !key_input:
		printerr("%s does not have key_input." % [self.name])
		return ""
	return key_input.text
	

func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	var key_input = _get_key_input()
	if !key_input:
		printerr("%s does not have key_input." % [self.name])
		return
	key_input.focus_exited.connect(on_key_change)
	var delete_button = _get_delete_button()
	if delete_button:
		delete_button.pressed.connect(on_delete)

func on_key_change():
	var key_input = _get_key_input()
	if !key_input:
		printerr("%s missing key_input." % [self.name])
		return
	if key_input.text == _object_key:
		return
	var old_key = _object_key
	_object_key = key_input.text
	key_changed.emit(old_key, _object_key)

func load_data(object_key:String, data:Dictionary):
	var key_input = _get_key_input()
	if !key_input:
		printerr("%s does not have key_input." % [self.name])
		return
	key_input.text = object_key
	super(object_key, data)

func lose_focus_if_has():
	super()
	var key_input = _get_key_input()
	if key_input and key_input.has_focus():
		key_input.release_focus()

func on_delete():
	self.queue_free()

class_name PageFileEditControl
extends Control

signal file_changed

@onready var file_path_input:LineEdit = $VBoxContainer/HBoxContainer/FilePathLineEdit
@onready var file_name_input:LineEdit = $VBoxContainer/HBoxContainer2/FileNameLineEdit
@onready var save_button:Button = $VBoxContainer/HBoxContainer2/SaveButton
@onready var file_button:Button = $VBoxContainer/HBoxContainer/FileButton
@onready var file_dialog:FileDialog = $FileDialog

var _last_file_name:String
var _last_file_path:String
var parent_edit_control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	file_name_input.focus_exited.connect(on_focus_leave_file_name)
	file_path_input.focus_exited.connect(on_focus_leave_file_path)
	file_button.pressed.connect(on_file_button)
	save_button.pressed.connect(on_save)
	file_dialog.title = "Select Action File"
	#file_dialog.filters = PackedStringArray([".json"])
	file_dialog.file_selected.connect(set_load_path)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func on_file_button():
	file_dialog.popup_centered_ratio()

func on_file_selected(arr:PackedStringArray):
	set_load_path(arr[0])

func lose_focus_if_has():
	if file_path_input.has_focus():
		file_path_input.release_focus()
	if file_name_input.has_focus():
		file_name_input.release_focus()

func on_focus_leave_file_path():
	if _last_file_path != file_path_input.text:
		file_changed.emit()
		_last_file_path = file_path_input.text

func on_focus_leave_file_name():
	_fix_file_name()
	if _last_file_name != file_name_input.text:
		file_changed.emit()
		_last_file_name = file_name_input.text

func set_load_path(path:String):
	file_path_input.text = path.get_base_dir()
	file_path_input.caret_column = file_path_input.text.length()
	_last_file_path = file_path_input.text
	file_name_input.text = path.get_file()
	_last_file_name = file_name_input.text

func _fix_file_name():
	if not file_name_input.text.ends_with(".json"):
		file_name_input.text += ".json"

func get_load_path():
	return file_path_input.text

func get_full_fill_path():
	return file_path_input.text.path_join(file_name_input.text)

func on_load():
	var full_file_path = file_path_input.text.path_join(file_name_input.text)
	if FileAccess.file_exists(full_file_path):
		var actions = ActionLibrary.parse_actions_from_file(full_file_path)
		
func on_save():
	if parent_edit_control:
		parent_edit_control.save_data()

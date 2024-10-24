@tool
class_name FileSubEditorContainer
extends BaseSubEditorContainer

@export var file_path_line_edit:LineEdit
@export var file_name_line_edit:LineEdit
@export var open_file_button:Button
@export var save_file_button:Button
@export var file_dialog:FileDialog

@export var quick_file_option_button:LoadedOptionButton
@export var edit_object_option_button:LoadedOptionButton

var _cached_files:Array = []

func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	edit_object_option_button.get_options_func = get_edit_selection_options
	edit_object_option_button.item_selected.connect(on_edit_selection_selected)
	quick_file_option_button.get_options_func = get_file_options
	quick_file_option_button.item_selected.connect(on_file_option_selected)
	save_file_button.pressed.connect(on_save_file_button)
	open_file_button.pressed.connect(on_open_file_button)
	file_dialog.file_selected.connect(on_dialog_file_selected)
	file_dialog.dir_selected.connect(on_dialog_dir_selected)

func lose_focus_if_has():
	if file_name_line_edit.has_focus():
		file_name_line_edit.release_focus()
	if file_path_line_edit.has_focus():
		file_path_line_edit.release_focus()

func set_current_file(full_path:String):
	file_path_line_edit.text = full_path.get_base_dir()
	file_name_line_edit.text = full_path.get_file()

func set_editing_oject(key:String):
	edit_object_option_button.load_options(key)

func get_save_path()->String:
	if file_path_line_edit.text == "" or file_name_line_edit.text == "":
		return ""
	var file_path = file_path_line_edit.text
	var file_name = file_name_line_edit.text
	if !file_name.ends_with(root_editor_control.object_file_sufux):
		file_name = file_name.substr(0, file_name.length() - file_name.find('.'))
		file_name = file_name + root_editor_control.object_file_sufux
	return file_path.path_join(file_name)



func on_dialog_dir_selected(full_path):
	pass
func on_dialog_file_selected(full_path):
	if file_dialog.file_mode == FileDialog.FILE_MODE_OPEN_FILE:
		root_editor_control.load_file(full_path)


func get_edit_selection_options()->Array:
	return root_editor_control.get_editable_object_options()
func on_edit_selection_selected(index:int):
	var object_key = edit_object_option_button.get_current_option_text()
	root_editor_control.on_editable_object_selected(object_key)

func get_file_options()->Array:
	if _cached_files.size() == 0:
		_cached_files = root_editor_control.search_for_files(root_editor_control.BASE_DATA_DIR, root_editor_control.object_file_sufux)
	return _cached_files
func on_file_option_selected(index:int):
	var file_path = quick_file_option_button.get_current_option_text()
	root_editor_control.load_file(file_path)

func get_current_directory()->String:
	return file_path_line_edit.text

func on_open_file_button():
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	if file_path_line_edit.text != "":
		file_dialog.current_path = file_path_line_edit.text.path_join("")
	else:
		file_dialog.current_path = root_editor_control.BASE_DATA_DIR.path_join("")
	file_dialog.clear_filters()
	file_dialog.add_filter("*"+root_editor_control.object_file_sufux)
	file_dialog.popup_centered_ratio()

func on_save_file_button():
	root_editor_control.save_file()

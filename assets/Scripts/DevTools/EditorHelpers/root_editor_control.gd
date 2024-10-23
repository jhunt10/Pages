@tool
class_name RootEditorControler
extends BackPatchContainer

const BASE_DATA_DIR = "res://data"

static var Instance:RootEditorControler

@export var exit_button:Button
@export var file_path_line_edit:LineEdit
@export var file_name_line_edit:LineEdit
@export var open_file_button:Button
@export var save_file_button:Button
@export var load_file_button:Button

@export var quick_load_option_button:LoadedOptionButton
@export var edit_selection_option_button:LoadedOptionButton

@export var details_editor_control:DetailsEditorContainer

var object_file_sufux = ".json"
var object_key_name = "SOMETHING_Key"

var _cached_files = []
var _editing_file_datas:Dictionary = {}
var _editing_object_key:String = ''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint(): return
	if !Instance: Instance = self
	elif Instance != self: 
		printerr("Multiple RootEditControler Instance")
		queue_free()
	quick_load_option_button.get_options_func = get_quick_select_file_options
	quick_load_option_button.item_selected.connect(on_quick_select_file_selected)
	quick_load_option_button.load_options()
	edit_selection_option_button.get_options_func = get_edit_selection_options
	edit_selection_option_button.item_selected.connect(on_edit_selection_selected)
	edit_selection_option_button.load_options()
	
	save_file_button.pressed.connect(save_file)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	if Engine.is_editor_hint(): return
	pass

func get_keys_to_subeditor_mapping()->Dictionary:
	return {
		"Details": details_editor_control
	}

func load_file(full_path:String, selected_object=''):
	file_path_line_edit.text = full_path.get_base_dir()
	file_name_line_edit.text = full_path.get_file()
	_editing_file_datas = parse_datas_from_file(full_path)
	edit_selection_option_button.load_options(selected_object)
	if selected_object != '':
		load_object_data(selected_object)

func save_file():
	var file_path = file_path_line_edit.text
	var file_name = file_name_line_edit.text
	var full_path = file_path.path_join(file_name)
	var saving_object_key = details_editor_control.object_key_line_edit.text
	var data = {object_key_name: saving_object_key}
	print(data)

func load_object_data(object_key:String):
	if !_editing_file_datas.keys().has(object_key):
		_editing_object_key = ''
		printerr("No Object found with key: '%s'." % [object_key])
		return
	_editing_object_key = object_key
	var active_data = _editing_file_datas[_editing_object_key]
	var mappings = get_keys_to_subeditor_mapping()
	for key in mappings:
		var sub_editor:BaseSubEditorContainer = mappings[key]
		sub_editor.load_data(_editing_object_key, active_data.get(key, active_data))

## Save current object to _editing_file_datas
func save_object_data():
	var saving_object_key = details_editor_control.object_key_line_edit.text
	if saving_object_key == _editing_object_key:
		# TODO: check for change
		var t = true
	_editing_file_datas[saving_object_key] = _build_active_object_save_data(saving_object_key)

## Build data dict for the object currently being edited
func _build_active_object_save_data(object_key:String):
	var data = {object_key_name: object_key}
	var mappings = get_keys_to_subeditor_mapping()
	for key in mappings:
		var sub_editor:BaseSubEditorContainer = mappings[key]
		data[key] = sub_editor.build_save_data()
	return data

##### Top Dropdown Mothods #####################################################
func get_edit_selection_options()->Array:
	return _editing_file_datas.keys()
func on_edit_selection_selected(index:int):
	var object_key = edit_selection_option_button.get_current_option_text()
	load_object_data(object_key)
func get_quick_select_file_options()->Array:
	if _cached_files.size() == 0:
		_cached_files = search_for_files(BASE_DATA_DIR, object_file_sufux)
	return _cached_files
func on_quick_select_file_selected(index:int):
	var file_path = quick_load_option_button.get_current_option_text()
	load_file(file_path)
################################################################################

func get_current_directory()->String:
	return file_path_line_edit.text

func search_current_directory(sufix:String)->Array:
	var files = search_for_files(file_path_line_edit.text, sufix)
	return files

static func search_for_files(path:String, sufix:String)->Array:
	var list = []
	_rec_search_for_files(path, sufix, list)
	return list
	
static func _rec_search_for_files(path:String, sufix:String, list:Array, limit:int=1000):
	var dir = DirAccess.open(path)
	if limit == 0:
		printerr("RootEditorControler._rec_search_for_files: Search limit reached!")
		return
	if dir:
		dir.list_dir_begin()
		var file_name:String = dir.get_next()
		while file_name != "":
			var full_path = path+"/"+file_name
			if dir.current_is_dir():
				_rec_search_for_files(full_path, sufix, list, limit-1)
			elif file_name.ends_with(sufix):
				list.append(full_path)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func parse_datas_from_file(path:String)->Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	var text:String = file.get_as_text()
	
	# Wrap in brackets to support multiple actions in same file
	if !text.begins_with("["):
		text = "[" + text + "]" 
	var dict = {}
	var datas = JSON.parse_string(text)
	for data in datas:
		var object_key = data.get(object_key_name, '')
		if object_key != '' and !dict.keys().has(object_key):
			dict[data[object_key_name]] = data
	return dict

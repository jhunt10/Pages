@tool
class_name RootEditorControler
extends BackPatchContainer

const BASE_DATA_DIR = "res://defs"

static var Instance:RootEditorControler

signal edit_entry_key_changed(editor_key:String, old_key:String, new_key:String)

@export var exit_button:Button
@export var details_editor_control:DetailsEditorContainer
@export var file_subeitor_container:FileSubEditorContainer

var object_file_sufux = ".json"
var object_key_name = "SOMETHING_Key"

var _cached_files = []
var _editing_objects_datas:Dictionary = {}
var _changed_object_keys:Array = []
var _editing_object_key:String = ''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint(): return
	if !Instance: Instance = self
	elif Instance != self: 
		printerr("Multiple RootEditControler Instance")
		queue_free()
	exit_button.pressed.connect(on_exit_menu)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	if Engine.is_editor_hint(): return
	pass


func _input(event: InputEvent) -> void:
	if event is InputEventKey and (event as InputEventKey).keycode == KEY_ENTER:
		lose_focus_if_has()
	if event is InputEventKey and (event as InputEventKey).keycode == KEY_ESCAPE:
		on_exit_menu()

func lose_focus_if_has():
	for subeditor:BaseSubEditorContainer in get_keys_to_subeditor_mapping().values():
		subeditor.lose_focus_if_has()

func clear():
	_editing_object_key = ''
	for sub:BaseSubEditorContainer in get_keys_to_subeditor_mapping().values():
		sub.set_show_change(false)
		sub.clear()

func get_keys_to_subeditor_mapping()->Dictionary:
	return {
		"Details": details_editor_control
	}

## Returns the property keys of a subeditor. Used to get things like DamageDatas.
func get_subeditor_option_keys(key:String)->Array:
	var subeditors = get_keys_to_subeditor_mapping()
	var subeditor:BaseSubEditorContainer = subeditors.get(key)
	if !subeditor:
		printerr("%s.get_subeditor_option_keys:Failed to find subeditor '%s'." % [self.name, key])
		return []
	return subeditor.get_option_keys()

func on_exit_menu():
	Instance = null
	self.queue_free()
	#print(_editing_objects_datas)
	pass

func load_file(full_path:String, selected_object=''):
	clear()
	_changed_object_keys.clear()
	file_subeitor_container.set_current_file(full_path)
	_editing_objects_datas = parse_datas_from_file(full_path)
	file_subeitor_container.set_editing_oject(selected_object)
	if selected_object != '':
		load_object_data(selected_object)

func save_file(override:bool = false):
	save_object_data()
	var full_path:String = file_subeitor_container.get_save_path()
	if full_path == "":
		printerr("%s.save_file: Invalid file_path.")
		return
	
	if !override and FileAccess.file_exists(full_path):
		var yes_no_popup:YesNoPopupContainer = load("res://Scenes/Editors/SharedSubEditors/yesno_popup_container.tscn").instantiate()
		yes_no_popup.set_message_and_funcs("File '%s' already exists.\nOverwrite saved file?" % [full_path], save_file.bind(true), null)
		self.add_child(yes_no_popup)
		return
	
	var save_data = JSON.stringify(_editing_objects_datas.values())
	var file = FileAccess.open(full_path, FileAccess.WRITE)
	file.store_string(save_data)
	file.close()
	_changed_object_keys.clear()
	file_subeitor_container.quick_file_option_button.load_options(full_path)
	load_file(full_path, _editing_object_key)




func get_editable_object_options()->Array:
	var out_list = []
	for key in _editing_objects_datas.keys():
		if _changed_object_keys.has(key):
			out_list.append('*'+key)
		else:
			out_list.append(key)
	return out_list

func on_editable_object_selected(object_key:String):
	if object_key.begins_with("*"):
		object_key = object_key.trim_prefix("*")
	if _editing_object_key != "":
		if _check_active_object_for_change():
			var yes_no_popup:YesNoPopupContainer = load("res://Scenes/Editors/SharedSubEditors/yesno_popup_container.tscn").instantiate()
			yes_no_popup.set_message_and_funcs(
				"Save changes to %s?" % [_editing_object_key], 
				load_object_data.bind(object_key, true), 
				load_object_data.bind(object_key, false))
			self.add_child(yes_no_popup)
			return
	load_object_data(object_key, false)

func load_object_data(object_key:String, save_current=false):
	if save_current:
		save_object_data()
	clear()
	if !_editing_objects_datas.keys().has(object_key):
		_editing_object_key = ''
		printerr("No Object found with key: '%s'." % [object_key])
		return
	_editing_object_key = object_key
	details_editor_control.set_object_key(_editing_object_key)
	var active_data = _editing_objects_datas[_editing_object_key]
	var mappings = get_keys_to_subeditor_mapping()
	for key in mappings:
		var sub_editor:BaseSubEditorContainer = mappings[key]
		var default = {}
		if key == "Details": # Hack for importing old files
			default = active_data
		sub_editor.load_data(key, active_data.get(key, default))

## Save current object to _editing_objects_datas
func save_object_data():
	var saving_object_key = details_editor_control.get_object_key()
	if saving_object_key == _editing_object_key:
		var changed = _check_active_object_for_change()
		if !changed:
			printerr("%s.save_object_data: No Change" % self.name)
			return
	_editing_objects_datas[saving_object_key] = _build_active_object_save_data(saving_object_key)
	_changed_object_keys.append(saving_object_key)
	_editing_object_key = saving_object_key

func _check_active_object_for_change():
	var mappings = get_keys_to_subeditor_mapping()
	var found_change = false
	for key in mappings:
		var sub_editor:BaseSubEditorContainer = mappings[key]
		if sub_editor.has_change():
			sub_editor.set_show_change(true)
			print("Change found in '%s'" % [sub_editor.name])
			found_change = true
	return found_change
	

## Build data dict for the object currently being edited
func _build_active_object_save_data(object_key:String):
	var data = {object_key_name: object_key}
	var mappings = get_keys_to_subeditor_mapping()
	for key in mappings:
		var sub_editor = mappings[key]
		data[key] = sub_editor.build_save_data()
	return data

func get_current_directory():
	return file_subeitor_container.get_current_directory()

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

func search_current_directory(sufix:String, recursive:bool = true)->Array:
	var files = []
	_rec_search_for_files(get_current_directory(), sufix, files, recursive)
	return files

static func search_for_files(path:String, sufix:String)->Array:
	var list = []
	_rec_search_for_files(path, sufix, list)
	return list
	
static func _rec_search_for_files(path:String, sufix:String, list:Array, recursive:bool=true, limit:int=1000):
	var dir = DirAccess.open(path)
	if limit == 0:
		printerr("RootEditorControler._rec_search_for_files: Search limit reached!")
		return
	if dir:
		dir.list_dir_begin()
		var file_name:String = dir.get_next()
		while file_name != "":
			var full_path = path+"/"+file_name
			if dir.current_is_dir() and recursive:
				_rec_search_for_files(full_path, sufix, list, limit-1)
			elif file_name.ends_with(sufix):
				list.append(full_path)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path: %s" % [path])

@tool
class_name SubActionSubEditorControl
extends BaseSubEditorContainer

@export var add_option_button:LoadedOptionButton
@export var premade_subaction_edit_entry:SubActionEditEntryContainer
@export var subaction_entry_container:VBoxContainer

static var SUB_ACTIONS_PATH = "res://assets/Scripts/Actions/SubActions/"

var _cached_scripts:Dictionary = {}
var _subaction_scripts:Dictionary:
	get:
		if _cached_scripts.size() == 0:
			var list = get_sub_actions_scripts()
			for path in list:
				var name = path.get_file().trim_prefix("SubAct_").trim_suffix(".gd")
				_cached_scripts[name] = path
		return _cached_scripts

func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	premade_subaction_edit_entry.visible = false
	add_option_button.get_options_func = get_add_options
	add_option_button.item_selected.connect(on_add_option_selected)
	
func lose_focus_if_has():
	for subaction_entry:SubActionEditEntryContainer in subaction_entry_container.get_children():
		subaction_entry.lose_focus_if_has()

func has_change():
	for subaction_entry:SubActionEditEntryContainer in subaction_entry_container.get_children():
		if subaction_entry.has_change():
			return true
	return false

func load_data(object_key:String, data:Dictionary):
	_loaded_data = data
	for index in data.keys():
		var subaction_datas_arr = data[index]
		for subaction_data in subaction_datas_arr:
			create_new_subaction_entry(index, subaction_data)
	_order_entries()

func create_new_subaction_entry(index, data):
	var new_entry:SubActionEditEntryContainer = premade_subaction_edit_entry.duplicate()
	subaction_entry_container.add_child(new_entry)
	new_entry.visible = true
	new_entry.frame_spin_box.set_value_no_signal(int(index))
	new_entry.on_frame_changed.connect(_order_entries)
	new_entry.load_data("", data)

func build_save_data()->Dictionary:
	var dict = {}
	for subaction_entry:SubActionEditEntryContainer in subaction_entry_container.get_children():
		var frame = subaction_entry.frame_spin_box.value
		if !dict.keys().has(frame):
			dict[frame] = []
		dict[frame].append(subaction_entry.build_save_data())
	return dict

func get_add_options()->Array:
	return _subaction_scripts.keys()

func on_add_option_selected(val):
	var script_name = add_option_button.get_current_option_text()
	if script_name == add_option_button.no_option_text:
		return
	add_option_button.selected = 0
	var data = {"SubActionScript": _subaction_scripts[script_name]}
	create_new_subaction_entry(0, data)
	_order_entries()

func _order_entries():
	var list = []
	for child in subaction_entry_container.get_children():
		list.append(child)
		subaction_entry_container.remove_child(child)
	for index in range(ActionQueController.FRAMES_PER_ACTION):
		for subaction_entry:SubActionEditEntryContainer in list:
			if index == subaction_entry.frame_spin_box.value:
				subaction_entry_container.add_child(subaction_entry)

static func get_sub_actions_scripts():
	var list = []
	if MainRootNode.action_library.loaded:
		_search_for_actions(SUB_ACTIONS_PATH, list)
	else:
		printerr("SubActionEntryControl.get_sub_actions_scripts: Actions not loaded")
	return list

static func _search_for_actions(path, list):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file:String = dir.get_next()
		while file != "":
			var full_path = path+file
			if dir.current_is_dir(): _search_for_actions(full_path, list)
			elif file.begins_with("SubAct_") and file.ends_with(".gd"): 
				list.append(full_path)
			file = dir.get_next()

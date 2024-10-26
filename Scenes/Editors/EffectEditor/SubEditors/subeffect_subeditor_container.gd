@tool
class_name SubEffectSubEditorContainer
extends BaseListSubEditorConatiner

static var SUB_EFFECT_PATH = "res://assets/Scripts/Actors/Effects/SubEffects/"

@export var add_option_button:LoadedOptionButton

var _cached_scripts:Dictionary = {}
var _subeffect_scripts:Dictionary:
	get:
		if _cached_scripts.size() == 0:
			var list = get_sub_actions_scripts()
			for path in list:
				var name = path.get_file().trim_prefix("SubEffect_").trim_suffix(".gd")
				_cached_scripts[name] = path
		return _cached_scripts

func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	add_option_button.get_options_func = get_add_options
	add_option_button.item_selected.connect(on_item_selected)

func get_add_options()->Array:
	return _subeffect_scripts.keys()

func on_item_selected(index):
	var key = add_option_button.get_current_option_text()
	if _subeffect_scripts.keys().has(key):
		var data = {"SubEffectScript": _subeffect_scripts[key]}
		var new_key = _make_new_key(key)
		create_new_entry(new_key, data)
	add_option_button.load_options("Add")

func _make_new_key(script_name):
	var existing_keys = get_key_to_input_mapping().keys()
	var index = 0
	for key:String in existing_keys:
		if key.begins_with(script_name):
			index += 1
	if index > 0:
		return script_name + str(index)
	else:
		return script_name

static func get_sub_actions_scripts():
	var list = []
	if MainRootNode.action_library.loaded:
		_search_for_actions(SUB_EFFECT_PATH, list)
	else:
		printerr("SubEffectSubEditorContainer.get_sub_actions_scripts: Effect not loaded")
	return list

static func _search_for_actions(path, list):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file:String = dir.get_next()
		while file != "":
			var full_path = path+file
			if dir.current_is_dir(): _search_for_actions(full_path, list)
			elif file.begins_with("SubEffect_") and file.ends_with(".gd"): 
				list.append(full_path)
			file = dir.get_next()

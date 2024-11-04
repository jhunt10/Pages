class_name ActionLibrary
extends BaseLoadObjectLibrary

const NO_ICON_SPRITE = "res://assets/Sprites/BadSprite.png"

## All Libraries should be static, but static override methods can't be called by BaseLoadObjectLibrary.
## So this is the work around.
static var Instance:ActionLibrary

static var _cached_icon_sprites : Dictionary = {}
static var _cached_subaction_scripts:Dictionary = {}

func get_object_name()->String:
	return 'Action'
func get_object_key_name()->String:
	return "ActionKey"
func get_def_file_sufix()->String:
	return "_Pages.json"
func get_data_file_sufix()->String:
	return "_Pages.json"
func is_object_static(object_def:Dictionary)->bool:
	return true
func get_object_script_path(object_def:Dictionary)->String:
	return "res://assets/Scripts/Actions/BaseAction.gd"

func _init() -> void:
	if Instance != null:
		printerr("Multiple ActionLibrarys created.")
		return
	Instance = self
	Instance.init_load()

static func list_all_actions()->Array:
	return Instance._loaded_objects.values()

static func get_action_def(key:String)->Dictionary:
	return Instance.get_object_def(key)
	
static func get_action(action_key:String)->BaseAction:
	var action = Instance.get_object(action_key)
	if !action:
		printerr("ActionLibrary.get_action: No item found with id '%s'." % [action_key])
	return action


const TILE_WIDTH = 64
const TILE_HIGHT = 56
const ActionDir = "res://data/Actions"


#func load_pages():
	#if loaded:
		#return
	#print("### Loading Actions")
	#_cached_icon_sprites[NO_ICON_SPRITE] = get_action_icon(NO_ICON_SPRITE)
	#for file in search_for_action_files():
		#print('# Checking File: ' + file)
		#var actions_dicts = parse_actions_from_file(file)
		#for act_key in actions_dicts.keys():
			#_action_list[act_key] = actions_dicts[act_key]
			#print("# -Loaded Action: " + act_key)
	#print("### Done Loading Actions")
	#loaded = true
	
#func reload_pages():
	#_action_list.clear()
	#_cached_icon_sprites.clear()
	#loaded = false
	#load_pages()

static func get_action_icon(file_path:String):
	if _cached_icon_sprites.keys().has(file_path):
		return _cached_icon_sprites[file_path]
	if FileAccess.file_exists(file_path):
		var sprite = load(file_path)
		_cached_icon_sprites[file_path] = sprite
		return sprite
	return _cached_icon_sprites[NO_ICON_SPRITE]

static func get_sub_action_script(script_path)->BaseSubAction:
	if _cached_subaction_scripts.keys().has(script_path):
		return _cached_subaction_scripts[script_path]
	var script = load(script_path)
	if not script:
		printerr("ActionLibrary.get_sub_action_script: No script found with name '%s'." % [script_path])
		return null
	var sub_action = script.new()
	_cached_subaction_scripts[script_path] = sub_action
	return sub_action

# Get a static instance of the action
#func get_action(key:String)->BaseAction:
	#if !loaded:
		#printerr("Attepted to get Action before loading: " + key)
	#if _action_list.has(key):
		#return _action_list[key]
	#return null
	
static func search_for_action_files()->Array:
	var list = []
	_rec_search_for_actions(ActionDir, list)
	return list
	
static func _rec_search_for_actions(path:String, list:Array, limit:int=1000):
	var dir = DirAccess.open(path)
	if limit == 0:
		printerr("ActionLibrary._rec_search_for_actions: Search limit reached!")
		return
	if dir:
		dir.list_dir_begin()
		var file_name:String = dir.get_next()
		while file_name != "":
			var full_path = path+"/"+file_name
			if dir.current_is_dir():
				_rec_search_for_actions(full_path, list, limit-1)
			elif file_name.ends_with(".json"):
				list.append(full_path)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path: %s" % [path])

#static func parse_actions_from_file(path:String)->Dictionary:
	#var datas = parse_action_datas_from_file(path)
	#var dict = {}
	#for data in datas.values():
		#var action = BaseAction.new(path, data)
		#dict[action.ActionKey] = action
	#return dict
	

#static func parse_action_datas_from_file(path:String)->Dictionary:
	#var file = FileAccess.open(path, FileAccess.READ)
	#var text:String = file.get_as_text()
	#
	## Wrap in brackets to support multiple actions in same file
	#if !text.begins_with("["):
		#text = "[" + text + "]" 
	#var dict = {}
	#var action_datas = JSON.parse_string(text)
	#for action_data in action_datas:
		#if !dict.has(action_data['ActionKey']):
			#dict[action_data['ActionKey']] = action_data
	#return dict

#func create_page(keyName : String) -> PageAction:
	#var script = action_scripts[keyName]
	#var newObj = script.new(action_data[keyName])
	#return newObj
#
#func create_gap_action():
	#var dic = {KeyName:GapActionKeyName}
	#var gap = PageAction.new(dic)
	#return gap
#
#func get_image(key_name) -> Texture2D:
	#if loaded_sprites.has(key_name):
		#return loaded_sprites[key_name]
	#return missing_image
	
	

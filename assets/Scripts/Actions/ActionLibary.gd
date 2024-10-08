class_name ActionLibary

const TILE_WIDTH = 64
const TILE_HIGHT = 56

const ActionDir = "res://data/Actions"

var _action_list:Dictionary = {}

var loaded = false
var loaded_sprites : Dictionary = {}

func _init() -> void:
	self.load_pages()

func load_pages():
	if loaded:
		return
	print("### Loading Actions")
	for file in search_for_action_files():
		print('# Checking File: ' + file)
		var actions_dicts = parse_actions_from_file(file)
		for act_key in actions_dicts.keys():
			_action_list[act_key] = actions_dicts[act_key]
			print("# -Loaded Action: " + act_key)
	print("### Done Loading Actions")
	loaded = true
	
func reload_pages():
	_action_list.clear()
	loaded_sprites.clear()
	loaded = false
	load_pages()
	
# Get a static instance of the action
func get_action(key:String)->BaseAction:
	if !loaded:
		printerr("Attepted to get Action before loading: " + key)
	if _action_list.has(key):
		return _action_list[key]
	return null
	
static func search_for_action_files()->Array:
	var list = []
	_rec_search_for_actions(ActionDir, list)
	return list
	
static func _rec_search_for_actions(path:String, list:Array, limit:int=1000):
	var dir = DirAccess.open(path)
	if limit == 0:
		printerr("ActionLibary._rec_search_for_actions: Search limit reached!")
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
		print("An error occurred when trying to access the path.")

static func parse_actions_from_file(path:String)->Dictionary:
	var datas = parse_action_datas_from_file(path)
	var dict = {}
	for data in datas.values():
		var action = BaseAction.new(path, data)
		dict[action.ActionKey] = action
	return dict
	

static func parse_action_datas_from_file(path:String)->Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	var text:String = file.get_as_text()
	
	# Wrap in brackets to support multiple actions in same file
	if !text.begins_with("["):
		text = "[" + text + "]" 
	var dict = {}
	var action_datas = JSON.parse_string(text)
	for action_data in action_datas:
		if !dict.has(action_data['ActionKey']):
			dict[action_data['ActionKey']] = action_data
	return dict

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
	
	

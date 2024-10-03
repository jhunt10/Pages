class_name ActionLibary

const TILE_WIDTH = 64
const TILE_HIGHT = 56

const ActionDir = "res://data/Actions/"

var _action_list:Dictionary = {}

var loaded = false
var loaded_sprites : Dictionary = {}

func _init() -> void:
	self.load_pages()

func load_pages():
	if loaded:
		return
	print("Loading Actions")
	var files = []
	_search_for_actions(ActionDir, files)
	for file in files:
		_load_action_file(file)
	loaded = true
	
# Get a static instance of the action
func get_action(key:String)->BaseAction:
	if !loaded:
		printerr("Attepted to get Action before loading: " + key)
	if _action_list.has(key):
		return _action_list[key]
	return null
	
func _search_for_actions(path:String, list:Array):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name:String = dir.get_next()
		while file_name != "":
			var full_path = path+"/"+file_name
			if dir.current_is_dir():
				_search_for_actions(full_path, list)
			elif file_name.ends_with(".json"):
				list.append(full_path)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func _load_action_file(path:String):
	var file = FileAccess.open(path, FileAccess.READ)
	var text:String = file.get_as_text()
	
	# Wrap in brackets to support multiple actions in same file
	if !text.begins_with("["):
		text = "[" + text + "]" 
		
	var action_datas = JSON.parse_string(text)
	for action_data in action_datas:
		var newAction = BaseAction.new(path.get_base_dir(), action_data)
		if !_action_list.has(newAction.ActionKey):
			_action_list[newAction.ActionKey] = newAction
			print("Loaded Action: " + newAction.ActionKey)

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
	
	

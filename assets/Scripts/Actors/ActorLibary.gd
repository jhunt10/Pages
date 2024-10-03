class_name ActorLibary

const ActorDir = "res://data/Actors/"
const _default_corpse_texture_path = "res://assets/Sprites/Actors/DefaultCorpse.png"

# Dictionary of actor's base data config
var _actors_data:Dictionary = {}

var loaded = false
var loaded_sprites : Dictionary = {}

func _init() -> void:
	self.load_actors_data()

func load_actors_data():
	if loaded:
		return
	print("Loading Actors")
	var files = []
	_search_for_actors(ActorDir, files)
	for file in files:
		_load_actor_file(file)
	loaded = true
	
# Get a static instance of the action
func get_actor_data(key:String)->Dictionary:
	if !loaded:
		printerr("Attepted to get Action before loading: " + key)
	if _actors_data.has(key):
		return _actors_data[key]
	return {}
	
func _search_for_actors(path:String, list:Array):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name:String = dir.get_next()
		while file_name != "":
			var full_path = path+"/"+file_name
			if dir.current_is_dir():
				_search_for_actors(full_path, list)
			elif file_name.ends_with(".json"):
				list.append(full_path)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func _load_actor_file(path:String):
	var file = FileAccess.open(path, FileAccess.READ)
	var text:String = file.get_as_text()
	
	# Wrap in brackets to support multiple actions in same file
	if !text.begins_with("["):
		text = "[" + text + "]" 
		
	var actor_datas = JSON.parse_string(text)
	for data in actor_datas:
		data['LoadPath'] = path.get_base_dir()
		_actors_data[data['ActorKey']] = data
		print("Loaded Actor: " + data['ActorKey'])

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
	
func get_default_corpse_texture()->Texture2D:
	return load(_default_corpse_texture_path)

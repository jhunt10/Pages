class_name EffectLibary

const EffectDir = "res://data/Effects/"

# Dictionary of effect's base data config
var _effects_data:Dictionary = {}

var loaded = false
var loaded_sprites : Dictionary = {}

func _init() -> void:
	self.load_effects_data()

func load_effects_data():
	if loaded:
		return
	print("Loading Effects")
	var files = []
	_search_for_effects(EffectDir, files)
	for file in files:
		_load_effect_file(file)
	loaded = true
	
func get_effect_data(key:String):
	if _effects_data.has(key):
		return _effects_data[key]
	return {}
	
# Get a static instance of the action
func create_new_effect(key:String, actor:BaseActor, data:Dictionary)->BaseEffect:
	if !loaded:
		printerr("Attepted to get Effect before loading: " + key)
	var effect_data = _effects_data[key]
	var script = load(effect_data['EffectScript'])
	if !script:
		printerr("Failed to find effect script: " + effect_data['EffectScript'])
		return null
		
	var merged_data = {}
	for k in effect_data.keys():
		merged_data[k] = effect_data[k]
	for k in data.keys():
		merged_data[k] = data[k]
		
	var new_effect:BaseEffect = script.new(actor, merged_data)
	return new_effect
	
func _search_for_effects(path:String, list:Array):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name:String = dir.get_next()
		while file_name != "":
			var full_path = path+"/"+file_name
			if dir.current_is_dir():
				_search_for_effects(full_path, list)
			elif file_name.ends_with(".json"):
				list.append(full_path)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func _load_effect_file(path:String):
	var file = FileAccess.open(path, FileAccess.READ)
	var text:String = file.get_as_text()
	
	# Wrap in brackets to support multiple actions in same file
	if !text.begins_with("["):
		text = "[" + text + "]" 
		
	var effect_datas = JSON.parse_string(text)
	for data in effect_datas:
		data['LoadPath'] = path.get_base_dir()
		_effects_data[data['EffectKey']] = data
		print("Loaded Effect: " + data['EffectKey'])

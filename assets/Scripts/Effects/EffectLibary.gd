class_name EffectLibary

const EffectDir = "res://data/Effects/"

# Dictionary of effect's base data config
var _effects_data:Dictionary = {}

static var _cached_subeffects:Dictionary = {}

var loaded = false
var loaded_sprites : Dictionary = {}

func _init() -> void:
	self.load_effects_data()

func load_effects_data():
	if loaded:
		return
	print("### Loading Effects")
	for file in search_for_effect_files():
		print('# Checking File: ' + file)
		var effects_dicts = parse_effect_datas_from_file(file)
		for effect_key in effects_dicts.keys():
			_effects_data[effect_key] = effects_dicts[effect_key]
			print("# -Loaded Effect: " + effect_key	)
	print("### Done Loading Effects")
	loaded = true
	
func reload_effects():
	_effects_data.clear()
	loaded_sprites.clear()
	loaded = false
	load_effects_data()
	
func get_effect_data(key:String):
	if _effects_data.has(key):
		return _effects_data[key]
	return {}
	
# Get a static instance of the effect
func create_new_effect(key:String, actor:BaseActor, data:Dictionary)->BaseEffect:
	if !loaded:
		printerr("Attepted to get Effect before loading: " + key)
	var effect_data = _effects_data[key]
	var merged_data = {}
	for k in effect_data.keys():
		merged_data[k] = effect_data[k]
	for k in data.keys():
		merged_data[k] = data[k]
		
	var new_effect:BaseEffect = BaseEffect.new(actor, merged_data)
	return new_effect
	
static func get_sub_effect_script(script_path)->BaseSubEffect:
	if _cached_subeffects.keys().has(script_path):
		return _cached_subeffects[script_path]
	var script = load(script_path)
	if not script:
		printerr("EffectLibrary.get_sub_effect_script: No script found with name '%s'." % [script_path])
	var subeffect = script.new()
	_cached_subeffects[script_path] = subeffect
	return subeffect
	
	
static func search_for_effect_files()->Array:
	var list = []
	_rec_search_for_effects(EffectDir, list)
	return list
	
static func _rec_search_for_effects(path:String, list:Array, limit:int=1000):
	var dir = DirAccess.open(path)
	if limit == 0:
		printerr("EffectLibary._rec_search_for_effect: Search limit reached!")
		return
	if dir:
		dir.list_dir_begin()
		var file_name:String = dir.get_next()
		while file_name != "":
			var full_path = path+"/"+file_name
			if dir.current_is_dir():
				_rec_search_for_effects(full_path, list, limit-1)
			elif file_name.ends_with(".json"):
				list.append(full_path)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

static func parse_effect_datas_from_file(path:String)->Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	var text:String = file.get_as_text()
	
	# Wrap in brackets to support multiple effects in same file
	if !text.begins_with("["):
		text = "[" + text + "]" 
	var dict = {}
	var effect_datas = JSON.parse_string(text)
	for effect_data in effect_datas:
		if !dict.has(effect_data['EffectKey']):
			effect_data['LoadPath'] = path.get_base_dir()
			dict[effect_data['EffectKey']] = effect_data
	return dict

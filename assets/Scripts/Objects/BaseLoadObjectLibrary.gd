class_name BaseLoadObjectLibrary

const OBJECTS_DEFS_DIR = "res://data/"

# Dictionary of object's base data config
static var _object_defs:Dictionary = {}
# Cache of static control scripts (Like SubAction and SubEffects)
static var _cached_scripts:Dictionary = {}
# Cache of static object instances
static var _cached_objects:Dictionary = {}

static var loaded = false
func _init() -> void:
	load_object_defs()



static func get_object_def(key:String):
	if _object_defs.has(key):
		return _object_defs[key]
	return {}

# Get static instance of static object
static func get_object(key)->StaticLoadObject:
	if !loaded:
		printerr("BaseLoadObjectLibrary.get_object: Attepted to get Object before loading: " + key)
		return null
	if not _cached_objects.keys().has(key):
		var object_def = _object_defs.get(key, null)
		if !object_def:
			printerr("BaseLoadObjectLibrary.get_object: No ObjectDef found with key '%s'.: " % [key])
			return null
		var script_path = object_def['ObjectScript']
		var script = load(script_path)
		if !script:
			printerr("BaseLoadObjectLibrary.get_object: Failed to find object script: " + script_path)
			return null
		if not script is StaticLoadObject:
			printerr("BaseLoadObjectLibrary.get_object: Object %s loaded script '%s' " + 
				"is not of type 'StaticLoadObject'." % [key, script_path]) 
		var load_path = object_def['LoadPath']
		_cached_objects[key] = script.new(key, load_path, object_def)
	return _cached_objects[key]

# Create a new instance of a saveable object
static func create_new_saveable_object(key:String, data:Dictionary)->SaveableLoadObject:
	if !loaded:
		printerr("BaseLoadObjectLibrary.create_new_saveable_object: Attepted to get Object before loading: " + key)
		return null
	var object_def = _object_defs.get(key, null)
	if !object_def:
		printerr("BaseLoadObjectLibrary.create_new_saveable_object: No ObjectDef found with key '%s'.: " % [key])
		return null
	var script_path = object_def['ObjectScript']
	var script = load(script_path)
	if !script:
		printerr("BaseLoadObjectLibrary.create_new_saveable_object: Failed to find object script: " + script_path)
		return null
	if not script is SaveableLoadObject:
		printerr("BaseLoadObjectLibrary.create_new_saveable_object: Object %s loaded script '%s' " + 
			"is not of type 'SaveableLoadObject'." % [key, script_path]) 
	var load_path = object_def['LoadPath']
	var new_object = script.new(key, load_path, object_def, data)
	return new_object



static func get_sub_script(script_path):
	if _cached_scripts.keys().has(script_path):
		return _cached_scripts[script_path]
	var script = load(script_path)
	if not script:
		printerr("BaseLoadObjectLibrary.get_object_script: No script found with name '%s'." % [script_path])
		return null
	var script_instance = script.new()
	_cached_scripts[script_path] = script_instance
	return script_instance



static func load_object_defs():
	if loaded:
		return
	print("Loading Objects")
	var files = []
	_search_for_objects(OBJECTS_DEFS_DIR, files)
	for file in files:
		_load_object_file(file)
	loaded = true

static func _load_object_file(path:String):
	var file = FileAccess.open(path, FileAccess.READ)
	var text:String = file.get_as_text()
	
	# Wrap in brackets to support multiple actions in same file
	if !text.begins_with("["):
		text = "[" + text + "]" 
		
	var object_defs = JSON.parse_string(text)
	for def in object_defs:
		def['LoadPath'] = path.get_base_dir()
		_object_defs[def['ObjectKey']] = def
		print("Loaded Object: " + def['ObjectKey'])

static func _search_for_objects(path:String, list:Array):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name:String = dir.get_next()
		while file_name != "":
			var full_path = path+"/"+file_name
			if dir.current_is_dir():
				_search_for_objects(full_path, list)
			elif file_name.ends_with(".json"):
				list.append(full_path)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

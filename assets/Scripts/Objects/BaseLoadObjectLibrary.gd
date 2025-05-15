class_name BaseLoadObjectLibrary

const LOGGING = true
const OBJECTS_DEFS_DIR = "res://defs/"
const OBJECTS_DATA_DIR = "res://saves/"

func get_object_name()->String:
	return 'Object'
func get_object_key_name()->String:
	return "ObjectKey"
func get_def_file_sufix()->String:
	return "_Object.json"
func get_data_file_sufix()->String:
	return "_Object.json"
func is_object_static(object_def:Dictionary)->bool:
	return object_def.get("IsStatic", false)
func get_object_script_path(object_def:Dictionary)->String:
	return object_def.get("_ObjectScript", "")

var loaded = false
# Dictionary of object's base data config
var _object_defs:Dictionary = {}
# Dictionary of object's key to the location it was loaded
var _defs_to_load_paths:Dictionary = {}
# Cache of static control scripts (Like SubAction and SubEffects)
var _cached_scripts:Dictionary = {}
# Cache of static object instances
var _static_objects:Dictionary = {}
# Collection of loaded objects by id
var _loaded_objects:Dictionary = {}


func get_object_def(key:String):
	if _object_defs.has(key):
		return _object_defs[key].duplicate(true)
	return {}

func get_object_def_load_path(key:String):
	return _defs_to_load_paths.get(key, null)

func get_object(id:String)->BaseLoadObject:
	if _static_objects.keys().has(id):
		return _static_objects[id]
	return _loaded_objects.get(id, null)

# Get static instance of static object
func get_static_object(key:String)->BaseLoadObject:
	if !loaded:
		printerr("%sLibrary.get_static_object: Attepted to get '%s' before loading" % [get_object_name(), key])
		return null
	if not _static_objects.keys().has(key):
		var new_object = create_object(key)
		if !new_object:
			printerr("%sLibrary.get_static_object: Failed to create object '%s'." % [get_object_name(), key])
			return null
		if !new_object.is_static():
			printerr("%sLibrary.get_static_object: '%s' is not a staic object." % [get_object_name(), key])
			return null
		_static_objects[key] = new_object
	return _static_objects[key]

func create_object(object_key:String, id:String='', data:Dictionary={})->BaseLoadObject:
	if id != '' and _loaded_objects.keys().has(id):
		printerr("%sLibrary.create_object: %s with id '%s' already exists.: " % [get_object_name(), id, object_key])
		return _loaded_objects[id]
	var object_def = _object_defs.get(object_key, null)
	if !object_def:
		printerr("%sLibrary.create_object: No ObjectDef found with key '%s'.: " % [get_object_name(), object_key])
		return null
	var script_path = get_object_script_path(object_def)
	if script_path == '':
		printerr("%sLibrary.get_object: No object script found on '%s'." % [get_object_name(), object_key])
		return null
	var script = load(script_path)
	if !script:
		printerr("%sLibrary.get_object: Failed to find object script '%s'." % [get_object_name(), script_path])
		return null
	var load_path = _defs_to_load_paths[object_key]
	var new_object:BaseLoadObject = script.new(object_key, load_path, object_def, id, data)
	if !new_object.is_static():
		_loaded_objects[new_object._id] = new_object
	return new_object

## Delete all loaded objects
func purge_objects():
	for obj_key in _loaded_objects.keys():
		var object = _loaded_objects[obj_key]
		var loaded_object:BaseLoadObject = object as BaseLoadObject
		if !loaded_object:
			printerr("Non-BaseLoadObject found with key: %s" % [obj_key])
		else:
			loaded_object.on_delete()
	_loaded_objects.clear()
	
func erase_object(object_id:String):
	if _loaded_objects.keys().has(object_id):
		if _loaded_objects.has(object_id):
			if not _loaded_objects[object_id].is_deleted:
				_loaded_objects[object_id].on_delete()
		_loaded_objects.erase(object_id)

func build_save_data()->Dictionary:
	var obj_datas:Dictionary = {}
	for object_id in _loaded_objects.keys():
		var object:BaseLoadObject = _loaded_objects[object_id]
		if object.save_me():
			var data = object.save_data()
			if LOGGING: print("# Saving %s Datas with id: %s" % [get_object_name(), object_id])
			obj_datas[object_id] = data
	return obj_datas

#func save_objects_data(file_path:String, extra_data={}):
	#if LOGGING: print("#### Saving %s Datas to: %s" % [get_object_name(), file_path])
	#var save_data = build_save_data(extra_data)
	#var save_data_string = JSON.stringify(save_data)
	#var file = FileAccess.open(file_path, FileAccess.WRITE)
	#file.store_string(save_data_string)
	#file.close()
	#if LOGGING: print("#### Saving %s Datas Done" % [get_object_name()])

func get_sub_script(script_path):
	if _cached_scripts.keys().has(script_path):
		return _cached_scripts[script_path]
	var script = load(script_path)
	if not script:
		printerr("%sLibrary.get_object_script: No script found with name '%s'." % [script_path])
		return null
	var script_instance = script.new()
	_cached_scripts[script_path] = script_instance
	return script_instance



func init_load():
	if loaded:
		return
	var obj_name = get_object_name()
	if LOGGING:
		print("")
		print("#### Loading %s" % [obj_name])
	
	_load_object_defs()
	
	
	# Load Static Objects
	if LOGGING: print("# Loading Static Objects" )
	_load_static_objects()
	
	# Load Objects
	#for object_file in _search_for_files(OBJECTS_DATA_DIR, get_data_file_sufix()):
		#if LOGGING: print("# Loading Save file: %s" % [object_file])
		#_load_objects_save_file(object_file)
	
	if LOGGING:
		print("#### DONE Loading %s" % [obj_name])
		print("")
	loaded = true


func reload():
	loaded = false
	_object_defs.clear()
	_defs_to_load_paths.clear()
	_static_objects.clear()
	_loaded_objects.clear()
	init_load()

func _load_object_defs():
	var delayed_defs = {}
	var paths = [OBJECTS_DEFS_DIR, 'res://ObjectDefs/']
	# Load Defs
	for path in paths:
		for def_file in _search_for_files(path, get_def_file_sufix()):
			if LOGGING: print("# Loading Def file: %s" % [def_file])
			var delayed = _load_object_def_file(def_file)
			for parent_key in delayed.keys():
				if not delayed_defs.keys().has(parent_key):
					delayed_defs[parent_key] = {}
				for child_key in delayed[parent_key]:
					delayed_defs[parent_key][child_key] = delayed[parent_key][child_key]
	
	var safety_limit = 100
	var safety_index = 0
	while delayed_defs.size() > 0 and safety_index <= safety_limit:
		for parent_key in delayed_defs.keys():
			if not _object_defs.keys().has(parent_key):
				print("Parent Def: %s not found" % [parent_key])
				continue
			var parent_def = _object_defs[parent_key]
			for child_key in delayed_defs[parent_key].keys():
				_object_defs[child_key] = _merge_defs(delayed_defs[parent_key][child_key], parent_def)
			delayed_defs.erase(parent_key)
		safety_index += 1
	if delayed_defs.size() > 0:
		printerr("Failed to load all inherited defs defs")
			

## Parse json def file and load to _object_defs and returns nest dicionaries of  parent key to child key to defs for child defs with non-loaded parents
func _load_object_def_file(file_path:String)->Dictionary:
	var file = FileAccess.open(file_path, FileAccess.READ)
	var text:String = file.get_as_text()
	var delayed_dic = {}
	# Wrap in brackets and parse as Array to support multiple objects in same file
	if !text.begins_with("["):
		text = "[" + text + "]" 
	var object_key_name = get_object_key_name()
	var object_defs:Array = JSON.parse_string(text)
	for def:Dictionary in object_defs:
		if !def.keys().has(object_key_name):
			printerr("No '%s' found on object in %s." % [object_key_name, file_path])
			continue
		var object_key = def[object_key_name]
		var parent_key = def.get("ParentKey", null)
		_defs_to_load_paths[object_key] = file_path.get_base_dir()
		if object_key == "TestChaser2":
			var t = true
		# Check if needs to wait for parent to be loaded
		if parent_key == null:
			_object_defs[object_key] = def
			if LOGGING: print("# - Loaded Object Def: %s" % [object_key])
		elif _object_defs.keys().has(parent_key):
			_object_defs[object_key] = _merge_defs(def, _object_defs[parent_key])
		else:
			if !delayed_dic.keys().has(parent_key):
				delayed_dic[parent_key] = {}
			delayed_dic[parent_key][object_key] = def
	return delayed_dic

## Search _object_defs and load static objects to _static_objects
func _load_static_objects():
	for object_key in _object_defs.keys():
		var object_def:Dictionary = _object_defs[object_key]
		if is_object_static(object_def):
			var script_path = get_object_script_path(object_def)
			var script = load(script_path)
			if !script:
				printerr("%sLibrary._load_static_objects: %s Failed to find object script '%s'. " % [get_object_name(), object_key, script_path])
				continue
			#if not script is BaseLoadObject:
				#printerr("%sLibrary._load_static_objects: Object %s loaded script '%s' is not of type 'BaseLoadObject'." % [get_object_name(), object_key, script_path]) 
				#continue
			#if not (script as BaseLoadObject).is_static():
				#printerr("%sLibrary._load_static_objects: Object %s is_static method returned false." % [get_object_name(), object_key]) 
				#continue
			var load_path = _defs_to_load_paths[object_key]
			var new_object:BaseLoadObject = script.new(object_key, load_path, object_def, object_key)
			if _static_objects.keys().has(object_key):
				printerr("%sLibrary._load_static_objects: Object %s already loaded." % [get_object_name(), object_key]) 
				continue
			_static_objects[object_key] = new_object
			if LOGGING: print("# - Loaded Static Object: %s" % [new_object._id])

## Parse json save file and load to _loaded_objects
func _load_objects_saved_data(saved_datas:Dictionary, purge_data:bool=true):
	if purge_data:
		purge_objects()
		
	var object_key_name = get_object_key_name()
	#var saved_data:Dictionary = JSON.parse_string(text)
	#var object_datas = saved_data.get("Objects", {})
	for object_id:String in saved_datas.keys():
		var save_data = saved_datas[object_id]
		var object_key = save_data.get(object_key_name, save_data.get("ObjectKey", null))
		if !object_key:
			printerr("%sLibrary._load_object_file: No 'ObjectKey' found on object '%s'" % [ get_object_name(), object_key_name, object_id])
			continue
		var object_def = get_object_def(object_key)
		if !object_def:
			printerr("%sLibrary._load_object_file: No object def found for '%s' on object '%s'" % [get_object_name(), object_key_name, object_id])
			continue
		var script_path = get_object_script_path(object_def)
		var script = load(script_path)
		if !script:
			printerr("%sLibrary._load_object_file: Failed to find object script: %s" % [get_object_name(), script_path])
			continue
		# Not sure how to correctly check this (this always returns false)
		#if not (script as BaseLoadObject):
			#printerr("%sLibrary._load_object_file: Object %s loaded script '%s' is not of type 'BaseLoadObject'." % [get_object_name(), object_key_name, script_path]) 
			#continue
		var load_path = _defs_to_load_paths[object_key]
		var new_object:BaseLoadObject = script.new(object_key, load_path, object_def, object_id, {})
		if _loaded_objects.keys().has(object_id):
			printerr("%sLibrary._load_object_file: Object with id '%s' already loaded." % [get_object_name(), object_id])
			continue
		_loaded_objects[object_id] = new_object
		if LOGGING: print("# - Loaded Saved Object: %s" % [object_id])
	for object in _loaded_objects.values():
		var save_data = saved_datas.get(object.Id, {})
		object.load_data(save_data)


## Recursivly search directory for files with object_file_sufix.
## Appends full path of found files to out_list.
static func _search_for_files(path:String,  sufix:String):
	var out_list = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name:String = dir.get_next()
		while file_name != "":
			var full_path = path.path_join(file_name)
			if dir.current_is_dir():
				out_list.append_array(_search_for_files(full_path, sufix))
			elif file_name.ends_with(sufix):
				out_list.append(full_path)
			file_name = dir.get_next()
	else:
		printerr("BaseObjectLibrary._search_for_files: An error occurred when trying to access the path '%s'." % [path])
	return out_list

static func _merge_defs(child:Dictionary, parent:Dictionary)->Dictionary:
	var new_data = parent.duplicate()
	for key:String in child.keys():
		var val = child[key]
		if val is Dictionary:
			if not key.ends_with("Set"):
				val = _merge_defs(child[key], parent.get(key, {}))
		if val is Array:
			# Default to parent on empty list
			if val.size() == 0:
				val = parent.get(key, [])
			# Merge list only when Strings
			# Lists sufixed with "Arr" are NOT merged
			elif val[0] is String and not (key.ends_with("Arr")):
				var new_list = []
				for arr_val in parent.get(key, []):
					if not new_list.has(arr_val):
						new_list.append(arr_val)
				for arr_val in val:
					if not new_list.has(arr_val):
						new_list.append(arr_val)
				val = new_list
			# Otherwise just keep child
			else:
				val = val
		new_data[key] = val
	return new_data

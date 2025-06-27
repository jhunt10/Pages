class_name VfxLibrary

const LOGGING = false
const VfxDir = "res://ObjectDefs/Data/VFXs"

static var _vfx_defs:Dictionary
static var _vfx_datas:Dictionary = {}

static var loaded = false

static func reload_vfxs():
	_vfx_datas.clear()
	_vfx_defs.clear()
	loaded = false
	load_vfx_defs()
	
# Get a static instance of the action
static func get_vfx_data(key:String)->VfxData:
	if !loaded:
		load_vfx_defs()
	if _vfx_datas.has(key):
		return _vfx_datas[key]
	return null

static func get_vfx_def(key, data:Dictionary={}, parent:BaseLoadObject=null, optional_load_path:String='')->Dictionary:
	if !loaded:
		load_vfx_defs()
	if key == null:
		key = ""
	var vfx_def = {}
	if _vfx_defs.keys().has(key):
		vfx_def = _vfx_defs[key]
	
	var load_path = vfx_def.get("LoadPath", "")
	if data.keys().has("SpriteName"):
		if optional_load_path:
			load_path = optional_load_path
		elif parent:
			load_path = parent.get_load_path()
		elif data.has("LoadPath"):
			load_path = data['LoadPath'] 
	
	var merged_datas = BaseLoadObjectLibrary._merge_defs(data, vfx_def)
	merged_datas['LoadPath'] = load_path
	return merged_datas
#
#func create_vfx_node_from_key(vfx_key:String, data:Dictionary={})->VfxNode:
	#var vfx_data = get_vfx_data(vfx_key)
	#if !vfx_data:
		#if LOGGING: printerr("VfxLibrary.create_vfx_node: No VFX found with key '%s'." % [vfx_key])
		#return null
	#return create_vfx_node(vfx_data, data)
#
#func create_vfx_node(vfx_data:VfxData, data:Dictionary={})->VfxNode:
	#if not vfx_data:
		#if LOGGING: printerr("VfxLibrary: Null data given to create_vfx_node.")
		#return null
	#var new_node:VfxNode = load("res://Scenes/VFXs/vfx_node.tscn").instantiate()
	#new_node.vfx_id = str(ResourceUID.create_id())
	#new_node.set_vfx_data(vfx_data, data)
	#return new_node
#
#func create_test_vfx(actor:BaseActor, vfx_data:VfxData, extra_data:Dictionary):
	##reload_pages()
	#return null
	#var new_node:VfxNode = load("res://data/VFXs/DamageVFXs/Lightning/lightning_chain_vfx_node.tscn").instantiate()
	#new_node.vfx_id = str(ResourceUID.create_id())
	#new_node.set_vfx_data(vfx_data, extra_data)
	#new_node.set_actor(actor)
	#var actor_node = CombatRootControl.get_actor_node(actor.Id)
	#actor_node.vfx_holder.add_vfx(new_node.vfx_id, new_node)
	#new_node.start_vfx()
	#return new_node

static func load_vfx_defs():
	if loaded:
		return
	if LOGGING: print("### Loading VFXs")
	for file in search_for_vfx_files():
		if LOGGING: print('# Checking File: ' + file)
		var vfx_data_dicts = parse_vfx_datas_from_file(file)
		for key in vfx_data_dicts.keys():
			_vfx_datas[key] = vfx_data_dicts[key]
			if LOGGING: print("# -Loaded VFX: " + key)
	if LOGGING: print("### Done Loading VFXs")
	loaded = true

static func search_for_vfx_files()->Array:
	var list = []
	_rec_search_for_vfx(VfxDir, list)
	return list
	
static func _rec_search_for_vfx(path:String, list:Array, limit:int=1000):
	var dir = DirAccess.open(path)
	if limit == 0:
		if LOGGING: printerr("VfxLibrary._rec_search_for_vfx: Search limit reached!")
		return
	if dir:
		dir.list_dir_begin()
		var file_name:String = dir.get_next()
		while file_name != "":
			var full_path = path+"/"+file_name
			if dir.current_is_dir():
				_rec_search_for_vfx(full_path, list, limit-1)
			elif file_name.ends_with("_VfxDefs.json"):
				list.append(full_path)
			file_name = dir.get_next()
	else:
		if LOGGING: print("An error occurred when trying to access the path: %s" % [path])

static func parse_vfx_datas_from_file(path:String)->Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	var text:String = file.get_as_text()
	
	# Wrap in brackets to support multiple actions in same file
	if !text.begins_with("["):
		text = "[" + text + "]" 
	var dict = {}
	var vfx_datas = JSON.parse_string(text)
	for vfx_data in vfx_datas:
		var key = vfx_data.get("VfxKey")
		if not key:
			if LOGGING: printerr("VfxLibrary.parse_vfx_datas_from_file: Keyless def found on file: %s" % [path])
		elif !dict.has(key):
			_vfx_defs[key] = vfx_data.duplicate(true)
			_vfx_defs[key]['LoadPath'] = path.get_base_dir()
			dict[key] = VfxData.new(vfx_data, path.get_base_dir())
	return dict

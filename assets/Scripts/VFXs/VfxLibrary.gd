class_name VfxLibrary

const VfxDir = "res://data/VFXs"

var _vfx_datas:Dictionary = {}

var loaded = false

func _init() -> void:
	self.load_vfxs()

func load_vfxs():
	if loaded:
		return
	print("### Loading VFXs")
	for file in search_for_vfx_files():
		print('# Checking File: ' + file)
		var vfx_data_dicts = parse_vfx_datas_from_file(file)
		for key in vfx_data_dicts.keys():
			_vfx_datas[key] = vfx_data_dicts[key]
			print("# -Loaded VFX: " + key)
	print("### Done Loading VFXs")
	loaded = true
	
func reload_pages():
	_vfx_datas.clear()
	loaded = false
	load_vfxs()

# Get a static instance of the action
func get_vfx_data(key:String)->VfxData:
	if !loaded:
		printerr("Attepted to get VFX before loading: " + key)
	if _vfx_datas.has(key):
		return _vfx_datas[key]
	return null

func create_vfx_node_from_key(vfx_key:String, data:Dictionary={})->VfxNode:
	var vfx_data = get_vfx_data(vfx_key)
	if !vfx_data:
		printerr("VfxLibrary.create_vfx_node: No VFX found with key '%s'." % [vfx_key])
		return null
	return create_vfx_node(vfx_data, data)

func create_vfx_node(vfx_data:VfxData, data:Dictionary={})->VfxNode:
	if not vfx_data:
		printerr("VfxLibrary: Null data given to create_vfx_node.")
		return null
	var new_node:VfxNode = load("res://Scenes/VFXs/vfx_node.tscn").instantiate()
	new_node.set_vfx_data(vfx_data, data)
	return new_node

func create_ailment_vfx_node(aliment_key:String, actor:BaseActor)->VfxNode:
	
	var new_node:AilmentVfxNode = null
	if aliment_key == "Shocked":
		new_node =  load("res://data/VFXs/AilmentVFXs/shocked_vfx_node.tscn").instantiate()
	if aliment_key == "Burned":
		new_node =  load("res://data/VFXs/AilmentVFXs/burned_vfx_node.tscn").instantiate()
	if aliment_key == "Chilled":
		new_node =  load("res://data/VFXs/AilmentVFXs/chilled_vfx_node.tscn").instantiate()
	if aliment_key == "Frozen":
		new_node =  load("res://data/VFXs/AilmentVFXs/frozen_vfx_node.tscn").instantiate()
	if !new_node:
		return null
	var actor_node = CombatRootControl.get_actor_node(actor.Id)
	actor_node.vfx_holder.add_child(new_node)
	new_node.set_actor(actor)
	new_node.start_vfx()
	return new_node

static func search_for_vfx_files()->Array:
	var list = []
	_rec_search_for_vfx(VfxDir, list)
	return list
	
static func _rec_search_for_vfx(path:String, list:Array, limit:int=1000):
	var dir = DirAccess.open(path)
	if limit == 0:
		printerr("VfxLibrary._rec_search_for_vfx: Search limit reached!")
		return
	if dir:
		dir.list_dir_begin()
		var file_name:String = dir.get_next()
		while file_name != "":
			var full_path = path+"/"+file_name
			if dir.current_is_dir():
				_rec_search_for_vfx(full_path, list, limit-1)
			elif file_name.ends_with("_VFX.json"):
				list.append(full_path)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path: %s" % [path])

static func parse_vfx_datas_from_file(path:String)->Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	var text:String = file.get_as_text()
	
	# Wrap in brackets to support multiple actions in same file
	if !text.begins_with("["):
		text = "[" + text + "]" 
	var dict = {}
	var vfx_datas = JSON.parse_string(text)
	for vfx_data in vfx_datas:
		if !dict.has(vfx_data['VFXKey']):
			dict[vfx_data['VFXKey']] = VfxData.new(vfx_data, path.get_base_dir())
	return dict

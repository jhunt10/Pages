class_name TagsLibrary

const LOGGING = false
const VfxDir = "res://ObjectDefs/Data/Tags"

static var _tags_defs:Dictionary={}

static var loaded = false



static func get_tag_description(tag)->String:
	loaded = false
	if !loaded:
		load_tag_defs()
	if _tags_defs.keys().has(tag):
		var tag_data = _tags_defs[tag]
		var desc =  tag_data.get("Description", tag)
		return desc
	return tag



static func reload_tags():
	_tags_defs.clear()
	loaded = false
	load_tag_defs()

static func load_tag_defs():
	if loaded:
		return
	if LOGGING: print("### Loading Tags")
	for file in search_for_tag_files():
		if LOGGING: print('# Checking File: ' + file)
		var loading_tags_data = parse_tags_datas_from_file(file)
		for key in loading_tags_data.keys():
			_tags_defs[key] = _tags_defs[key]
			if LOGGING: print("# -Loaded Tag: " + key)
	if LOGGING: print("### Done Loading Tags")
	loaded = true

static func search_for_tag_files()->Array:
	var list = []
	_rec_search_for_tag_file(VfxDir, list)
	return list
	
static func _rec_search_for_tag_file(path:String, list:Array, limit:int=1000):
	var dir = DirAccess.open(path)
	if limit == 0:
		if LOGGING: printerr("VfxLibrary._rec_search_for_vfx: Search limit reached!")
		return
	if dir:
		dir.list_dir_begin()
		var file_name:String = dir.get_next()
		while file_name != "":
			var full_path = path.path_join(file_name)
			if dir.current_is_dir():
				_rec_search_for_tag_file(full_path, list, limit-1)
			elif file_name.ends_with("TagDefs.def"):
				list.append(full_path)
			file_name = dir.get_next()
	else:
		if LOGGING: print("An error occurred when trying to access the path: %s" % [path])

static func parse_tags_datas_from_file(path:String)->Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	var text:String = file.get_as_text()
	var dict = {}
	var tags_datas = JSON.parse_string(text)
	for tag in tags_datas.keys():
		if !dict.has(tag):
			_tags_defs[tag] = tags_datas[tag].duplicate(true)
			_tags_defs[tag]['LoadPath'] = path.get_base_dir()
			dict[tag] = tags_datas[tag]
	return dict

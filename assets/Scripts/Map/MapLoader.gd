class_name MapLoader

static var _maps:Dictionary = {}
static var _loaded:bool = false

static func load_maps():
	if _loaded:
		return
	var file_paths = BaseLoadObjectLibrary._search_for_files("res://Scenes/Maps/", "MapDef.json")
	for file_path:String in file_paths:
		var file = FileAccess.open(file_path, FileAccess.READ)
		var text:String = file.get_as_text()
		var map_data:Dictionary = JSON.parse_string(text)
		var map_key = map_data.get("MapKey", null)
		if !map_key:
			printerr("'MapKey' not found in map def file: %s" % [file_path])
			continue
		map_data['LoadPath'] = file_path.get_base_dir()
		_maps[map_key] = map_data
		
	_loaded = true

static func get_map_datas()->Dictionary:
	if !_loaded: load_maps()
	return _maps

static  func get_map_data(key)->Dictionary:
	if !_loaded: load_maps()
	return _maps.get(key, {})

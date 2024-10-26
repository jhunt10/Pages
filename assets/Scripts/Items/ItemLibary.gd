class_name ItemLibrary

const ItemDir = "res://data/Items/"

# Dictionary of item's base data config
static var _items_defs:Dictionary = {}

static var loaded = false
func _init() -> void:
	load_item_defs()

static func load_item_defs():
	if loaded:
		return
	print("Loading Items")
	var files = []
	_search_for_items(ItemDir, files)
	for file in files:
		_load_item_file(file)
	loaded = true
	
static func get_item_def(key:String):
	if _items_defs.has(key):
		return _items_defs[key]
	return {}
	
# Create a new instance of an item
static func create_new_item(key:String, data:Dictionary)->BaseItem:
	if !loaded:
		printerr("Attepted to get Item before loading: " + key)
	var item_def = _items_defs[key]
	var script = load(item_def['ItemScript'])
	if !script:
		printerr("Failed to find item script: " + item_def['ItemScript'])
		return null
	var load_path = item_def['LoadPath']
	var new_item:BaseItem = script.new(load_path, item_def, data)
	return new_item

static func _load_item_file(path:String):
	var file = FileAccess.open(path, FileAccess.READ)
	var text:String = file.get_as_text()
	
	# Wrap in brackets to support multiple actions in same file
	if !text.begins_with("["):
		text = "[" + text + "]" 
		
	var item_defs = JSON.parse_string(text)
	for def in item_defs:
		def['LoadPath'] = path.get_base_dir()
		_items_defs[def['ItemKey']] = def
		print("Loaded Item: " + def['ItemKey'])

static func _search_for_items(path:String, list:Array):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name:String = dir.get_next()
		while file_name != "":
			var full_path = path+"/"+file_name
			if dir.current_is_dir():
				_search_for_items(full_path, list)
			elif file_name.ends_with(".json"):
				list.append(full_path)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

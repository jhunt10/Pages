class_name ItemLibary

const ItemDir = "res://data/Items/"

# Dictionary of item's base data config
var _items_data:Dictionary = {}

var loaded = false
var loaded_sprites : Dictionary = {}

func _init() -> void:
	self.load_items_data()

func load_items_data():
	if loaded:
		return
	print("Loading Items")
	var files = []
	_search_for_items(ItemDir, files)
	for file in files:
		_load_item_file(file)
	loaded = true
	
func get_item_data(key:String):
	if _items_data.has(key):
		return _items_data[key]
	return {}
	
# Get a static instance of the action
func create_new_item(key:String, data:Dictionary)->BaseItem:
	if !loaded:
		printerr("Attepted to get Item before loading: " + key)
	var item_data = _items_data[key]
	var script = load(item_data['ItemScript'])
	if !script:
		printerr("Failed to find item script: " + item_data['ItemScript'])
		return null
		
	var merged_data = {}
	for k in item_data.keys():
		merged_data[k] = item_data[k]
	for k in data.keys():
		merged_data[k] = data[k]
		
	var new_item:BaseItem = script.new(merged_data)
	return new_item
	
func _search_for_items(path:String, list:Array):
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

func _load_item_file(path:String):
	var file = FileAccess.open(path, FileAccess.READ)
	var text:String = file.get_as_text()
	
	# Wrap in brackets to support multiple actions in same file
	if !text.begins_with("["):
		text = "[" + text + "]" 
		
	var item_datas = JSON.parse_string(text)
	for data in item_datas:
		data['LoadPath'] = path.get_base_dir()
		_items_data[data['ItemKey']] = data
		print("Loaded Item: " + data['ItemKey'])

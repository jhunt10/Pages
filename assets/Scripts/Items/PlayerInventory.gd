class_name PlayerInventory

static var _stacked_item_counts_by_key:Dictionary
static var _held_items_by_id:Dictionary

static var loaded = false

static func load_data(file_path):
	loaded = true

static func save_data(file_path):
	pass

static func add_item_by_key(item_key:String):
	var item_def = 
	var item = ItemLibrary.create_new_item(item_key, {})
	if item:
		_held_items_by_id[item.id] = item

class_name PlayerInventory

static var _stacked_item_counts_by_key:Dictionary
static var _held_items_ids:Array

static var loaded = false

static func load_data(file_path):
	loaded = true

static func save_data(file_path):
	pass

static func add_item(item:BaseItem):
	if _held_items_ids.has(item.Id):
		return
	
	if item.can_stack and _stacked_item_counts_by_key.keys().has(item.ItemKey):
		#TODO: Item Stacking
		var t = true
	else:
		_held_items_ids.append(item.Id)
	

static func get_held_items()->Array:
	var out_list = []
	for item_id in _held_items_ids:
		var item = ItemLibrary.get_item(item_id)
		if item:
			out_list.append(item)
		else:
			_held_items_ids.erase(item_id)
	return out_list

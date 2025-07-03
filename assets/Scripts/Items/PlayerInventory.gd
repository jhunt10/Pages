class_name PlayerInventory

const LOGGING = false

signal inventory_changed

static var _stacked_item_count_by_key:Dictionary
static var _stacked_item_id_by_key:Dictionary
static var _held_unique_items_ids:Array

static var _inst:PlayerInventory
static var Instance:PlayerInventory:
	get:
		if !_inst:
			PlayerInventory.new()
		return _inst
func _init() -> void:
	if !_inst:
		_inst = self

static func clear_items():
	_stacked_item_count_by_key.clear()
	_held_unique_items_ids.clear()

static func has_item_id(item_id:String):
	if _held_unique_items_ids.has(item_id):
		return true
	if _stacked_item_id_by_key.values().has(item_id):
		return true
	return false

static func has_item(item:BaseItem):
	#if item.can_stack:
	return _stacked_item_count_by_key.keys().has(item.ItemKey)
	#return _held_unique_items_ids.has(item.Id)

static func spawn_item(item_key:String, count):
	var item = ItemLibrary.get_static_inst_of_item(item_key)
	if item:
		add_item(item, count)

static func add_item(item:BaseItem, count:int=1):
	if LOGGING: print("PlayerInventory.AddItem: Item: %s" % [item.Id])
	if not _stacked_item_count_by_key.keys().has(item.ItemKey):
		var inv_item = ItemLibrary.get_static_inst_of_item(item.ItemKey)
		if LOGGING: print("-- New Stacking Item")
		_stacked_item_count_by_key[item.ItemKey] = count
		_stacked_item_id_by_key[item.ItemKey] = inv_item.Id
	else:
		_stacked_item_count_by_key[item.ItemKey] += count
	ItemLibrary.delete_item(item)
	Instance.inventory_changed.emit()


#static func add_to_stack(item_key:String, count:int=1):
	#if LOGGING: print("PlayerInventory.add_to_stack: Item: %s | %s" % [item_key, count])
	#if _stacked_item_id_by_key.keys().has(item_key):
		#if LOGGING: print("PlayerInventory.add_to_stack: Added to existing stack")
		#_stacked_item_count_by_key[item_key] += count
		#Instance.inventory_changed.emit()
		#return
	#if LOGGING: print("PlayerInventory.add_to_stack: Creating new stack")
	#var new_item = ItemLibrary.create_item(item_key,{})
	#_stacked_item_id_by_key[item_key] = new_item.Id
	#_stacked_item_count_by_key[item_key] = count
	#Instance.inventory_changed.emit()

static func reduce_stack_count(item_key:String, take_count:int=1):
	if LOGGING: print("PlayerInventory.reduce_stack_count: Item: %s | %s" % [item_key, take_count])
	if not _stacked_item_id_by_key.keys().has(item_key):
		if LOGGING: print("PlayerInventory.reduce_stack_count: Had none")
		return
		
	var have_count = _stacked_item_count_by_key[item_key]
	if have_count > take_count:
		_stacked_item_count_by_key[item_key] -= take_count
		Instance.inventory_changed.emit()
		if LOGGING: print("PlayerInventory.reduce_stack_count: Had more")
		return
		
	if LOGGING: print("PlayerInventory.reduce_stack_count: Had exact amount")
	var item_id = _stacked_item_id_by_key[item_key]
	var item = ItemLibrary.get_item(item_id)
	ItemLibrary.delete_item(item)
	_stacked_item_id_by_key.erase(item_key)
	_stacked_item_count_by_key.erase(item_key)
	Instance.inventory_changed.emit()

## Create a new item of key and reduce stack count in Player Inventory
static func split_item_off_stack(item_key:String)->BaseItem:
	var count = get_item_stack_count(item_key)
	if count == 0:
		var unique_item = get_item_by_key(item_key)
		if unique_item:
			delete_item_from_inventory(unique_item)
			return unique_item
		print("ItemHelper.split_item_off_stack: 0 items of key '%s' found in PlayerInventory" % [item_key])
		return null
	var inv_item = get_item_by_key(item_key)
	if !inv_item:
		print("ItemHelper.split_item_off_stack: No item of key '%s' found in PlayerInventory" % [item_key])
		return null
	var new_item = ItemLibrary.create_item(item_key, {})
	if !new_item:
		print("ItemHelper.split_item_off_stack: Failed to create new item '%s'." % [item_key])
		return null
	if count == 1:
		delete_item_from_inventory(inv_item)
	else:
		_stacked_item_count_by_key[item_key] -= 1
		Instance.inventory_changed.emit()
	return new_item

static func delete_item_from_inventory(item:BaseItem):
	#if item.can_stack:
	if not _stacked_item_id_by_key.values().has(item.Id):
		return
	_stacked_item_id_by_key.erase(item.ItemKey)
	_stacked_item_count_by_key.erase(item.ItemKey)
	#else:
		#var index = _held_unique_items_ids.find(item.Id)
		#if index < 0:
			#return
		#_held_unique_items_ids.remove_at(index)
	Instance.inventory_changed.emit()

static  func list_all_held_item_ids()->Array:
	var out_list = []
	out_list.append_array(_held_unique_items_ids)
	for item_key in _stacked_item_id_by_key.keys():
		if _stacked_item_count_by_key.get(item_key, 0) > 0:
			var item_id = _stacked_item_id_by_key[item_key]
			out_list.append(item_id)
	return out_list

static  func list_all_held_items()->Array:
	var out_list = []
	var id_list = list_all_held_item_ids()
	for id in id_list:
		var item = ItemLibrary.get_item(id)
		if item:
			out_list.append(item)
	return out_list

static func get_item_stack_count(item_key:String):
	return _stacked_item_count_by_key.get(item_key, 0)

static func get_item_by_key(item_key:String)->BaseItem:
	if _stacked_item_id_by_key.keys().has(item_key):
		var item_id = _stacked_item_id_by_key[item_key]
		return ItemLibrary.get_item(item_id)
	for item_id in _held_unique_items_ids:
		var item = ItemLibrary.get_item(item_id)
		if item and item.ItemKey == item_key:
			return item
	return null

static func get_sorted_items()->Array:
	var items = list_all_held_items()
	items.sort_custom(sort_item)
	var out_list = []
	for item in items:
		out_list.append(item)
	return out_list

static func sort_item(item_a:BaseItem, item_b:BaseItem)->bool:
	if !item_a: return true
	if !item_b: return false
	if item_a.get_display_name().naturalnocasecmp_to(item_b.get_display_name()) < 0:
		return true
	return false

static func build_save_data()->Dictionary:
	var out_dict = {}
	var item_ids = list_all_held_item_ids()
	for item_id in item_ids:
		var item = ItemLibrary.get_item(item_id)
		var save_data = item.save_data()
		save_data['StackCount'] = _stacked_item_count_by_key.get(item.ItemKey, 0)
		out_dict[item_id] = save_data
	return out_dict
	

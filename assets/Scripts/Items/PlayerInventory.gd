class_name PlayerInventory

const LOGGING = true

signal inventory_changed

static var _stacked_item_count_by_key:Dictionary
# Holds Mapping of ItemKey to Static ItemId (which is same thing and dumb)
static var _stacked_item_id_by_key:Dictionary
static var _held_unique_items_ids:Array

static var _new_items:Array = []

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

static func has_item(item_or_key):
	var item_key = item_or_key
	if item_or_key is BaseItem:
		item_key = item_or_key.ItemKey
	#if item.can_stack:
	return _stacked_item_count_by_key.keys().has(item_key)
	#return _held_unique_items_ids.has(item.Id)

static func spawn_item(item_key:String, count):
	var item = ItemLibrary.get_static_inst_of_item(item_key)
	if item:
		add_item(item, count)

static func add_item(item, count:int=1, mark_as_new:bool=false):
	var item_key = item
	if item is BaseItem:
		item_key = item.ItemKey
	
	if LOGGING: print("PlayerInventory.AddItem: Item: %s" % [item_key])
	# If Item Key doesn't exisit in counts
	if not _stacked_item_count_by_key.keys().has(item_key):
		var inv_item = ItemLibrary.get_static_inst_of_item(item_key)
		if LOGGING: print("-- New Stacking Item")
		_stacked_item_count_by_key[item_key] = count
		_stacked_item_id_by_key[item_key] = inv_item.Id
		if mark_as_new and not _new_items.has(item_key):
			_new_items.append(item_key)
	else:
		_stacked_item_count_by_key[item_key] += count
	if item is BaseItem and not item.is_static_inst:
		ItemLibrary.delete_item(item)
	Instance.inventory_changed.emit()

static func reduce_stack_count(item_key:String, take_count:int=1):
	if LOGGING: print("PlayerInventory.reduce_stack_count: Item: %s | %s" % [item_key, take_count])
	if not _stacked_item_id_by_key.keys().has(item_key):
		if LOGGING: print("PlayerInventory.reduce_stack_count: Had none")
		return
		
	var have_count = _stacked_item_count_by_key[item_key]
	# Have more than what's being taken, simply reduce count
	if have_count > take_count:
		_stacked_item_count_by_key[item_key] -= take_count
		Instance.inventory_changed.emit()
		if LOGGING: print("PlayerInventory.reduce_stack_count: Had more")
		return
	
	# Taking all or more, reduce count to zero
	if LOGGING: print("PlayerInventory.reduce_stack_count: Had exact amount")
	#var item_id = _stacked_item_id_by_key[item_key]
	#var item = ItemLibrary.get_item(item_id)
	#ItemLibrary.delete_item(item)
	#_stacked_item_id_by_key.erase(item_key)
	_stacked_item_count_by_key[item_key] = 0
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
	#_stacked_item_id_by_key.erase(item.ItemKey)
	_stacked_item_count_by_key[item.ItemKey] = 0
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
	var unique_item_dict = {} 
	var stacked_item_counts = {}
	var item_ids = list_all_held_item_ids()
	for item_id in item_ids:
		var item = ItemLibrary.get_item(item_id)
		if item.is_static_inst:
			# Item Id and Key are same for static items
			stacked_item_counts[item_id] = _stacked_item_count_by_key.get(item_id, 0)
		else: 
			var save_data = item.save_data()
			save_data['StackCount'] = _stacked_item_count_by_key.get(item.ItemKey, 0)
			unique_item_dict[item_id] = save_data
	return {"UniqueItems": unique_item_dict, "StackedItems": stacked_item_counts}

static func load_save_data(data:Dictionary):
	if LOGGING:
		print("PlayerInventory: Loading Saved Data")
	#TODO: Remove Hack to suporrt old saves (pre-Itch)
	if not data.keys().has("StackedItems"):
		var new_data = {"UniqueItems":{}, "StackedItems": {}}
		for key in data.keys():
			var sub_data = data[key]
			var obj_key = sub_data.get("ObjectKey", "")
			var obj_id = sub_data.get("Id", "")
			if obj_id == obj_key:
				new_data['StackedItems'][key] = sub_data.get("StackCount", 1)
			else:
				new_data['UniqueItems'][key] = sub_data
		data = new_data
	# Hack End
	
	# Load Unique Items
	if LOGGING:
		print("PlayerInventory: Unique Item Count: " + str(data.get("UniqueItems", {}).size()))
	for item_id in data.get("UniqueItems", {}).keys():
		if LOGGING:
			print("Loading Saved Unique Item: " + item_id)
		var item_data = data['UniqueItems'][item_id]
		var item_key = item_data.get('ObjectKey')
		var item = ItemLibrary.get_or_create_item(item_id, item_key, item_data)
		var invalid_reason = ItemLibrary.validate_object(item)
		if invalid_reason != '':
			printerr("PlayerInventory.load_save_data: Item with id '%s' is invalid: %s" % [item_id, invalid_reason])
			continue
		if item:
			PlayerInventory.add_item(item, item_data.get('StackCount', 1), false)
		else:
			printerr("PlayerInventory.load_save_data: Failed to find item with id '%s'." % [item_id])
	# Load Static Items
	if LOGGING:
		print("PlayerInventory: Static Item Count: " + str(data.get("StackedItems", []).size()))
	for item_id in data.get("StackedItems", {}).keys():
		var count = data['StackedItems'][item_id]
		if LOGGING:
			print("Loading Saved Static Item: " + str(count) + " : " + item_id)
		var item = ItemLibrary.get_static_inst_of_item(item_id)
		var invalid_reason = ItemLibrary.validate_object(item)
		if invalid_reason != '':
			printerr("PlayerInventory.load_save_data: Item with id '%s' is invalid: %s" % [item_id, invalid_reason])
			continue
		if item:
			PlayerInventory.add_item(item, count, false)
		else:
			printerr("PlayerInventory.load_save_data: Failed to find item with id '%s'." % [item_id])
		

static func is_item_new(item_key:String)->bool:
	return _new_items.has(item_key)
	
static func mark_new_item_as_seen(item_key:String):
	if _new_items.has(item_key):
		_new_items.erase(item_key)
	

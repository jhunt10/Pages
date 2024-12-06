class_name PlayerInventory

const LOGGING = false

signal inventory_changed

static var _stacked_item_ids_by_keys:Dictionary
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

static func has_item_id(item_id:String):
	var item = ItemLibrary.get_item(item_id)
	if item:
		return has_item(item)
	return false

static func has_item(item:BaseItem):
	if item.can_stack:
		return _stacked_item_ids_by_keys.get(item.ItemKey, []).has(item.Id)
	return _held_unique_items_ids.has(item.Id)

static func add_item(item:BaseItem):
	if LOGGING: print("PlayerInventory.AddItem: Item: %s" % [item.Id])
	if item.can_stack:
		if !_stacked_item_ids_by_keys.keys().has(item.ItemKey):
			if LOGGING: print("-- New Stacking Item")
			_stacked_item_ids_by_keys[item.ItemKey] = []
			_stacked_item_ids_by_keys[item.ItemKey].append(item.Id)
		elif !_stacked_item_ids_by_keys[item.ItemKey].has(item.Id):
			if LOGGING: print("-- New Item For Stack")
			_stacked_item_ids_by_keys[item.ItemKey].append(item.Id)
		else:
			if LOGGING: print("-- Has Item in Stack")
			return
	elif !_held_unique_items_ids.has(item.Id):
		if LOGGING: print("-- New Unique Item")
		_held_unique_items_ids.append(item.Id)
	else:
		if LOGGING: print("-- Has Unique Item")
		return
	Instance.inventory_changed.emit()

static func remove_item(item:BaseItem):
	if item.can_stack:
		if !_stacked_item_ids_by_keys.keys().has(item.ItemKey):
			return
		_stacked_item_ids_by_keys[item.ItemKey].erase(item.Id)
		if _stacked_item_ids_by_keys[item.ItemKey].size() == 0:
			_stacked_item_ids_by_keys.erase(item.ItemKey)
	else:
		var index = _held_unique_items_ids.find(item.Id)
		if index < 0:
			return
		_held_unique_items_ids.remove_at(index)
	Instance.inventory_changed.emit()

## For emoving item when only the Id is available. Use remove_item when possible. 
static func _erase_item_id(item_id:String):
	_held_unique_items_ids.erase(item_id)
	for key in _stacked_item_ids_by_keys.keys():
		var ids:Array = _stacked_item_ids_by_keys[key]
		ids.erase(item_id)
		if ids.size() == 0:
			_stacked_item_ids_by_keys.erase(key)

static  func list_all_held_item_ids()->Array:
	var out_list = []
	out_list.append_array(_held_unique_items_ids)
	for item_stack:Array in _stacked_item_ids_by_keys.values():
		out_list.append_array(item_stack)
	return out_list

## Returns all unique items and the first instance of each stackable item
static func list_held_item_stacks()->Array:
	var out_list = []
	for item_id in _held_unique_items_ids:
		var item = ItemLibrary.get_item(item_id)
		if item:
			out_list.append(item)
		else:
			_erase_item_id(item_id)
	for item_stack:Array in _stacked_item_ids_by_keys.values():
		if item_stack.size() == 0:
			_stacked_item_ids_by_keys.erase(item_stack)
			continue
		var first_id = item_stack[0]
		var item = ItemLibrary.get_item(first_id)
		if item:
			out_list.append(item)
		else:
			_erase_item_id(first_id)
	return out_list

static func get_item_stack_count(item_key:String):
	var ids:Array = _stacked_item_ids_by_keys.get(item_key, [])
	return ids.size()

static func get_item_or_top_stack(item:BaseItem)->BaseItem:
	if item.can_stack:
		if (_stacked_item_ids_by_keys.keys().has(item.ItemKey) 
		and _stacked_item_ids_by_keys[item.ItemKey].size() > 0):
			var top_id = _stacked_item_ids_by_keys[item.ItemKey][0]
			return ItemLibrary.get_item(top_id)
	elif _held_unique_items_ids.has(item.Id):
		return item
	return null

static func get_sorted_items()->Array:
	var items = list_held_item_stacks()
	items.sort_custom(sort_item)
	var out_list = []
	for item in items:
		out_list.append(item)
	return out_list

static func sort_item(item_a:BaseItem, item_b:BaseItem)->bool:
	if !item_a: return true
	if !item_b: return false
	if item_a.details.display_name.naturalnocasecmp_to(item_b.details.display_name) < 0:
		return true
	return false

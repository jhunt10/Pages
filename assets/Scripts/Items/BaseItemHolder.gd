## Base class for Equipment, items, and BagItem Holders
class_name BaseItemHolder

# Use Actor.bag_items_changed
#signal items_changed

const LOGGING = false

signal items_changed
signal item_slots_rebuilt

var slot_sets_data:Array:
	get:
		return _item_slot_sets_datas

## Def of each slot set. Using Array to preserve order.
var _item_slot_sets_datas:Array=[]
## Key of each SlotSet, in Array to preserve order
var _slot_set_key_mapping:Array=[]
## Array of ItemIds for that item slot
var _raw_item_slots:Array=[]
## Array of Dictionaries holding slot set meta data for that item slot 
## {"SlotSetIndex":slot_set_index, "SlotSetKey":slot_key, "SubIndex":sub_index}
var _raw_to_slot_set_mapping:Array=[]
var _actor:BaseActor

func _debug_name()->String:
	return "BaseItemHolder"

func _init(actor:BaseActor) -> void:
	self._actor = actor
	#_build_slots_list()

func build_save_data()->Array:
	var out_list = []
	for item_id in _raw_item_slots:
		if !item_id:
			out_list.append(null)
		else:
			var item = ItemLibrary.get_item(item_id)
			var save_data = item.save_data()
			out_list.append(save_data)
	return out_list

## Creates items that were slaved to slots. Ignores slot sets for now.
func load_save_data(data:Array):
	_raw_item_slots = []
	for item_data in data:
		if item_data == null:
			_raw_item_slots.append(null)
			continue
		var item_id = item_data.get('Id')
		var item_key = item_data.get('ObjectKey')
		var new_item = ItemLibrary.get_or_create_item(item_id, item_key, item_data)
		if new_item:
			_raw_item_slots.append(new_item.Id)
		else:
			printerr("BaseItemHolder.load_save_data: Failed to create item for id '%s'." % [item_id])
			_raw_item_slots.append(null)

func _load_slots_sets_data()->Array:
	return []

func _on_item_loaded(Item:BaseItem):
	pass

func validate_items():
	if LOGGING: print("Validating Itemes for %s : %s" % [_actor.Id, _debug_name()])
		
	var backup_slots = _raw_item_slots.duplicate()
	_build_slots_list()
	_raw_item_slots.fill(null)
	for old_slot_index in range(backup_slots.size()):
		var item_id = backup_slots[old_slot_index]
		if not item_id:
			continue
		var item = ItemLibrary.get_item(item_id, false)
		if not item:
			printerr("%s.validate_items: No item found with id '%s'." % [_debug_name(), item_id])
			continue
		# Get the first slot item could go in
		var slot = get_first_valid_slot_for_item(item, false)
		# if found, put it there
		if slot >= 0:
			_raw_item_slots[slot] = item.Id
		# else remove
		else:
			remove_item(item.Id)
			if _actor.is_player:
				PlayerInventory.add_item(item)
				

# Returns true if valid or String message of why the item is not valid.
func _is_item_valid_in_slot(slot_index, item:BaseItem):
	return true

func _build_slots_list():
	if LOGGING: print("Building Slots for Itemes for %s : %s" % [_actor.Id, _debug_name()])
	_slot_set_key_mapping = []
	_raw_to_slot_set_mapping = []
	_item_slot_sets_datas = _load_slots_sets_data()
	if LOGGING: print("- Raw Slots : %s" % [_raw_item_slots])
	var _backup_slots = _raw_item_slots.duplicate()
	_raw_item_slots.clear()
	#if _actor.ActorKey == "TestChaser":
		#var t = true
	var raw_index = 0
	var slot_set_index = 0
	for sub_slot_data in _item_slot_sets_datas:
		var slot_key = sub_slot_data.get("Key")
		var sub_slot_count = sub_slot_data.get("Count")
		sub_slot_data['IndexOffset'] = raw_index
		_slot_set_key_mapping.append(slot_key)
		for sub_index in range(sub_slot_count):
			_raw_to_slot_set_mapping.append({"SlotSetIndex":slot_set_index, "SlotSetKey":slot_key, "SubIndex":sub_index})
			if _backup_slots.size() > raw_index:
				_raw_item_slots.append(_backup_slots[raw_index])
			else:
				_raw_item_slots.append(null)
			raw_index += 1
		slot_set_index += 1
	
	if LOGGING: print("- Final Raw Index: %s" % [raw_index])
	if LOGGING: print("- Backup Slots: %s\n" % [_backup_slots])
	while raw_index < _backup_slots.size():
		if _backup_slots[raw_index] and _actor.is_player:
			var item = ItemLibrary.get_item(_backup_slots[raw_index], false)
			if item:
				PlayerInventory.add_item(item)
		raw_index += 1
	item_slots_rebuilt.emit()

func get_raw_slot_index_of_item(item:BaseItem):
	return _raw_item_slots.find(item.Id)

#func get_raw_slot_index(tag:String, sub_index:int)->int:
	#var slot_set_index = _slot_set_key_mapping.find(tag)
	#if slot_set_index < 0:
		#return slot_set_index
	#else:
		#return _item_slot_sets_datas[slot_set_index]['IndexOffset'] + sub_index

func get_slot_set_data_for_index(index:int):
	if index < 0 or index > _raw_item_slots.size():
		return null
	var index_data = _raw_to_slot_set_mapping[index]
	return _item_slot_sets_datas[index_data['SlotSetIndex']]
	

func get_slot_set_key_for_index(index:int):
	var data = get_slot_set_data_for_index(index)
	if data:
		return data['Key']
	return null
	
func get_slot_sub_index_for_index(index:int):
	var data = get_slot_set_data_for_index(index)
	if data:
		var index_offset = data['IndexOffset']
		return index - index_offset
	return null

func get_max_item_count()->int:
	return _raw_item_slots.size()

## Returns an all item slots and the item id they are set to. This includes empty slots will null values. 
func list_item_ids(include_nulls:bool=false)->Array:
	var out_list = []
	for val in _raw_item_slots:
		if include_nulls or val:
			out_list.append(val)
	return out_list

## Returns all items in slots. Does not include nulls for empty slots.
func list_items()->Array:
	var out_list=[]
	for index in range(_raw_item_slots.size()):
		var item_id = _raw_item_slots[index]
		if item_id == null: continue
		var item = ItemLibrary.get_item(item_id, false)
		if item:
			out_list.append(item)
		else:
			printerr("%s.list_items: Lost Item in slot '%s': '%s'" % [_debug_name(), index, item_id])
			_raw_item_slots[index] = null
			
	return out_list

func has_item(item_id:String):
	return _raw_item_slots.has(item_id)

func get_item_id_in_slot(index:int):
	if index >= 0 and index < _raw_item_slots.size():
		var item_id = _raw_item_slots[index]
		if item_id:
			return item_id
	return ''

func get_item_in_slot(index:int)->BaseItem:
	if index >= 0 and index < _raw_item_slots.size():
		var item_id =  _raw_item_slots[index]
		if item_id:
			var item = ItemLibrary.get_item(item_id, false)
			if item:
				return item
			else:
				printerr("%s.get_item_in_slot: Lost Item in slot '%s': '%s'" % [_debug_name(), index, item_id])
				_raw_item_slots[index] = null
	return null

func remove_item(item_id:String, supress_signal:bool=false):
	print("Remove Item: %s" % [item_id])
	if not ItemHelper.transering_items.has(item_id):
		printerr("Transfering Item outside of ItemHelper: %s | %s " % [item_id, _actor.Id])
	var index = _raw_item_slots.find(item_id)
	if index >= 0:
		_raw_item_slots[index] = null
		_on_item_removed(item_id, supress_signal)
		if not supress_signal:
			items_changed.emit()

func can_set_item_in_slot(item:BaseItem, index:int, allow_replace:bool=false)->bool:
	if index < 0 or index >= _raw_item_slots.size():
		printerr("ItemHolder.can_set_item_in_slot: Index '%s' outside of range '%s'." % [index, _raw_item_slots.size()])
		return false
	if not allow_replace and _raw_item_slots.has(item.Id):
		return false
	var check_slot_set_data = get_slot_set_data_for_index(index)
	if LOGGING: print("ItemHolder.can_set_item_in_slot: _can_slot_set_accept_item: Index '%s' | %s" % [index, check_slot_set_data])
	if not _can_slot_set_accept_item(check_slot_set_data, item):
		return false
	if not allow_replace and _raw_item_slots[index] != null:
		return false
	return true

## Directly set an Item into given slot index without any checks or signals.
## Should only be used by ItemHelper
func _direct_set_item_in_slot(slot_index:int, item:BaseItem):
	if slot_index >= 0 and slot_index <= _raw_item_slots.size():
		_raw_item_slots[slot_index] = item.Id

## Get Items that will be removed if current item is added to slot.
## Should only be used by ItemHelper
func _get_items_removed_if_new_item_added(slot_index:int, item:BaseItem)->Array:
	var current_item = get_item_in_slot(slot_index)
	if current_item:
		return [current_item]
	return []

func try_set_item_in_slot(item:BaseItem, index:int, allow_replace:bool=false)->bool:
	if not ItemHelper.transering_items.has(item.Id):
		printerr("Transfering Item outside of ItemHelper: %s | %s " % [item.Id, _actor.Id])
	if not can_set_item_in_slot(item, index, allow_replace):
		return false
	if _raw_item_slots[index] != null:
		if allow_replace:
			remove_item(_raw_item_slots[index], true)
		else:
			return false
	_raw_item_slots[index] = item.Id
	_on_item_added_to_slot(item, index)
	items_changed.emit()
	return true

func _can_slot_set_accept_item(check_slot_set_data:Dictionary, item:BaseItem)->bool:
	var filter_data = check_slot_set_data.get("FilterData")
	var item_tags = item.get_tags()
	if filter_data:
		var required_tags = filter_data.get("RequiredTags")
		if required_tags is String:
			if item_tags.has(required_tags):
				return true
		if required_tags is Array:
			for req_tag in required_tags:
				if not item_tags.has(req_tag):
					return false
			return true
	else:
		return true
	if LOGGING: print("_can_slot_set_accept_item: %s: %s | %s" % [item.Id, item_tags, filter_data])
	return false
	

func get_first_valid_slot_for_item(item:BaseItem, allow_replace:bool=false)->int:
	for i in range(_raw_item_slots.size()):
		if can_set_item_in_slot(item, i, allow_replace):
			return i
	return -1

func add_item_to_first_valid_slot(item:BaseItem):
	ItemHelper.transering_items.append(item.Id)
	for i in range(_raw_item_slots.size()):
		if try_set_item_in_slot(item, i, false):
			ItemHelper.transering_items.erase(item.Id)
			return true
	ItemHelper.transering_items.erase(item.Id)
	return false

func _on_item_removed(item_id:String, supressing_signals:bool):
	pass

func _on_item_added_to_slot(item:BaseItem, index:int):
	pass



func get_passive_stat_mods()->Array:
	var out_list = []
	var checked_items = [] ## For double sloted items (two handing)
	for item_id in _raw_item_slots:
		if checked_items.has(item_id):
			continue
		checked_items.append(item_id)
		if item_id and item_id != '':
			var item:BaseItem = ItemLibrary.get_item(item_id)
			if not item:
				printerr("BaseItemHolder.get_passive_stat_mods: ItemLibrary missing item with id '%s'." % [item_id])
				continue
			out_list.append_array(item.get_passive_stat_mods())
	return out_list

func _get__mods(mod_prefix:String)->Dictionary:
	var out_dict = {}
	var checked_items = [] ## For double sloted items (two handing)
	for item_id in _raw_item_slots:
		if checked_items.has(item_id):
			continue
		if item_id and item_id != '':
			var item:BaseItem = ItemLibrary.get_item(item_id)
			if item:
				var mods = item._get__mods(mod_prefix)
				for mod_key in mods.keys():
					out_dict[mod_key] = mods[mod_key]
	return out_dict

func get_targeting_mods()->Array:
	return _get__mods("Target").values()

func get_ammo_mods()->Dictionary:
	return _get__mods("Ammo")
	
func get_attack_mods()->Dictionary:
	return _get__mods("Attack")
	
func get_damage_mods()->Dictionary:
	return _get__mods("Damage")
	
func get_weapon_mods()->Dictionary:
	return _get__mods("Weapon")

	#for item_tags in _item_tagged_slots.keys():
		#if _does_item_match_tags(item_tags, item):
			#var open_slot = _item_tagged_slots[item_tags].find(null)
			#if open_slot >= 0:
				#_item_tagged_slots[item_tags][open_slot] = item.Id
				#_actor.bag_items_changed.emit()
				#print("Added Item: " + item.Id)
				#return
			#else:
				#print("No Open Slot found in '%s'" %[item_tags])
		#else:
			#print("%s Not match tags '%s'" %[item.ItemKey, item_tags])
	#print("No Valid ItemTags Slot Found")

#func _does_item_match_tags(item_tags:String, item:BaseItem)->bool:
	#var tags = item_tags.split("|")
	#for tag in tags:
		#if tag == "Any":
			#continue
		#if not item.details.tags.has(tag):
			#return false
	#return true

#func set_item_for_slot(slot_item_tags:String, index:int, item:BaseItem):
	#if !_item_tag_slot_counts.keys().has(slot_item_tags):
		#return
	#if item and _item_tagged_slots[slot_item_tags].has(item.ItemKey):
		#return
	#if index < 0 or index >= _item_tagged_slots[slot_item_tags].size():
		#return
	#if item:
		#_item_tagged_slots[slot_item_tags][index] = item.Id
	#else:
		#_item_tagged_slots[slot_item_tags][index] = null
	#_actor.bag_items_changed.emit()
#
#func get_item_ids_per_item_tags()->Dictionary:
	#return _item_tagged_slots.duplicate()

#func _count_item_tag_slots():
	#_item_tag_slot_counts.clear()
	#var total_max_count = 0
	#for equipment:BaseEquipmentItem in _actor.equipment.list_equipment():
		#var item_tags_dict:Dictionary = equipment.get_load_val("ItemTagSlots", {})
		##printerr("Checking Equipment for ItemTagSlots: %s : %s" % [equipment.Id, item_tags_dict])
		#for item_tags in item_tags_dict.keys():
			#if !_item_tag_slot_counts.keys().has(item_tags):
				#_item_tag_slot_counts[item_tags] = 0
			#_item_tag_slot_counts[item_tags] += item_tags_dict[item_tags]
			#total_max_count += item_tags_dict[item_tags]
	#
	#var found_change = false
	#
	## Remove lost Item Tags
	#for item_tags in _item_tagged_slots.keys():
		#if not _item_tag_slot_counts.keys().has(item_tags):
			#found_change = true
			#_item_tagged_slots.erase(item_tags)
	#
	## Correct slots size
	#for item_tags in _item_tag_slot_counts.keys():
		## Item Tags did not exist
		#if !_item_tagged_slots.keys().has(item_tags):
			#_item_tagged_slots[item_tags] = []
			#found_change = true
		## Correct for size change
		#var max_count = _item_tag_slot_counts[item_tags]
		#if max_count != _item_tagged_slots[item_tags].size():
			#found_change = true
			#if _item_tagged_slots[item_tags].size() < max_count:
				#for index in range(max_count - _item_tagged_slots[item_tags].size()):
					#_item_tagged_slots[item_tags].append(null)
			#else:
				#for index in range(_item_tagged_slots[item_tags].size() - max_count):
					#_item_tagged_slots[item_tags].remove_at(max_count)
	#

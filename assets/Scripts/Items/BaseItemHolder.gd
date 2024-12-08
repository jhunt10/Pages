## Base class for Equipment, items, and BagItem Holders
class_name BaseItemHolder

# Use Actor.bag_items_changed
#signal items_changed

signal items_changed

var slot_sets_data:Array:
	get:
		return _item_slot_sets_datas

## Def of each slot set. Using Array to preserve order.
var _item_slot_sets_datas:Array=[]
## Ordered Array of slot set keyes
var _slot_set_key_mapping:Array=[]
var _raw_item_slots:Array=[]
var _raw_to_slot_set_mapping:Array=[]
var _actor:BaseActor

func _init(actor:BaseActor) -> void:
	self._actor = actor
	_build_slots_list()

func _load_slots_sets_data()->Array:
	return []

func _load_saved_items()->Array:
	return []

func _build_slots_list():
	var slot_set_index = 0
	var raw_index = 0
	_slot_set_key_mapping = []
	_raw_to_slot_set_mapping = []
	_item_slot_sets_datas = _load_slots_sets_data()
	var saved_items = _load_saved_items()
	#if _actor.ActorKey == "TestChaser":
		#var t = true
	for sub_slot_data in _item_slot_sets_datas:
		var slot_key = sub_slot_data.get("Key")
		var sub_slot_count = sub_slot_data.get("Count")
		sub_slot_data['IndexOffset'] = raw_index
		_slot_set_key_mapping.append(slot_key)
		for sub_index in range(sub_slot_count):
			_raw_to_slot_set_mapping.append({"SlotSetIndex":slot_set_index, "SlotSetKey":slot_key, "SubIndex":sub_index})
			if saved_items.size() > raw_index:
				_raw_item_slots.append(saved_items[raw_index])
			else:
				_raw_item_slots.append(null)
			raw_index += 1
		slot_set_index += 1

func get_raw_slot_index(tag:String, sub_index:int)->int:
	var slot_set_index = _slot_set_key_mapping.find(tag)
	if slot_set_index < 0:
		return slot_set_index
	else:
		return _item_slot_sets_datas[slot_set_index]['IndexOffset'] + sub_index

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
	for id in _raw_item_slots:
		if id == null: continue
		var item = ItemLibrary.get_item(id)
		if item:
			out_list.append(item)
	return out_list

func has_item(item_id:String):
	return _raw_item_slots.has(item_id)

func get_item_id_in_slot(index:int):
	if index >= 0 and index < _raw_item_slots.size():
		return _raw_item_slots[index]
	return null

func get_item_in_slot(index:int)->BaseItem:
	if index >= 0 and index < _raw_item_slots.size():
		var item_id =  _raw_item_slots[index]
		if item_id:
			return ItemLibrary.get_item(item_id)
	return null

func remove_item(item_id:String, supress_signal:bool=false):
	var index = _raw_item_slots.find(item_id)
	if index >= 0:
		_raw_item_slots[index] = null
		_on_item_removed_from_slot(item_id, index)
		if not supress_signal:
			items_changed.emit()

func can_set_item_in_slot(item:BaseItem, index:int, allow_replace:bool=false)->bool:
	if index < 0 or index >= _raw_item_slots.size():
		return false
	if not allow_replace and _raw_item_slots.has(item.Id):
		return false
	var slot_set_data = get_slot_set_data_for_index(index)
	if not _can_slot_set_accept_item(slot_set_data, item):
		return false
	if not allow_replace and _raw_item_slots[index] != null:
		return false
	return true

func try_set_item_in_slot(item:BaseItem, index:int, allow_replace:bool=false)->bool:
	if not can_set_item_in_slot(item, index, allow_replace):
		return false
	if _raw_item_slots[index] != null:
		remove_item(_raw_item_slots[index], true)
	_raw_item_slots[index] = item.Id
	_on_item_added_to_slot(item, index)
	items_changed.emit()
	return true

func _can_slot_set_accept_item(slot_set_data:Dictionary, item:BaseItem)->bool:
	var filter_data = slot_set_data.get("FilterData")
	var item_tags = item.get_item_tags()
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
	return false
	

func add_item_to_first_valid_slot(item:BaseItem):
	for i in range(_raw_item_slots.size()):
		if try_set_item_in_slot(item, i, false):
			return true
	return false

func _on_item_removed_from_slot(item_id:String, index:int):
	pass

func _on_item_added_to_slot(item:BaseItem, index:int):
	pass




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

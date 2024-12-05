## Manages the items in an Actor's bag
class_name ItemHolder

# Use Actor.bag_items_changed
#signal items_changed

var _item_tag_slot_counts:Dictionary={}
var _item_tagged_slots:Dictionary={}

var _actor:BaseActor

func _init(actor:BaseActor) -> void:
	self._actor = actor
	_actor.equipment_changed.connect(_count_item_tag_slots)
	_item_tagged_slots = _actor.get_load_val("BagItems", {})
	_count_item_tag_slots()
	

func get_max_item_count()->int:
	var count = 0
	for val in _item_tag_slot_counts.values():
		count += val
	return count

## Returns an all item slots and the item id they are set to. This includes empty slots will null values. 
func list_item_ids()->Array:
	var out_list = []
	for val in _item_tagged_slots.values():
		out_list.append_array(val)
	return out_list

## Returns all items in slots. Does not include nulls for empty slots.
func list_items()->Array:
	var ids = list_item_ids()
	var out_list=[]
	for id in ids:
		if id == null: continue
		var item = ItemLibrary.get_item(id)
		if item:
			out_list.append(item)
	return out_list

func has_item(item_id:String):
	var item_ids = list_item_ids()
	return item_ids.has(item_id)

func remove_item(item_id:String):
	for item_tags in _item_tagged_slots.keys():
		var index = _item_tagged_slots[item_tags].find(item_id)
		if index < 0:
			continue
		_item_tagged_slots[item_tags][index] = null
		_actor.bag_items_changed.emit()
		return

func add_item_to_first_valid_slot(item:BaseItem):
	for item_tags in _item_tagged_slots.keys():
		if _does_item_match_tags(item_tags, item):
			var open_slot = _item_tagged_slots[item_tags].find(null)
			if open_slot >= 0:
				_item_tagged_slots[item_tags][open_slot] = item.Id
				_actor.bag_items_changed.emit()
				print("Added Item: " + item.Id)
				return
			else:
				print("No Open Slot found in '%s'" %[item_tags])
		else:
			print("%s Not match tags '%s'" %[item.ItemKey, item_tags])
	print("No Valid ItemTags Slot Found")

func _does_item_match_tags(item_tags:String, item:BaseItem)->bool:
	var tags = item_tags.split("|")
	for tag in tags:
		if tag == "Any":
			continue
		if not item.details.tags.has(tag):
			return false
	return true

func set_item_for_slot(slot_item_tags:String, index:int, item:BaseItem):
	if !_item_tag_slot_counts.keys().has(slot_item_tags):
		return
	if item and _item_tagged_slots[slot_item_tags].has(item.ItemKey):
		return
	if index < 0 or index >= _item_tagged_slots[slot_item_tags].size():
		return
	if item:
		_item_tagged_slots[slot_item_tags][index] = item.Id
	else:
		_item_tagged_slots[slot_item_tags][index] = null
	_actor.bag_items_changed.emit()

func get_item_ids_per_item_tags()->Dictionary:
	return _item_tagged_slots.duplicate()

func _count_item_tag_slots():
	_item_tag_slot_counts.clear()
	var total_max_count = 0
	for equipment:BaseEquipmentItem in _actor.equipment.list_equipment():
		var item_tags_dict:Dictionary = equipment.get_load_val("ItemTagSlots", {})
		#printerr("Checking Equipment for ItemTagSlots: %s : %s" % [equipment.Id, item_tags_dict])
		for item_tags in item_tags_dict.keys():
			if !_item_tag_slot_counts.keys().has(item_tags):
				_item_tag_slot_counts[item_tags] = 0
			_item_tag_slot_counts[item_tags] += item_tags_dict[item_tags]
			total_max_count += item_tags_dict[item_tags]
	
	var found_change = false
	
	# Remove lost Item Tags
	for item_tags in _item_tagged_slots.keys():
		if not _item_tag_slot_counts.keys().has(item_tags):
			found_change = true
			_item_tagged_slots.erase(item_tags)
	
	# Correct slots size
	for item_tags in _item_tag_slot_counts.keys():
		# Item Tags did not exist
		if !_item_tagged_slots.keys().has(item_tags):
			_item_tagged_slots[item_tags] = []
			found_change = true
		# Correct for size change
		var max_count = _item_tag_slot_counts[item_tags]
		if max_count != _item_tagged_slots[item_tags].size():
			found_change = true
			if _item_tagged_slots[item_tags].size() < max_count:
				for index in range(max_count - _item_tagged_slots[item_tags].size()):
					_item_tagged_slots[item_tags].append(null)
			else:
				for index in range(_item_tagged_slots[item_tags].size() - max_count):
					_item_tagged_slots[item_tags].remove_at(max_count)
	

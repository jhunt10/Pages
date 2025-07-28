## Base class for Equipment, items, and BagItem Holders
class_name BaseItemHolder

const LOGGING = true
enum ValidStates {UnValidated, Valid, Invalid, Unacceptable}

# Unused / Outdated signal left behind because I don't want to fix Character Sheet right now
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
## Array of ValidStates for each _raw_slot
var _slot_validation_states:Array = []
## Array of Dictionaries holding slot set meta data for that item slot 
## {"SlotSetIndex":slot_set_index, "SlotSetKey":slot_key, "SubIndex":sub_index}
var _raw_to_slot_set_mapping:Array=[]
var _actor:BaseActor

## Array Item Id for for items providing of Slot Mods
var _slot_mod_source_item_ids:Array = [] 

func get_holder_name()->String:
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

func _get_innate_slots_data()->Array:
	return []

func _build_slots_list():
	if LOGGING: print("Building Slots in %s for %s" % [get_holder_name(), _actor.Id])
	if LOGGING: print("- Raw Slots : %s" % [_raw_item_slots])
	
	# Cache current items and thier slot set data to rebuild list later
	var old_item_to_slot_sets = []
	for old_index in range(_raw_item_slots.size()):
		var old_slot_set_data = _raw_to_slot_set_mapping[old_index].duplicate()
		old_slot_set_data['ItemId'] = _raw_item_slots[old_index]
		old_item_to_slot_sets.append(old_slot_set_data)
	
	# Clear current data
	_slot_set_key_mapping = []
	_raw_to_slot_set_mapping = []
	_slot_mod_source_item_ids = []
	
	# Load Slot sets
	_item_slot_sets_datas = _get_innate_slots_data()
	var slot_mods = _actor.get_item_slot_mods_for_holder(get_holder_name())
	for slot_mod_key in slot_mods.keys():
		var slot_mod = slot_mods[slot_mod_key]
		if slot_mod.keys().has("AddedSlotSets"):
			var added_slot_datas = slot_mod['AddedSlotSets']
			for added_slot_data:Dictionary in added_slot_datas:
				# Add Source Item Id from Mod to SlotSet
				if (not added_slot_data.keys().has("SourceItemId")
				 and slot_mod.keys().has("SourceItemId")):
					added_slot_data['SourceItemId'] = slot_mod['SourceItemId']
				_item_slot_sets_datas.append(added_slot_data)
			
	# Clear raw slots list after getting Slot Mods
	_raw_item_slots.clear()
	
	# Build Slot Sets
	var raw_index = 0
	var slot_set_index = 0
	for slot_set_data in _item_slot_sets_datas:
		if slot_set_data.keys().has("SourceItemId"):
			var item_id = slot_set_data['SourceItemId']
			if not _slot_mod_source_item_ids.has(item_id):
				_slot_mod_source_item_ids.append(item_id)
		var slot_key = slot_set_data.get("Key", slot_set_data.get("SlotSetKey", ""))
		var sub_slot_count = slot_set_data.get("Count")
		slot_set_data['IndexOffset'] = raw_index
		_slot_set_key_mapping.append(slot_key)
		for sub_index in range(sub_slot_count):
			_raw_to_slot_set_mapping.append({
				"SlotSetIndex":slot_set_index, 
				"SlotSetKey":slot_key, 
				"SubIndex":sub_index
			})
			_raw_item_slots.append(null)
			_slot_validation_states.append(ValidStates.UnValidated)
			raw_index += 1
		slot_set_index += 1
	
	if LOGGING: print("- Final Raw Index: %s" % [raw_index])
	#if LOGGING: print("- Backup Slots: %s\n" % [_backup_slots])
	
	# Find new indexes for old items
	var rejected_items = []
	for old_index in range(old_item_to_slot_sets.size()):
		var old_data = old_item_to_slot_sets[old_index]
		var slot_set_key = old_data['SlotSetKey']
		var old_slot_set_sub_index = old_data['SubIndex']
		var item_id = old_data['ItemId']
		# There was no item
		if item_id == null:
			continue
		var new_slot_set_data = get_slot_set_data(slot_set_key)
		
		# Slot Set that used to hold this item is gone
		if new_slot_set_data.size() == 0:
			rejected_items.append(item_id)
			continue
		# Size of Slot set has changed and pushed this item out
		if new_slot_set_data.get("Count", 0) < old_slot_set_sub_index:
			rejected_items.append(item_id)
			continue
		var new_index = new_slot_set_data.get("IndexOffset") + old_slot_set_sub_index
		if new_index >= _raw_item_slots.size():
			printerr("ItemHolder.build_slots_list: Miscalulated size of new index?")
			continue
		_raw_item_slots[new_index] = item_id
	
	for item_id in rejected_items:
		# TODO: Handle Rejected items (inventory, ground, or void)
		var item = ItemLibrary.get_item(item_id, false)
		if item:
			PlayerInventory.add_item(item)
	
	item_slots_rebuilt.emit()

func get_valid_state_of_item(item)->ValidStates:
	var index = get_raw_slot_index_of_item(item)
	if index >= 0 and index < _slot_validation_states.size():
		return _slot_validation_states[index]
	return ValidStates.UnValidated
	

func validate_items():
	if LOGGING: print("Validating Itemes for %s : %s" % [_actor.Id, get_holder_name()])
	for index in range(_raw_item_slots.size()):
		var item_id = _raw_item_slots[index]
		# Slot is empty
		if !item_id:
			_slot_validation_states[index] = ValidStates.UnValidated
			continue
		
		var item = ItemLibrary.get_item(item_id, false)
		# Item does not exist
		if not item:
			printerr("%s.validate_items: No item found with id '%s' in slot %s." % [get_holder_name(), item_id, index])
			_direct_clear_slot(index)
			continue
		
		var is_accepted = can_set_item_in_slot(item, index, true)
		if not is_accepted:
			_slot_validation_states[index] = ValidStates.Unacceptable
			continue
		
		var invalid_reason = item.get_cant_use_reasons(_actor)
		if invalid_reason.size() > 0:
			_slot_validation_states[index] = ValidStates.Invalid
			continue
		_slot_validation_states[index] = ValidStates.Valid
	if LOGGING: print("Finished Validating Itemes for %s : %s" % [_actor.Id, get_holder_name()])

func get_raw_slot_index_of_item(item:BaseItem):
	return _raw_item_slots.find(item.Id)

#func get_raw_slot_index(tag:String, sub_index:int)->int:
	#var slot_set_index = _slot_set_key_mapping.find(tag)
	#if slot_set_index < 0:
		#return slot_set_index
	#else:
		#return _item_slot_sets_datas[slot_set_index]['IndexOffset'] + sub_index

func get_slot_set_data(key:String)->Dictionary:
	for data:Dictionary in _item_slot_sets_datas:
		if data.get("Key") == key:
			return data
	return {}

func get_slot_set_data_for_index(index:int):
	if index < 0 or index > _raw_item_slots.size():
		return {}
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

## Returns all items in slots. Not include nulls for empty slots.
func list_items(include_invalid:bool = false)->Array:
	var out_list=[]
	for index in range(_raw_item_slots.size()):
		# Check if item is valid
		if not include_invalid and _slot_validation_states[index] != ValidStates.Valid:
			continue
		
		var item_id = _raw_item_slots[index]
		if item_id == null: 
			continue
		var item = ItemLibrary.get_item(item_id, false)
		if item:
			out_list.append(item)
		else:
			printerr("%s.list_items: Lost Item in slot '%s': '%s'" % [get_holder_name(), index, item_id])
			_direct_clear_slot(index)
			
	return out_list

func list_invalid_items()->Array:
	var out_list=[]
	for index in range(_raw_item_slots.size()):
		# Check if item is valid
		if _slot_validation_states[index] == ValidStates.Valid:
			continue
		
		var item_id = _raw_item_slots[index]
		if item_id == null: 
			continue
		var item = ItemLibrary.get_item(item_id, false)
		if item:
			out_list.append(item)
		else:
			printerr("%s.list_items: Lost Item in slot '%s': '%s'" % [get_holder_name(), index, item_id])
			_direct_clear_slot(index)
			
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
				printerr("%s.get_item_in_slot: Lost Item in slot '%s': '%s'" % [get_holder_name(), index, item_id])
				_direct_clear_slot(index)
	return null

func remove_item(item_id:String, supress_signal:bool=false):
	print("Remove Item: %s" % [item_id])
	if not ItemHelper.transering_items.has(item_id):
		printerr("Transfering Item outside of ItemHelper: %s | %s " % [item_id, _actor.Id])
	var index = _raw_item_slots.find(item_id)
	if index >= 0:
		_direct_clear_slot(index)
		_on_item_removed(item_id, supress_signal)

## Returns true if SlotSet of given index will accept Item
func can_set_item_in_slot(item:BaseItem, index:int, allow_replace:bool=false)->bool:
	if index < 0 or index >= _raw_item_slots.size():
		printerr("ItemHolder.can_set_item_in_slot: Index '%s' outside of range '%s'." % [index, _raw_item_slots.size()])
		return false
	
	# No Swapping or replacing items
	if not allow_replace:
		# Slot is occupied
		if _raw_item_slots[index] != null:
			return false
		# Item is already in other slot
		if _raw_item_slots.has(item.Id):
			return false
	var check_slot_set_data = get_slot_set_data_for_index(index)
	#if LOGGING: print("ItemHolder.can_set_item_in_slot: _can_slot_set_accept_item: Index '%s' | %s" % [index, check_slot_set_data])
	if not _can_slot_set_accept_item(check_slot_set_data, item):
		return false
	return true

## Directly set an Item into given slot index without any checks or signals.
## Should only be used by ItemHelper
func _direct_set_item_in_slot(slot_index:int, item:BaseItem):
	if slot_index >= 0 and slot_index <= _raw_item_slots.size():
		_raw_item_slots[slot_index] = item.Id
		_slot_validation_states[slot_index] = ValidStates.UnValidated

func _direct_clear_slot(slot_index:int):
	if slot_index >= 0 and slot_index <= _raw_item_slots.size():
		_raw_item_slots[slot_index] = null
		_slot_validation_states[slot_index] = ValidStates.UnValidated
	

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
	_slot_validation_states[index] = ValidStates.UnValidated
	_on_item_added_to_slot(item, index)
	return true

## Check if given SlotSet data accepts item
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
	#if LOGGING: print("%s._can_slot_set_accept_item: Not Accepted %s: %s | %s" % [get_holder_name(), item.Id, item_tags, filter_data])
	return false
	

func get_first_valid_slot_for_item(item:BaseItem, allow_replace:bool=false)->int:
	for i in range(_raw_item_slots.size()):
		if not allow_replace and _raw_item_slots[i] != null:
			continue
		if can_set_item_in_slot(item, i, allow_replace):
			return i
	return -1

func add_item_to_first_valid_slot(item:BaseItem):
	ItemHelper.transering_items.append(item.Id)
	var slot = get_first_valid_slot_for_item(item, false)
	if slot >= 0 and try_set_item_in_slot(item, slot, false):
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

func _get__mods_from_items(mod_prop_name:String, valid_items_only:bool=true)->Dictionary:
	var out_dict = {}
	for index in range(_raw_item_slots.size()):
		var item_id = _raw_item_slots[index]
		# Slot is empty
		if item_id == null or item_id != '':
			continue
		# Item is not valid
		if valid_items_only and _slot_validation_states[item_id] != ValidStates.Valid:
			continue
		var item:BaseItem = ItemLibrary.get_item(item_id)
		if not item:
			continue
		var mods = item._get__mods(mod_prop_name)
		for mod_key in mods.keys():
			# Mod has seen
			if out_dict.keys().has(mod_key):
				# Warning for same mod from differnt item
				if out_dict[mod_key].get("SourceItemId", "") != item.Id:
					printerr("%s.get_%s_mod: Mod with key '%s' added from both: %s and %s." %[get_holder_name(), mod_key, out_dict[mod_key].get("SourceItemId", ""), item.Id])
				continue
			out_dict[mod_key] = mods[mod_key]
	return out_dict

## Returns Mod Data for Item Slot Mods provided by held items, NOT mods applied to this holder
func get_item_slots_mods()->Array:
	return _get__mods_from_items("ItemSlotsMods").values()

func get_targeting_mods()->Array:
	return _get__mods_from_items("TargetMods").values()

func get_ammo_mods()->Dictionary:
	return _get__mods_from_items("AmmoMods")
	
func get_attack_mods()->Dictionary:
	return _get__mods_from_items("AttackMods")
	
func get_damage_mods()->Dictionary:
	return _get__mods_from_items("DamageMods")
	
func get_weapon_mods()->Dictionary:
	return _get__mods_from_items("WeaponMods")

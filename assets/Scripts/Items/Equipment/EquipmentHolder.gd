class_name EquipmentHolder
extends BaseItemHolder

func _debug_name()->String:
	return "EquipmentHolder"

func _init(actor) -> void:
	super(actor)

func _load_slots_sets_data()->Array:
	var slots = _actor.get_load_val("EquipmentSlots", [])
	var out_dict = {}
	for slot in slots:
		if out_dict.keys().has(slot):
			printerr("EquipmentHolder._get_slots_sets_data: Actor '%s' has multiple '%s' slots." % [_actor.Id, slot])
			continue
		out_dict[slot] = {
			"Key": slot,
			"DisplayName":slot,
			"Count": 1,
			"FilterData":{"RequiredTags":[slot]}
		}
	return out_dict.values()


func validate_items():
	_build_slots_list()

#var _actor:BaseActor

#var _slot_equipment_types:Array:
	#get: return _actor.get_load_val("EquipmentSlots", [])
#var _slot_equipment_ids:Array:
	#get: return _actor.get_load_val("Equipment", [])
#
#func _init(actor:BaseActor) -> void:
	#self._actor = actor
	#
	#_slot_equipment_types = _slot_equipment_types
	#var saved_equipment = actor.get_load_val("Equipment")
	#if !saved_equipment or saved_equipment.size() != _slot_equipment_types.size():
		#actor._data['Equipment'] = []
		#for i in range(_slot_equipment_types.size() -_slot_equipment_ids.size()):
			#actor._data['Equipment'].append(null)
	
	# Load or Create entries for each slot defined in ActorDef
	#for equipment_id in equipt_items:
		#if !equipment_id or equipment_id == '':
			#_slot_equipment_ids.append(null)
		#else:
			#_slot_equipment_ids.append(equipment_id)

#func save_equipt_items()->Array:
	#return _slot_equipment_ids

## Return true if actor can equipt item in slot
#func has_slot(slot:String)->bool:
	#return _slot_equipment_ids.has(slot)

func get_index_of_slot_with_type(slot_type:String)->int:
	var slot_set_index = _slot_set_key_mapping.find(slot_type)
	if slot_set_index < 0:
		return -1
	var slot_set_data = _item_slot_sets_datas[slot_set_index]
	return slot_set_data.get('IndexOffset', -1)

func get_equipt_items_of_slot_type(slot_type:String)->Array:
	if slot_type == "Weapon":
		var weapons = []
		var main_hand = get_primary_weapon()
		if main_hand: weapons.append(main_hand)
		var offhand = get_offhand_weapon()
		if offhand and offhand != main_hand: weapons.append(offhand)
		return weapons
	var slot_set_index = _slot_set_key_mapping.find(slot_type)
	if slot_set_index < 0:
		return []
	var slot_set_data = _item_slot_sets_datas[slot_set_index]
	var index_offset = slot_set_data['IndexOffset']
	var sub_slot_count = slot_set_data['Count']
	var out_list = []
	for sub_index in range(sub_slot_count):
		var item_id = get_item_id_in_slot(index_offset + sub_index)
		if item_id:
			var item = ItemLibrary.get_item(item_id)
			if item:
				out_list.append(item)
	return out_list

func get_slot_equipment_type(index:int)->String:
	if index < 0 or index >= _raw_to_slot_set_mapping.size():
		return ''
	var slot_set_ref = _raw_to_slot_set_mapping[index]
	return slot_set_ref['SlotSetKey']

func has_equipment_in_slot(index:int, equipment:BaseEquipmentItem=null)->bool:
	if index < 0 or index >= _raw_item_slots.size():
		return false
	if equipment:
		return _raw_item_slots[index] == equipment.Id
	return _raw_item_slots[index] != null

## Returns slot index of equipment if it is equipped
func get_slot_of_equipt_item(equipment:BaseEquipmentItem)->int:
	return _raw_item_slots.find(equipment.Id)

func get_equipment_in_slot(index:int)->BaseEquipmentItem:
	var item = get_item_in_slot(index)
	if item and item is BaseEquipmentItem:
		return item
	return null

func list_equipment()->Array:
	return list_items()

func can_equip_item(equipment:BaseEquipmentItem)->bool:
	if !equipment:
		return false
	var slot = equipment.get_equipment_slot_type()
	if slot != "Weapon" and !_slot_set_key_mapping.has(slot):
		return false
	#var stat_req = equipment.get_required_stat()
	#for stat_name in stat_req.keys():
		#var req_stat_val = stat_req[stat_name]
		#var stat_val = _actor.stats.get_stat(stat_name, 0)
		#if stat_val < req_stat_val:
			#return false
	return true

func remove_item(item_id:String, supress_signal:bool=false):
	if not _raw_item_slots.has(item_id):
		return
	# Might need to change hands if item is in Mainhand or Offhand
	var main_hand_index = -1
	var off_hand_index = -1
	for index in range(_raw_item_slots.size()):
		var slot_item_id = _raw_item_slots[index]
		if slot_item_id == item_id:
			if _slot_set_key_mapping[index] == "MainHand":
				main_hand_index = index
			if _slot_set_key_mapping[index] == "OffHand":
				off_hand_index = index
	
	var in_main_hand = main_hand_index >= 0
	var in_off_hand = off_hand_index >= 0
	
	# In both hands
	if in_off_hand and in_main_hand:
		# Remove from both hands
		_safe_set_slot(main_hand_index, null, true)
		_safe_set_slot(off_hand_index, null, supress_signal)
		if _actor.is_player:
			var item = ItemLibrary.get_item(item_id)
			PlayerInventory.add_item(item)
		return
		
	# Only in Off Hand: Check if main hand weapon can be two handed
	elif in_off_hand and not in_main_hand:
		main_hand_index = _slot_set_key_mapping.find("MainHand")
		var main_hand_item = get_equipment_in_slot(main_hand_index)
		if not main_hand_item: # No item in main_hand
			_safe_set_slot(off_hand_index, null, supress_signal)
			if _actor.is_player:
				var item = ItemLibrary.get_item(item_id)
				PlayerInventory.add_item(item)
			return
		var main_hand_weapon = main_hand_item as BaseWeaponEquipment
		if not main_hand_weapon: # Main Hand item is not weapon?
			_safe_set_slot(off_hand_index, null, supress_signal)
			if _actor.is_player:
				var item = ItemLibrary.get_item(item_id)
				PlayerInventory.add_item(item)
			return
		# Move main hand weapon to both hands
		if (main_hand_weapon.get_weapon_class() == BaseWeaponEquipment.WeaponClasses.Medium
			or main_hand_weapon.get_weapon_class() == BaseWeaponEquipment.WeaponClasses.Heavy):
			_safe_set_slot(off_hand_index, main_hand_weapon, supress_signal)
			if _actor.is_player:
				var item = ItemLibrary.get_item(item_id)
				PlayerInventory.add_item(item)
		else: # Can't two hand Main Hand
			_safe_set_slot(off_hand_index, null, supress_signal)
			if _actor.is_player:
				var item = ItemLibrary.get_item(item_id)
				PlayerInventory.add_item(item)
			return
			
	
	# Only in Main Hand
	elif in_main_hand and not in_off_hand:
		off_hand_index = _slot_set_key_mapping.find("OffHand")
		var off_hand_item = get_equipment_in_slot(off_hand_index)
		if not off_hand_item: # No item in off_hand
			_safe_set_slot(main_hand_index, null, supress_signal)
			if _actor.is_player:
				var item = ItemLibrary.get_item(item_id)
				PlayerInventory.add_item(item)
			return
		var off_hand_weapon = off_hand_item as BaseWeaponEquipment
		if not off_hand_weapon: # Off Hand item is not weapon
			_safe_set_slot(main_hand_index, null, supress_signal)
			if _actor.is_player:
				var item = ItemLibrary.get_item(item_id)
				PlayerInventory.add_item(item)
			return 
		# Move off hand weapon to main hands
		_safe_set_slot(off_hand_index, null, true)
		_safe_set_slot(main_hand_index, off_hand_weapon, supress_signal)
		if _actor.is_player:
			var item = ItemLibrary.get_item(item_id)
			PlayerInventory.add_item(item)
	
	# Isn't in either hand
	else:
		var index = _raw_item_slots.find(item_id)
		_safe_set_slot(index, null, supress_signal)
		if _actor.is_player:
			var item = ItemLibrary.get_item(item_id)
			PlayerInventory.add_item(item)
	

func remove_equipment(equipment:BaseEquipmentItem, supress_signal:bool = false):
	return remove_item(equipment.Id, supress_signal)

# Set equipment to a slot and inform old and new equipment of change
func _safe_set_slot(index:int, equipment:BaseEquipmentItem, supress_signal:bool=false):
	var old_equipment = get_equipment_in_slot(index)
	if old_equipment:
		if equipment and old_equipment.Id == equipment.Id:
			return
		else:
			_raw_item_slots[index] = null
	if equipment:
		_raw_item_slots[index] = equipment.Id
	if not supress_signal:
		items_changed.emit()
	
## Try to equip the item to the first open slot for it's type. If no open slots are found, replace first if allowed
func try_equip_item(equipment:BaseEquipmentItem, replace:bool=false)->bool:
	var slot_type = equipment.get_equipment_slot_type()
	if slot_type == "Weapon":
		var weapon = equipment as BaseWeaponEquipment
		slot_type = "MainHand"
		if weapon.get_weapon_class() == BaseWeaponEquipment.WeaponClasses.Light:
			var have_weapon = get_primary_weapon()
			if have_weapon and have_weapon.get_weapon_class() == BaseWeaponEquipment.WeaponClasses.Light:
				slot_type = "OffHand"
			
	if not _slot_set_key_mapping.has(slot_type):
		# No slot for item
		return false
	var index = _slot_set_key_mapping.find(slot_type)
	return try_set_item_in_slot(equipment, index, replace)

func try_set_item_in_slot(item:BaseItem, index:int, allow_replace:bool=false)->bool:
	var slot_type = get_slot_equipment_type(index)
	
	if not can_set_item_in_slot(item, index, allow_replace):
		return false
		
	# Non-Weapon OffHand: Remove Primary if two handing Heavy Weapon
	if slot_type == "OffHand" and not item is BaseWeaponEquipment:
		if is_two_handing():
			var two_hand_weapon = get_primary_weapon()
			if two_hand_weapon.get_weapon_class() == BaseWeaponEquipment.WeaponClasses.Heavy:
				remove_equipment(two_hand_weapon, true)
			else:
				_raw_item_slots[index] = null
	
	if not item is BaseWeaponEquipment:
		_safe_set_slot(index, item)
		return true
		
		
	var weapon = item as BaseWeaponEquipment
	var main_hand_index = _slot_set_key_mapping.find("MainHand")
	var off_hand_index = _slot_set_key_mapping.find("OffHand")
	var current_primary = get_primary_weapon()
	var current_offhand = get_item_in_slot(off_hand_index)
	if index != main_hand_index and index != off_hand_index:
		printerr("EquipmentHolder.try_set_item_in_slot: Attempted to set weapon '%s' in non-hand slot %s." % [item.Id, index])
		return false
	# For Heavy Weapons: Equipt to both hands
	if weapon.get_weapon_class() == BaseWeaponEquipment.WeaponClasses.Heavy:
		if not allow_replace and (current_primary or current_offhand):
			return false
		if current_primary:
			remove_equipment(current_primary, true)
		if current_offhand:
			remove_equipment(current_offhand, true)
			
		_safe_set_slot(main_hand_index, item, true)
		_safe_set_slot(off_hand_index, item, true)
		items_changed.emit()
		return true
	
	# For Medium Weapons: Equipt to both hands if off_hand is empty
	elif weapon.get_weapon_class() == BaseWeaponEquipment.WeaponClasses.Medium:
		# Equipting to off hand / two handing
		if index == off_hand_index:
			if not allow_replace and (current_primary or current_offhand):
				return false
			if current_offhand:
				remove_equipment(current_offhand, true)
			if current_primary:
				remove_equipment(current_primary, true)
			_safe_set_slot(main_hand_index, item, true)
			_safe_set_slot(off_hand_index, item, true)
			items_changed.emit()
			return true
		# Equipting to main hand
		elif index == main_hand_index:
			if not allow_replace and current_primary:
				return false
			if current_primary:
				remove_equipment(current_primary, true)
				# Was two handing
				if current_offhand and current_primary.Id == current_offhand.Id:
					current_offhand = null
			if _raw_item_slots[off_hand_index] == null: # Off hand is empty
				_safe_set_slot(off_hand_index, item, true)
			_safe_set_slot(main_hand_index, item, true)
			items_changed.emit()
			return true
	# For Light Weapons: Equipt to off hand only when main hand is empty or has light weapon
	elif weapon.get_weapon_class() == BaseWeaponEquipment.WeaponClasses.Light:
		if index == off_hand_index:
			if not current_primary: # Force over to main hand
				index = main_hand_index
			elif not current_primary.get_weapon_class() == BaseWeaponEquipment.WeaponClasses.Light:
				index = main_hand_index # Force over to main hand
			elif not allow_replace and current_offhand:
				return false
			elif current_offhand:
				remove_equipment(current_offhand, true)
		if index == main_hand_index:
			if not allow_replace and current_primary:
				return false
			if current_primary:
				remove_equipment(current_primary, true)
		_safe_set_slot(index, item, true)
		items_changed.emit()
		return true
		
	printerr("RquipmentHolder.try_set_item_in_slot: Unhandled case. Item: %s | Slot: %s | AllowReplace: %s" % [item.Id, index, allow_replace] )
	return false

func _can_slot_set_accept_item(slot_set_data:Dictionary, item:BaseItem)->bool:
	if not item is BaseWeaponEquipment:
		return super(slot_set_data, item)
	var weapon = item as BaseWeaponEquipment
	var slot_key = slot_set_data.get("Key")
	if weapon.get_weapon_class() == BaseWeaponEquipment.WeaponClasses.Heavy:
		return slot_key == "MainHand" or slot_key == "OffHand"
	elif weapon.get_weapon_class() == BaseWeaponEquipment.WeaponClasses.Medium:
		return slot_key == "MainHand" or slot_key == "OffHand"
	elif weapon.get_weapon_class() == BaseWeaponEquipment.WeaponClasses.Light:
		return slot_key == "MainHand" or slot_key == "OffHand"
	return false
	#if !can_equip_item(equipment):
		#if LOGGING: print("Does not meet stat requirments")
		#return false
	#
	#var equipment_slot_type = equipment.get_equipment_slot_type()
	#if equipment_slot_type == "Weapon":
		#equipment_slot_type = "MainHand"
		#var weapon = (equipment as BaseWeaponEquipment)
		#if weapon:
			## For Light weapons, see if MainHand is occupied, then try OffHand
			#var main_hand_index = _get_first_or_open_slot_of_type('MainHand')
			#var current_weapon = get_equipment_in_slot(main_hand_index)
			#if (current_weapon and weapon.get_weapon_class() == BaseWeaponEquipment.WeaponClasses.Light
				#and current_weapon.get_weapon_class() == BaseWeaponEquipment.WeaponClasses.Light):
				#equipment_slot_type = "OffHand"
				#
			#
	#var first_found_slot = _get_first_or_open_slot_of_type(equipment_slot_type)
	#if first_found_slot >= 0:
		#if replace or not has_equipment_in_slot(first_found_slot):
			#equip_item_to_slot(first_found_slot, equipment)
			#return true
	#return false

func _get_single_equipment_of_type(slot_type)->BaseEquipmentItem:
	var items = get_equipt_items_of_slot_type(slot_type)
	if items.size() > 1:
		printerr("EquipmentHolder._get_single_equipment_of_type: Multiple '%s' slots found on actor '%s'." % [slot_type, _actor.id])
	if items.size() > 0:
		return items[0]
	return null

func get_bag_equipment()->BaseBagEquipment:
	for item in list_equipment():
		if item is BaseBagEquipment:
			return item
	#var bag = _get_single_equipment_of_type("Bag")
	#if bag: 
		#if bag is BaseBagEquipment:
			#return bag as BaseBagEquipment
		#printerr("EquipmentHolder.get_bag_equipment: Equipt Item '%s' is not of type 'BaseBagEquipment'." % [bag.Id])
	return null

func get_que_equipment()->BaseQueEquipment:
	for item in list_equipment():
		if item is BaseQueEquipment:
			return item
	return null

func is_two_handing()->bool:
	var main_hand_slot_index = _slot_set_key_mapping.find("MainHand")
	if main_hand_slot_index < 0:
		return false
	var off_hand_slot_index = _slot_set_key_mapping.find("OffHand")
	if off_hand_slot_index < 0:
		return false
	var main_hand_item_id = get_item_id_in_slot(main_hand_slot_index)
	var off_hand_item_id = get_item_id_in_slot(off_hand_slot_index)
	if main_hand_item_id == null or off_hand_item_id == null:
		return false
	return main_hand_item_id == off_hand_item_id

func get_primary_weapon()->BaseWeaponEquipment:
	var main_hand_slot_index = _slot_set_key_mapping.find("MainHand")
	if main_hand_slot_index < 0:
		return null
	var item = get_equipment_in_slot(main_hand_slot_index)
	if item is BaseWeaponEquipment:
		return item as BaseWeaponEquipment
	return null

func get_offhand_weapon()->BaseWeaponEquipment:
	if is_two_handing():
		return null
	var off_hand_slot_index = _slot_set_key_mapping.find("OffHand")
	if off_hand_slot_index < 0:
		return null
	var item = get_equipment_in_slot(off_hand_slot_index)
	if item is BaseWeaponEquipment:
		return item as BaseWeaponEquipment
	return null

func get_filtered_weapons(weapon_filter)->Array:
	var out_arr = []
	
	var fall_back_to_unarmed = weapon_filter.get("FallbackToUnarmed", true)
	var range_melee_filter = weapon_filter.get("LimitRangeMelee", "MatchPrimary")
	var include_ranged = range_melee_filter == "Range" or range_melee_filter == "Either"
	var include_melee = range_melee_filter == "Melee" or range_melee_filter == "Either"
	var primary_weapon = self.get_primary_weapon()
	if range_melee_filter == "MatchPrimary":
		if not primary_weapon:
			return []
		include_ranged = primary_weapon.is_ranged_weapon()
		include_melee = primary_weapon.is_melee_weapon()
	
	var included_weapon_ids = []
	var index = 0
	for slot in weapon_filter.get("IncludeSlots", []):
		if slot == "Primary":
			slot = "Weapon"
		if slot == "TwoHand":
			if self.is_two_handing():
				slot = "Weapon"
			else:
				continue
		for weapon in self.get_equipt_items_of_slot_type(slot):
			if weapon is BaseWeaponEquipment:
				if included_weapon_ids.has(weapon.Id):
					continue
				if not ( # Match Ranged or Melee requirement
					(include_ranged and weapon.is_ranged_weapon()) 
					or (include_melee and weapon.is_melee_weapon())
				):
					continue
				out_arr.append(weapon)
				included_weapon_ids.append(weapon.Id)
				index += 1
	return out_arr

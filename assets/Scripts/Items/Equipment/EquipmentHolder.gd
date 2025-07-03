class_name EquipmentHolder
extends BaseItemHolder

var _hand_count = 0

var _is_two_handing:bool = false
var _is_dual_handing:bool = false

func _debug_name()->String:
	return "EquipmentHolder"

func _init(actor) -> void:
	super(actor)


func get_tags_added_to_actor()->Array:
	var out_list = []
	if _is_two_handing:
		out_list.append("TwoHand")
	if _is_dual_handing:
		out_list.append("DualHand")
	return out_list
		

func _load_slots_sets_data()->Array:
	var equipment_data = _actor.actor_data.get("EquipmentData", {})
	var slots = equipment_data.get("EquipmentSlots", [])
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
	_hand_count = equipment_data.get("HandCount", 0)
	if _hand_count > 0:
		out_dict['Hands'] = {
			"Key": "Hands",
			"DisplayName":"Hands",
			"Count": _hand_count,
			"IsHandSlots": true,
			"FilterData":{"RequiredTags":["Tool"]}
		}
		
	return out_dict.values()


func validate_items():
	_build_slots_list()

func list_equipment()->Array:
	return list_items()

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

########################
##     Hand Logic     ##
########################
func get_first_hand_index()->int:
	var index = _slot_set_key_mapping.find("Hands")
	if index < 0:
		return -1
	return  _item_slot_sets_datas[index].get("IndexOffset", -1)

func get_first_hand_tool()->BaseToolEquipment:
	var slot_set_index = _slot_set_key_mapping.find("Hands")
	if slot_set_index < 0:
		return null
	var slot_index =  _item_slot_sets_datas[slot_set_index].get("IndexOffset", -1)
	var item = get_item_in_slot(slot_index)
	if not item is BaseToolEquipment:
		return null
	return item

func list_all_hand_indexes()->Array:
	var mainhand_index = get_first_hand_index()
	return range(mainhand_index, mainhand_index + _hand_count)

func list_all_tools_in_hands()->Array:
	var out_list = []
	for i in list_all_hand_indexes():
		var item = get_item_in_slot(i)
		if item and not out_list.has(item):
			out_list.append(item)
	return out_list

func list_offhand_indexes()->Array:
	var mainhand_index = get_first_hand_index()
	return range(mainhand_index+1, mainhand_index + _hand_count)

func list_tools_in_offhands()->Array:
	var out_list = []
	for i in list_offhand_indexes():
		var item = get_item_in_slot(i)
		if item and not out_list.has(item):
			out_list.append(item)
	return out_list

# For Ease of Life, tools can be drop in any hand slot 
func get_auto_hand_index(item:BaseItem, requested_slot_index:int, allow_replace:bool = true)->int:
	var slot_index = requested_slot_index	
	# Check that item is Tool
	var tool = item as BaseToolEquipment
	if !tool:
		printerr("EquipmentHolder.can_set_item_in_slot: Non-Tool Item attempted to go in HandSlot")
		return false
	
	var firsthand_index = get_first_hand_index()
	var is_going_to_mainhand = requested_slot_index == firsthand_index
	
	if is_going_to_mainhand:
		if ( 
			# Non-MainHand Tool, push to OffHand
			not _can_use_tool_in_mainhand(tool) 
			# Could Off and MainHand is full - Prevent setting single Dualable weapon
			#or (_can_use_tool_in_mainhand(tool) and _raw_item_slots[firsthand_index] == null)
		):
			# TODO: Assuming 2hands
			if _hand_count > 1:
				slot_index = firsthand_index + 1
				is_going_to_mainhand = false
		
	else: # Requested OffHand slot
		if (# Non-OffHand Tool, push to MainHand
			not _can_use_tool_in_offhand(tool)
			# Could MainHand and MainHand is empty, push to MainHand
			or (_can_use_tool_in_mainhand(tool) and _raw_item_slots[firsthand_index] == null)
		):
			return firsthand_index
		# We are 2Hand and current tool can't be 1hand, Push to main
		if is_two_handing():
			var main_hand_item = get_item_in_slot(firsthand_index)
			if main_hand_item and not _can_use_tool_in_one_hands(main_hand_item):
				# Check that new tool can go to main - No, Auto Swap will fix it later
				# and we need to make sure current MainHand is removed
				#if _can_use_tool_in_mainhand(tool):
				return firsthand_index
				
			
	return slot_index

## Get Items that will be removed if current item is added to slot.
## Should only be used by ItemHelper
func _get_items_removed_if_new_item_added(slot_index:int, item:BaseItem)->Array:
	# Only Hands require special logic
	if get_slot_set_key_for_index(slot_index) != "Hands":
		return super(slot_index, item)
		
	return list_all_tools_in_hands()


func can_set_item_in_slot(item:BaseItem, index:int, allow_replace:bool=false)->bool:
	# Only Hands require special logic
	if get_slot_set_key_for_index(index) != "Hands":
		return super(item, index, allow_replace)
	
	if not (item is BaseToolEquipment):
		printerr("EquipmentHolder.can_set_item_in_slot: Non-Tool Item attempted to go in HandSlot")
		return false
	
	# Hand logic doesn't actually prevent items from being equip
	if not allow_replace:
		return _raw_item_slots[index] == null
	return true

func _on_item_added_to_slot(item:BaseItem, index:int):
	auto_order_hand_items()

func _on_item_removed(item_id:String, supressing_signals:bool):
	# Skip hand logic when mid transaction
	if supressing_signals:
		return
	auto_order_hand_items()

# Correct for toosl in hands and set HandStates after some change
func auto_order_hand_items(): 
	# Skip Logic if one/no hands
	if _hand_count <= 1:
		return
	
	var hand_indexes = list_all_hand_indexes()
	var mainhand_index = get_first_hand_index()
	var mainhand_item = get_item_in_slot(mainhand_index)
	
	# Check that MainHand is Valid
	if mainhand_item == null:
		# When MainHand is empy, OffHand weapons need to be moved over to MainHand
		for i in list_offhand_indexes():
			var item_in_offhand = get_item_in_slot(i)
			if item_in_offhand and item_in_offhand is BaseToolEquipment:
				if _can_use_tool_in_mainhand(item_in_offhand):
					# Move fist found/valid OffHand item to MainHand
					_raw_item_slots[mainhand_index] = _raw_item_slots[i]
					#TODO: Instea of nulling out _raw_slots, do an invaid items cache
					_raw_item_slots[i] = null
					break
	# MainHand Item should not be in MainHand
	elif not _can_use_tool_in_mainhand(mainhand_item):
		# Move to offhand
		#TODO: Assuming 2Hand
		for i in list_offhand_indexes():
			_raw_item_slots[i] = mainhand_item.Id
			_raw_item_slots[mainhand_index] = null
			break
	
	# Check OffHands are valid
	for offhand_index in list_offhand_indexes():
		var offhand_item = get_item_in_slot(offhand_index)
		if offhand_item and not _can_use_tool_in_offhand(offhand_item):
			#TODO: Instea of nulling out _raw_slots, do an invaid items cache
			_raw_item_slots[offhand_index] = null
	
	# Clear out HandStates
	_is_two_handing = false
	_is_dual_handing = false
	
	# Check 2 Handing conditions
	if mainhand_item:
		# MainHand Item must be two handed
		if not _can_use_tool_in_one_hands(mainhand_item):
			#TODO: Assuming 2Hands
			# Clear any offhands
			for offhand_index in list_offhand_indexes():
				#TODO: Instea of nulling out _raw_slots, do an invaid items cache
				_raw_item_slots[offhand_index] = null
			_is_two_handing = true
		
		# MainHand Item could be two handed
		elif _can_use_tool_in_two_hands(mainhand_item):
			# Check for open offhands
			var open_offhand = false
			for offhand_index in list_offhand_indexes():
				if _raw_item_slots[offhand_index] == null:
					open_offhand = true
					break
			_is_two_handing = open_offhand
	
	# Check Dual Handing conditions
	if mainhand_item and mainhand_item is BaseWeaponEquipment:
		var offhand_weapon = get_offhand_weapon()
		if (offhand_weapon and 
			(offhand_weapon.is_melee_weapon() == mainhand_item.is_melee_weapon()
			or offhand_weapon.is_ranged_weapon() == mainhand_item.is_ranged_weapon())):
				_is_dual_handing = true


func _can_use_tool_in_mainhand(item:BaseToolEquipment):
	var hand_conditions = _actor.get_hands_conditions_for_tool(item)
	if hand_conditions.size() == 0:
		return false
	return hand_conditions.get("CanMainHand", false)
	
func _can_use_tool_in_offhand(item:BaseToolEquipment):
	var hand_conditions = _actor.get_hands_conditions_for_tool(item)
	if hand_conditions.size() == 0:
		return true
	if not hand_conditions.get("CanOffHand", false):
		return false
	
	var main_hand_tool = get_first_hand_tool()
	for offhand_req in hand_conditions.get("OffHandReq", []):
		if TagHelper.check_tag_filters("MainHandTagFilters", offhand_req, main_hand_tool):
			return true
	return false

func _can_use_tool_in_one_hands(item:BaseToolEquipment):
	var hand_conditions = _actor.get_hands_conditions_for_tool(item)
	if hand_conditions.size() == 0:
		return true
	return hand_conditions.get("CanOneHand", false)
	
func _can_use_tool_in_two_hands(item:BaseToolEquipment):
	var hand_conditions = _actor.get_hands_conditions_for_tool(item)
	if hand_conditions.size() == 0:
		return false
	return hand_conditions.get("CanTwoHand", false)

########################
##      Weapons       ##
########################
func is_two_handing()->bool:
	return _is_two_handing

func get_primary_weapon()->BaseWeaponEquipment:
	var mainhand_slot_index = get_first_hand_index()
	if mainhand_slot_index < 0:
		return null
	var item = get_item_in_slot(mainhand_slot_index)
	if item is BaseWeaponEquipment:
		return item as BaseWeaponEquipment
	return null

func get_offhand_weapon()->BaseWeaponEquipment:
	if is_two_handing():
		return get_primary_weapon()
	var offhands = list_offhand_indexes()
	if offhands.size() == 0:
		return null
	var off_hand_slot_index = offhands[0]#_slot_set_key_mapping.find("OffHand")
	if off_hand_slot_index < 0:
		return null
	var item = get_item_in_slot(off_hand_slot_index)
	if item is BaseWeaponEquipment:
		return item as BaseWeaponEquipment
	return null

func get_filtered_weapons(weapon_filter)->Array:
	var out_arr = []
	
	var fall_back_to_unarmed = weapon_filter.get("FallbackToUnarmed", true)
	var include_classes = weapon_filter.get("LimitClasses", [])
	if include_classes.size() == 0:
		include_classes = ["Light", "Medium", "Heavy"]
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
				var wpn_class = weapon.get_weapon_class()
				var wpn_class_str = BaseWeaponEquipment.WeaponClasses.keys()[wpn_class]
				if not include_classes.has(wpn_class_str):
					continue
				out_arr.append(weapon)
				included_weapon_ids.append(weapon.Id)
				index += 1
	return out_arr

func get_bag_equipment()->BaseBagEquipment:
	for item in list_equipment():
		if item is BaseBagEquipment:
			return item
	return null

func get_que_equipment()->BaseQueEquipment:
	for item in list_equipment():
		if item is BaseQueEquipment:
			return item
	return null

##	Weapon Transfer Logic
# Adding Light
#	To Main Hand:
#		NA
#	To  Off Hand: 
#		if MainHand is Light:
#			Normal Logic
#		else:
#			Place in Main
# Adding Medium:
#	To Main Hand:
#		If Versitile:
#			If OffHand is Empty:
#				Place in Off and



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

#func get_index_of_slot_with_type(slot_type:String)->int:
	#var slot_set_index = _slot_set_key_mapping.find(slot_type)
	#if slot_set_index < 0:
		#return -1
	#var slot_set_data = _item_slot_sets_datas[slot_set_index]
	#return slot_set_data.get('IndexOffset', -1)

#func try_equip_weapon(item:BaseWeaponEquipment, holder:BaseItemHolder, slot_index:int, allow_replace:bool = true)->String:

#func has_equipment_in_slot(index:int, equipment:BaseEquipmentItem=null)->bool:
	#if index < 0 or index >= _raw_item_slots.size():
		#return false
	#if equipment:
		#return _raw_item_slots[index] == equipment.Id
	#return _raw_item_slots[index] != null

### Returns slot index of equipment if it is equipped
#func get_slot_of_equipt_item(equipment:BaseEquipmentItem)->int:
	#return _raw_item_slots.find(equipment.Id)

#func get_item_in_slot(index:int)->BaseEquipmentItem:
	#var item = get_item_in_slot(index)
	#if item and item is BaseEquipmentItem:
		#return item
	#return null

#func can_equip_item(equipment:BaseEquipmentItem)->bool:
	#if !equipment:
		#return false
	#var slot = equipment.get_equipment_slot_type()
	#if slot != "Weapon" and !_slot_set_key_mapping.has(slot):
		#return false
	##var stat_req = equipment.get_required_stat()
	##for stat_name in stat_req.keys():
		##var req_stat_val = stat_req[stat_name]
		##var stat_val = _actor.stats.get_stat(stat_name, 0)
		##if stat_val < req_stat_val:
			##return false
	#return true

#func remove_item(item_id:String, supress_signal:bool=false):
	#if not _raw_item_slots.has(item_id):
		#return
	#if not ItemHelper.transering_items.has(item_id):
		#printerr("Transfering Item outside of ItemHelper: %s | %s " % [item_id, _actor.Id])
	## Might need to change hands if item is in Mainhand or Offhand
	#var main_hand_index = -1
	#var off_hand_index = -1
	#for index in range(_raw_item_slots.size()):
		#var slot_item_id = _raw_item_slots[index]
		#if slot_item_id == item_id:
			#if _slot_set_key_mapping[index] == "MainHand":
				#main_hand_index = index
			#if _slot_set_key_mapping[index] == "OffHand":
				#off_hand_index = index
	#
	#var in_main_hand = main_hand_index >= 0
	#var in_off_hand = off_hand_index >= 0
	#
	## In both hands
	#if in_off_hand and in_main_hand:
		## Remove from both hands
		#_safe_set_slot(main_hand_index, null, true)
		#_safe_set_slot(off_hand_index, null, supress_signal)
		#if _actor.is_player:
			#var item = ItemLibrary.get_item(item_id)
			#PlayerInventory.add_item(item)
		#return
		#
	## Only in Off Hand: Check if main hand weapon can be two handed
	#elif in_off_hand and not in_main_hand:
		#main_hand_index = _slot_set_key_mapping.find("MainHand")
		#var main_hand_item = get_item_in_slot(main_hand_index)
		#if not main_hand_item: # No item in main_hand
			#_safe_set_slot(off_hand_index, null, supress_signal)
			#if _actor.is_player:
				#var item = ItemLibrary.get_item(item_id)
				#PlayerInventory.add_item(item)
			#return
		#var main_hand_weapon = main_hand_item as BaseWeaponEquipment
		#if not main_hand_weapon: # Main Hand item is not weapon?
			#_safe_set_slot(off_hand_index, null, supress_signal)
			#if _actor.is_player:
				#var item = ItemLibrary.get_item(item_id)
				#PlayerInventory.add_item(item)
			#return
		## Move main hand weapon to both hands
		#if (main_hand_weapon.get_weapon_class() == BaseWeaponEquipment.WeaponClasses.Medium
			#or main_hand_weapon.get_weapon_class() == BaseWeaponEquipment.WeaponClasses.Heavy):
			#_safe_set_slot(off_hand_index, main_hand_weapon, supress_signal)
			#if _actor.is_player:
				#var item = ItemLibrary.get_item(item_id)
				#PlayerInventory.add_item(item)
		#else: # Can't two hand Main Hand
			#_safe_set_slot(off_hand_index, null, supress_signal)
			#if _actor.is_player:
				#var item = ItemLibrary.get_item(item_id)
				#PlayerInventory.add_item(item)
			#return
			#
	#
	## Only in Main Hand
	#elif in_main_hand and not in_off_hand:
		#off_hand_index = _slot_set_key_mapping.find("OffHand")
		#var off_hand_item = get_item_in_slot(off_hand_index)
		#if not off_hand_item: # No item in off_hand
			#_safe_set_slot(main_hand_index, null, supress_signal)
			#if _actor.is_player:
				#var item = ItemLibrary.get_item(item_id)
				#PlayerInventory.add_item(item)
			#return
		#var off_hand_weapon = off_hand_item as BaseWeaponEquipment
		#if not off_hand_weapon: # Off Hand item is not weapon
			#_safe_set_slot(main_hand_index, null, supress_signal)
			#if _actor.is_player:
				#var item = ItemLibrary.get_item(item_id)
				#PlayerInventory.add_item(item)
			#return 
		## Move off hand weapon to main hands
		#_safe_set_slot(off_hand_index, null, true)
		#_safe_set_slot(main_hand_index, off_hand_weapon, supress_signal)
		#if _actor.is_player:
			#var item = ItemLibrary.get_item(item_id)
			#PlayerInventory.add_item(item)
	#
	## Isn't in either hand
	#else:
		#var index = _raw_item_slots.find(item_id)
		#_safe_set_slot(index, null, supress_signal)
		#if _actor.is_player:
			#var item = ItemLibrary.get_item(item_id)
			#PlayerInventory.add_item(item)

#func remove_equipment(equipment:BaseEquipmentItem, supress_signal:bool = false):
	#return remove_item(equipment.Id, supress_signal)

## Set equipment to a slot and inform old and new equipment of change
#func _safe_set_slot(index:int, equipment:BaseEquipmentItem, supress_signal:bool=false):
	#var old_equipment = get_item_in_slot(index)
	#if old_equipment:
		#if equipment and old_equipment.Id == equipment.Id:
			#return
		#else:
			#_raw_item_slots[index] = null
	#if equipment:
		#_raw_item_slots[index] = equipment.Id
	#if not supress_signal:
		#items_changed.emit()
	


#func try_set_item_in_slot(item:BaseItem, index:int, allow_replace:bool=false)->bool:
	#var slot_type = get_slot_equipment_type(index)
	#
	#if not can_set_item_in_slot(item, index, allow_replace):
		#return false
		#
	## Non-Weapon OffHand: Remove Primary if two handing Heavy Weapon
	#if slot_type == "OffHand" and not item is BaseWeaponEquipment:
		#if is_two_handing():
			#var two_hand_weapon = get_primary_weapon()
			#if two_hand_weapon.get_weapon_class() == BaseWeaponEquipment.WeaponClasses.Heavy:
				#remove_equipment(two_hand_weapon, true)
			#else:
				#_raw_item_slots[index] = null
	#
	#if not item is BaseWeaponEquipment:
		#_safe_set_slot(index, item)
		#return true
		#
		#
	#var weapon = item as BaseWeaponEquipment
	#var main_hand_index = _slot_set_key_mapping.find("MainHand")
	#var off_hand_index = _slot_set_key_mapping.find("OffHand")
	#var current_primary = get_primary_weapon()
	#var current_offhand = get_item_in_slot(off_hand_index)
	#if index != main_hand_index and index != off_hand_index:
		#printerr("EquipmentHolder.try_set_item_in_slot: Attempted to set weapon '%s' in non-hand slot %s." % [item.Id, index])
		#return false
	## For Heavy Weapons: Equipt to both hands
	#if weapon.get_weapon_class() == BaseWeaponEquipment.WeaponClasses.Heavy:
		#if not allow_replace and (current_primary or current_offhand):
			#return false
		#if current_primary:
			#remove_equipment(current_primary, true)
		#if current_offhand:
			#remove_equipment(current_offhand, true)
			#
		#_safe_set_slot(main_hand_index, item, true)
		#_safe_set_slot(off_hand_index, item, true)
		#items_changed.emit()
		#return true
	#
	## For Medium Weapons: Equipt to both hands if off_hand is empty
	#elif weapon.get_weapon_class() == BaseWeaponEquipment.WeaponClasses.Medium:
		## Equipting to off hand / two handing
		#if index == off_hand_index:
			#if not allow_replace and (current_primary or current_offhand):
				#return false
			#if current_offhand:
				#remove_equipment(current_offhand, true)
			#if current_primary:
				#remove_equipment(current_primary, true)
			#_safe_set_slot(main_hand_index, item, true)
			#_safe_set_slot(off_hand_index, item, true)
			#items_changed.emit()
			#return true
		## Equipting to main hand
		#elif index == main_hand_index:
			#if not allow_replace and current_primary:
				#return false
			#if current_primary:
				#remove_equipment(current_primary, true)
				## Was two handing
				#if current_offhand and current_primary.Id == current_offhand.Id:
					#current_offhand = null
			#if _raw_item_slots[off_hand_index] == null: # Off hand is empty
				#_safe_set_slot(off_hand_index, item, true)
			#_safe_set_slot(main_hand_index, item, true)
			#items_changed.emit()
			#return true
	## For Light Weapons: Equipt to off hand only when main hand is empty or has light weapon
	#elif weapon.get_weapon_class() == BaseWeaponEquipment.WeaponClasses.Light:
		#if index == off_hand_index:
			#if not current_primary: # Force over to main hand
				#index = main_hand_index
			#elif not current_primary.get_weapon_class() == BaseWeaponEquipment.WeaponClasses.Light:
				#index = main_hand_index # Force over to main hand
			#elif not allow_replace and current_offhand:
				#return false
			#elif current_offhand:
				#remove_equipment(current_offhand, true)
		#if index == main_hand_index:
			#if not allow_replace and current_primary:
				#return false
			#if current_primary:
				#remove_equipment(current_primary, true)
		#_safe_set_slot(index, item, true)
		#items_changed.emit()
		#return true
		#
	#printerr("RquipmentHolder.try_set_item_in_slot: Unhandled case. Item: %s | Slot: %s | AllowReplace: %s" % [item.Id, index, allow_replace] )
	#return false

#func _get_single_equipment_of_type(slot_type)->BaseEquipmentItem:
	#var items = get_equipt_items_of_slot_type(slot_type)
	#if items.size() > 1:
		#printerr("EquipmentHolder._get_single_equipment_of_type: Multiple '%s' slots found on actor '%s'." % [slot_type, _actor.id])
	#if items.size() > 0:
		#return items[0]
	#return null

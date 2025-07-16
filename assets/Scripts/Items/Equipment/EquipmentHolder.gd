class_name EquipmentHolder
extends BaseItemHolder

var _hand_count = 0

var _is_unarmed:bool = false
var _is_two_handing:bool = false
var _is_dual_handing:bool = false

func _debug_name()->String:
	return "EquipmentHolder"

func _init(actor) -> void:
	super(actor)


func get_tags_added_to_actor()->Array:
	var out_list = []
	if _is_unarmed:
		out_list.append("Unarmed")
	if _is_two_handing:
		out_list.append("TwoHand")
	if _is_dual_handing:
		out_list.append("DualHand")
	return out_list
		

func _load_slots_sets_data()->Array:
	# Actors always have a slot for PageBook and SupplyBag
	var out_dict = {
		"PageBook": {
			"Key": "PageBook",
			"DisplayName":"PageBook",
			"Count": 1,
			"FilterData":{"RequiredTags":["PageBook"]}
		},
		"SupplyBag": {
			"Key": "SupplyBag",
			"DisplayName":"SupplyBag",
			"Count": 1,
			"FilterData":{"RequiredTags":["SupplyBag"]}
		}
	}
	var equipment_constraints = _actor.actor_data.get("EquipmentConstraints", {})
	_hand_count = equipment_constraints.get("HandCount", 0)
	if _hand_count > 0:
		out_dict['Hands'] = {
			"Key": "Hands",
			"DisplayName":"Hands",
			"Count": _hand_count,
			"IsHandSlots": true,
			"FilterData":{"RequiredTags":["Tool"]}
		}
	var apparel_slots = equipment_constraints.get("ApparelSlots", [])
	for slot in apparel_slots:
		if out_dict.keys().has(slot):
			printerr("EquipmentHolder._get_slots_sets_data: Actor '%s' has multiple '%s' slots." % [_actor.Id, slot])
			continue
		out_dict[slot] = {
			"Key": "Apparel:"+slot,
			"DisplayName":slot,
			"Count": 1,
			"FilterData":{"RequiredTags":["Apparel", slot]}
		}
	var trinkets = equipment_constraints.get("TrinketCount", 1)
	if trinkets > 0:
		out_dict["Trinket"] = {
			"Key": "Trinket",
			"DisplayName":"Trinket",
			"Count": trinkets,
			"FilterData":{"RequiredTags":["Apparel", "Trinket"]}
		}
	
		
	return out_dict.values()


func validate_items():
	_build_slots_list()
	auto_order_hand_items()

func list_equipment()->Array:
	return list_items()

func get_equipt_items_of_slot_type(slot_type:String)->Array:
	if slot_type == "MainHand":
		var weapons = []
		var main_hand = get_primary_weapon()
		if main_hand: weapons.append(main_hand)
		return weapons
	elif slot_type == "Weapon":
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
		# Non-OffHand Tool, push to MainHand
		if not _can_use_tool_in_offhand(tool):
			return firsthand_index
		# Could MainHand and MainHand is empty, push to MainHand
		if _can_use_tool_in_mainhand(tool) and _raw_item_slots[firsthand_index] == null:
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


#func can_set_item_in_slot(item:BaseItem, index:int, allow_replace:bool=false)->bool:
	## Only Hand Slots require special logic
	## If not hand slot - use default logic
	#if get_slot_set_key_for_index(index) != "Hands":
		#return super(item, index, allow_replace)
	#
	## If it is a hand slot, but not a Tool Item
	#if not (item is BaseToolEquipment):
		#return false
	#
	## Hand logic doesn't actually prevent items from being equip
	#if not allow_replace:
		#return _raw_item_slots[index] == null
	#return true

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
	_is_unarmed = false
	_is_two_handing = false
	_is_dual_handing = false
	
	# Check if Unarmed
	if not mainhand_item or not mainhand_item is BaseWeaponEquipment:
		_is_unarmed = true
	
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
		if not TagHelper.check_tag_filters("MainHandTagFilters", offhand_req, main_hand_tool):
			return false
	return true

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
	return _actor.get_tags().has("TwoHand")

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
		return null# get_primary_weapon()
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


########################
##      Apparel       ##
########################
func list_apparel()->Array:
	var out_list = []
	for equipment in list_equipment():
		if equipment is BaseApparelEquipment:
			out_list.append(equipment)
	return out_list
	
func get_total_apparel_stats()->Dictionary:
	var stats = {"Armor":0, "Ward":0}
	for equipment in list_equipment():
		if equipment is BaseApparelEquipment:
			stats["Armor"] += equipment.get_armor_value()
			stats["Ward"] += equipment.get_ward_value()
	return stats

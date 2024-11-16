class_name EquipmentHolder

const LOGGING = true

var _actor:BaseActor

var _slot_equipment_types:Array:
	get: return _actor.get_load_val("EquipmentSlots", [])
var _slot_equipment_ids:Array:
	get: return _actor.get_load_val("Equipment", [])

func _init(actor:BaseActor) -> void:
	self._actor = actor
	
	_slot_equipment_types = actor.get_load_val("EquipmentSlots", [])
	_slot_equipment_ids = actor.get_load_val("Equipment", [])
	if _slot_equipment_ids.size() < _slot_equipment_types.size():
		for i in range(_slot_equipment_types.size() -_slot_equipment_ids.size()):
			_slot_equipment_ids.append(null)
	# Load or Create entries for each slot defined in ActorDef
	#for equipment_id in equipt_items:
		#if !equipment_id or equipment_id == '':
			#_slot_equipment_ids.append(null)
		#else:
			#_slot_equipment_ids.append(equipment_id)

func save_equipt_items()->Array:
	return _slot_equipment_ids

## Return true if actor can equipt item in slot
func has_slot(slot:String)->bool:
	return _slot_equipment_ids.has(slot)

func get_equipt_items_of_slot_type(slot_type:String)->Array:
	var out_list = []
	for index in range(_slot_equipment_types.size()):
		if _slot_equipment_types[index] == slot_type:
			var item_id = _slot_equipment_ids[index]
			if item_id == null:
				continue
			var item = ItemLibrary.get_item(item_id)
			if item:
				out_list.append(item)
	return out_list

func get_slot_equipment_type(index:int)->String:
	if index < 0 or index >= _slot_equipment_types.size():
		return ''
	return _slot_equipment_types[index]

func has_equipment_in_slot(index:int, equipment:BaseEquipmentItem=null)->bool:
	if index < 0 or index >= _slot_equipment_types.size():
		return false
	if equipment:
		return _slot_equipment_ids[index] == equipment.Id
	return _slot_equipment_ids[index] != null

## Returns slot index of equipment if it is equipped
func get_slot_of_equipt_item(equipment:BaseEquipmentItem)->int:
	return _slot_equipment_ids.find(equipment.Id)

func get_equipment_in_slot(index:int)->BaseEquipmentItem:
	if index < 0 or index >= _slot_equipment_types.size():
		return null
	var item_id = _slot_equipment_ids[index]
	if item_id != null:
		return ItemLibrary.get_item(item_id)
	return null

func list_equipment()->Array:
	var out_list = []
	for equipment_id in _slot_equipment_ids:
		if equipment_id != null:
			var item = ItemLibrary.get_item(equipment_id)
			if item:
				out_list.append(item)
	return out_list

func remove_equipment(equipment:BaseEquipmentItem):
	var index = _slot_equipment_ids.find(equipment.Id)
	if index < 0:
		if LOGGING: print("Removeing Weapon: '%s' not found." %[equipment.Id])
		return
	var equipment_slot_type = equipment.get_equipment_slot_type()
	if LOGGING: print("Removeing Weapon: '%s' from slot %s:%s" %[equipment.Id, index, equipment_slot_type])
	
	# Remove an OffHand item
	if equipment_slot_type == "OffHand":
		var primary = get_primary_weapon()
		# If primary weapon is Medium, equipt it to the now open OffHand slot
		if primary and primary.get_weapon_class() == BaseWeaponEquipment.WeaponClasses.Medium and primary.Id != equipment.Id :
			if LOGGING: print("Removeing Weapon: Twohanding primary weapon '%s' to slot %s:%s" %[equipment.Id, index, equipment_slot_type])
			clear_slot(index, false)
			_slot_equipment_ids[index] = primary.Id
			_actor.equipment_changed.emit()
			return
	# Removeing a Weapon
	if equipment_slot_type == "Weapon":
		var primary = get_primary_weapon()
		var offhand = get_offhand_weapon()
		# Removing a wepon that was being two handed
		if primary and offhand and primary.Id == offhand.Id and primary.Id == equipment.Id:
			# Clear from all slots
			for i in range(_slot_equipment_ids.size()):
				if _slot_equipment_ids[i]  == equipment.Id:
					clear_slot(i, false)
			_actor.equipment_changed.emit()
			return
					
		# Removeing primary with an offhand weapon equip, move the offhand to main slot
		if primary == equipment and offhand and offhand != equipment:
			clear_slot(index, false)
			var off_hand_slot = _slot_equipment_ids.find(offhand.Id)
			_slot_equipment_ids[off_hand_slot] = null
			_slot_equipment_ids[index] = offhand.Id
			_actor.equipment_changed.emit()
			return
	
	clear_slot(index)

func clear_slot(index:int, emit_change:bool=true, skip_unbind:bool=false):
	if index < 0 or index >= _slot_equipment_types.size() or _slot_equipment_ids[index] == null:
		return null
	# Get current item
	var current_item = get_equipment_in_slot(index) 
	
	# Clear slot
	_slot_equipment_ids[index] = null
	
	# Unbind current item if it thinks it;s still bound
	if not skip_unbind and current_item and current_item.is_equipped_to_actor(_actor): 
			current_item.clear_equipt_actor()
		
	if emit_change:
		_actor.equipment_changed.emit()

func equip_item_to_slot(index:int, equipment:BaseEquipmentItem):
	if index < 0 or index >= _slot_equipment_types.size() or _slot_equipment_ids[index] == equipment.Id:
		return 
		
	var slot_type = _slot_equipment_types[index]
	var equipment_slot_type = equipment.get_equipment_slot_type()
	if LOGGING: print("Equiprting %s of type %s to slot %s:%s" %[equipment.ItemKey, equipment_slot_type, index, slot_type])
	
	# Weapons require special logic
	if equipment_slot_type == "Weapon":
		var weapon = (equipment as BaseWeaponEquipment)
		if !weapon:
			printerr("%s.EquipmentHolder: Attempted to equip non-weapon %s to 'Weapon' slot %s." % 
					[_actor.Id, equipment.Id, index])
			return
		return equip_weapon_to_slot(index, weapon)
	# Slot is open
	if _slot_equipment_ids[index] == null:
		index = index # Do nothing
	# Equipting offhand
	elif slot_type == "OffHand":
		var primary_weapon = get_primary_weapon()
		var offhand_weapon = get_offhand_weapon()
		# Two Handing a weapon
		if offhand_weapon and primary_weapon.Id == offhand_weapon.Id:
			# Two Handing a Heavy weapon, clear both hands
			if offhand_weapon.get_weapon_class() == BaseWeaponEquipment.WeaponClasses.Heavy:
				if LOGGING: print("Two Handed Heavy Case" )
				# Clear from all slots
				for i in range(_slot_equipment_ids.size()):
					if _slot_equipment_ids[i]  == offhand_weapon.Id:
						clear_slot(i, false)
			# Two Handing a meduim weapon, clear OffHand but don't unbind
			if offhand_weapon.get_weapon_class() == BaseWeaponEquipment.WeaponClasses.Medium:
				clear_slot(index, false, true)
		else:
			clear_slot(index, false)
			
			
	# Clear anythng else in slot but supress singal
	elif has_equipment_in_slot(index):
		clear_slot(index, false)
		
	# Set equipment in slot
	_slot_equipment_ids[index] = equipment.Id
	
	# Set equipment's actor if not already set
	if not equipment.is_equipped_to_actor(_actor): 
		equipment.set_equipt_actor(_actor, index)
	_actor.equipment_changed.emit()

func equip_weapon_to_slot(index:int, weapon:BaseWeaponEquipment):
	var slot_type = _slot_equipment_types[index]
		
	# Handle Heavy Weapons
	if weapon.get_weapon_class() == BaseWeaponEquipment.WeaponClasses.Heavy:
		var off_hand_slot = _get_first_or_open_slot_of_type("OffHand")
		if off_hand_slot < 0:
			printerr("%s.EquipmentHolder: Attempted to Heavy weapon %s without an 'OffHand' slot." % 
					[_actor.Id, weapon.Id, index])
			return
		else:
			clear_slot(off_hand_slot, false)
		_slot_equipment_ids[off_hand_slot] = weapon.Id
		
	# Handle Medium Weapons
	if weapon.get_weapon_class() == BaseWeaponEquipment.WeaponClasses.Medium:
		if slot_type == "OffHand":
			printerr("%s.EquipmentHolder: Attempted to Medium weapon %s to an 'OffHand' slot." % 
					[_actor.Id, weapon.Id, index])
			return
		# Clear any offhand weapons (non-weapon offhands are fine)
		_clear_offhand_weapons()
		# If offhand is open, two hand
		var open_offhand_id = _get_first_or_open_slot_of_type("OffHand")
		if open_offhand_id >= 0 and _slot_equipment_ids[open_offhand_id] == null:
			_slot_equipment_ids[open_offhand_id] = weapon.Id
	
	# Clear anythng else in slot
	if has_equipment_in_slot(index):
		clear_slot(index, false)
	# Set equipment in slot
	_slot_equipment_ids[index] = weapon.Id
	# Set equipment's actor if not already set
	if not weapon.is_equipped_to_actor(_actor): 
		weapon.set_equipt_actor(_actor, index)
	_actor.equipment_changed.emit()


func _clear_offhand_weapons():
	print("Cear offhand")
	for check_index in range(_slot_equipment_types.size()):
		if _slot_equipment_types[check_index] != "OffHand":
			continue
		var item_id = _slot_equipment_ids[check_index]
		print("Check: %s"%[item_id])
		if !item_id: 
			continue
		var item = ItemLibrary.get_item(item_id)
		if !item: 
			continue
		if (item is BaseEquipmentItem) and (item as BaseEquipmentItem).get_equipment_slot_type() == "Weapon":
			print("CLEAR: %s"%[item_id])
			clear_slot(check_index)
		

## Try to equip the item to the first open slot for it's type. If no open slots are found, replace first if allowed
func try_equip_item(equipment:BaseEquipmentItem, replace:bool=false)->bool:
	var equipment_slot_type = equipment.get_equipment_slot_type()
	if equipment_slot_type == "Weapon":
		equipment_slot_type = "MainHand"
		var weapon = (equipment as BaseWeaponEquipment)
		if weapon:
			# For Light weapons, see if MainHand is occupied, then try OffHand
			var main_hand_index = _get_first_or_open_slot_of_type('MainHand')
			var current_weapon = get_equipment_in_slot(main_hand_index)
			if (current_weapon and weapon.get_weapon_class() == BaseWeaponEquipment.WeaponClasses.Light
				and current_weapon.get_weapon_class() == BaseWeaponEquipment.WeaponClasses.Light):
				equipment_slot_type = "OffHand"
				
			
	var first_found_slot = _get_first_or_open_slot_of_type(equipment_slot_type)
	if first_found_slot >= 0:
		if replace or not has_equipment_in_slot(first_found_slot):
			equip_item_to_slot(first_found_slot, equipment)
			return true
	return false


func is_two_handing()->bool:
	var primary = get_primary_weapon()
	if !primary:
		return false
	var off_hand = get_offhand_weapon()
	if !off_hand:
		return false
	return primary.Id == off_hand.Id

func get_primary_weapon()->BaseWeaponEquipment:
	var main_hand_slot_index = _get_first_or_open_slot_of_type("MainHand")
	if main_hand_slot_index < 0:
		return null
	var item = get_equipment_in_slot(main_hand_slot_index)
	if item is BaseWeaponEquipment:
		return item as BaseWeaponEquipment
	return null

func get_offhand_weapon()->BaseWeaponEquipment:
	var main_hand_slot_index = _get_first_or_open_slot_of_type("OffHand")
	if main_hand_slot_index < 0:
		return null
	var item = get_equipment_in_slot(main_hand_slot_index)
	if item is BaseWeaponEquipment:
		return item as BaseWeaponEquipment
	return null

func get_total_equipment_armor()->int:
	var val = 0
	for equipment:BaseEquipmentItem in list_equipment():
		val +=  equipment.get_armor_value()
	return val

func get_total_equipment_ward()->int:
	var val = 0
	for equipment:BaseEquipmentItem in list_equipment():
		val +=  equipment.get_ward_value()
	return val

func _get_first_or_open_slot_of_type(slot_type:String)->int:
	var first_found_slot = -1
	for index in range(_slot_equipment_types.size()):
		var check_type = _slot_equipment_types[index]
		if check_type == slot_type:
			if not has_equipment_in_slot(index):
				return index
			elif first_found_slot < 0:
				first_found_slot = index
	return first_found_slot


#func equipt_que(que:BaseQueEquipment):
	#_set_equipment(BaseEquipmentItem.EquipmentSlots.Que, que)
#
#func equipt_bag(bag:BaseBagEquipment):
	#_set_equipment(BaseEquipmentItem.EquipmentSlots.Bag, bag)
#
#func equipt_armor(armor:BaseArmorEquipment):
	#var slot = armor.get_equip_slot()
	#_set_equipment(slot, armor)
#
#func equipt_trinket(armor:BaseArmorEquipment):
	#var slot = armor.get_equip_slot()
	#_set_equipment(slot, armor)
#
#func equipt_weapon(weapon:BaseWeaponEquipment, offhand:bool = false):
	#_set_equipment(BaseEquipmentItem.EquipmentSlots.Weapon, weapon)
#
#func _set_equipment(slot:BaseEquipmentItem.EquipmentSlots, item:BaseEquipmentItem):
	#if not _equipment_slot_to_item_id.keys().has(slot):
		#printerr("EquipmentHolder.set_equipment: Actor '%s' does not have slot of type '%s'." % [_actor.Id, slot])
		#return
	## Check if has an item in the slot
	#var current_item = get_item_in_slot(slot) 
	#if current_item and current_item.get_equipt_to_actor_id() == _actor.Id: 
		#current_item.clear_equipt_actor()
	#
	#_equipment_slot_to_item_id[slot] = item.Id
	#
	## Check if item has another owner
	#if item.get_equipt_to_actor_id() != self._actor.Id:
		#item.set_equipt_actor(self._actor)
	#_actor.stats.dirty_stats()


func get_all_stat_mods()->Array:
	var out_list = []
	for equipment_id in _slot_equipment_ids:
		if equipment_id and equipment_id != '':
			var equipment:BaseEquipmentItem = ItemLibrary.get_item(equipment_id)
			out_list.append_array(equipment.get_stat_mods())
	return out_list

#func get_weapon_attack_bonus(stat_name:String):
	#var main_hand_item = get_item_in_slot(EquipmentSlots.Weapon)

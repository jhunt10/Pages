class_name EquipmentHolder

var _actor:BaseActor

var _slot_equipment_types:Array=[]
var _slot_equipment_ids:Array=[]

func _init(actor:BaseActor) -> void:
	self._actor = actor
	
	_slot_equipment_types = actor.get_load_val("EquipmentSlots", [])
	var equipt_items:Array = actor.get_load_val("Equipment", {})
	# Load or Create entries for each slot defined in ActorDef
	for equipment_id in equipt_items:
		if !equipment_id or equipment_id == '':
			_slot_equipment_ids.append(null)
		else:
			_slot_equipment_ids.append(equipment_id)

func save_data()->Dictionary:
	var out_dict = {}
	out_dict["Equipment"] = _slot_equipment_ids
	return out_dict

## Return true if actor can equipt item in slot
func has_slot(slot:String)->bool:
	return _slot_equipment_ids.has(slot)

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
		return
	clear_slot(index)

func clear_slot(index:int):
	if index < 0 or index >= _slot_equipment_types.size() or _slot_equipment_ids[index] == null:
		return null
	# Get current item
	var current_item = get_equipment_in_slot(index) 
	# Clear slot
	_slot_equipment_ids[index] = null
	# Unbind current item if it thinks it;s still bound
	if current_item and current_item.is_equipped_to_actor(_actor): 
			current_item.clear_equipt_actor()
	_actor.stats.dirty_stats()

func equip_item_to_slot(index:int, equipment:BaseEquipmentItem):
	if index < 0 or index >= _slot_equipment_types.size():
		return null
	# Already equipped
	if _slot_equipment_ids[index] == equipment.Id:
		return
	var equipment_slot_type = equipment.get_equipment_slot_type()
	if _slot_equipment_types[index] != equipment_slot_type:
		printerr("%s.EquipmentHolder: Equipment %s of type '%s' can no go in slot %s of type '%s'." % 
				[_actor.Id, equipment.Id, equipment_slot_type, index, _slot_equipment_types[index]])
		return
	# Clear anythng else in slot
	if has_equipment_in_slot(index):
		clear_slot(index)
	# Set equipment in slot
	_slot_equipment_ids[index] = equipment.Id
	# Set equipment's actor if not already set
	if not equipment.is_equipped_to_actor(_actor): 
		equipment.set_equipt_actor(_actor, index)

## Try to equip the item to the first open slot for it's type. If no open slots are found, replace first if allowed
func try_equip_item(equipment:BaseEquipmentItem, replace:bool=false)->bool:
	var first_found_slot = -1
	var equipment_slot_type = equipment.get_equipment_slot_type()
	for index in range(_slot_equipment_types.size()):
		var check_type = _slot_equipment_types[index]
		if check_type == equipment_slot_type:
			if not has_equipment_in_slot(index):
				equip_item_to_slot(index, equipment)
				return true
			elif first_found_slot < 0:
				first_found_slot = index
	if replace and first_found_slot >= 0:
		equip_item_to_slot(first_found_slot, equipment)
		return true
	return false




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

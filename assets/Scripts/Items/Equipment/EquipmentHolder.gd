class_name EquipmentHolder

var _actor:BaseActor
var _equipment_slot_to_item_id:Dictionary = {}

func _init(actor:BaseActor) -> void:
	self._actor = actor
	
	# Create entries for each slot defined in ActorDef
	var actor_slots:Array = actor.get_load_val("EquipmentSlots", [])
	for slot_key_str in actor_slots:
		if BaseEquipmentItem.EquipmentSlots.has(slot_key_str):
			var slot_type = BaseEquipmentItem.EquipmentSlots.get(slot_key_str)
			_equipment_slot_to_item_id[slot_type] = null
	
	 #Check if Ids are already set
	var equipt_items = actor.get_load_val("EquiptedItems", {})
	for slot_key_str in equipt_items.keys():
		if BaseEquipmentItem.EquipmentSlots.has(slot_key_str):
			var slot_type = BaseEquipmentItem.EquipmentSlots.get(slot_key_str)
			_equipment_slot_to_item_id[slot_type] = equipt_items[slot_key_str]

func save_data()->Dictionary:
	var out_dict = {}
	for slot in _equipment_slot_to_item_id:
		var key = BaseEquipmentItem.EquipmentSlots.keys()[slot]
		var item_id =  _equipment_slot_to_item_id.get(slot, null)
		#if item_id:
		out_dict[key] = item_id
	return out_dict

## Return true if actor can equipt item in slot
func has_slot(slot:BaseEquipmentItem.EquipmentSlots)->bool:
	return _equipment_slot_to_item_id.keys().has(slot)

func has_item_in_slot(slot:BaseEquipmentItem.EquipmentSlots)->bool:
	var item_id =  _equipment_slot_to_item_id.get(slot, null)
	return item_id != null 

func get_item_in_slot(slot:BaseEquipmentItem.EquipmentSlots)->BaseEquipmentItem:
	var item_id =  _equipment_slot_to_item_id.get(slot, null)
	if !item_id:
		return null
	return ItemLibrary.get_item(item_id)

func get_total_equipment_armor()->int:
	var val = 0
	for slot in _equipment_slot_to_item_id.keys():
		if (slot == BaseEquipmentItem.EquipmentSlots.Head or
			slot == BaseEquipmentItem.EquipmentSlots.Body or
			slot == BaseEquipmentItem.EquipmentSlots.Feet or
			slot == BaseEquipmentItem.EquipmentSlots.Trinket):
				var armor_item = (get_item_in_slot(slot) as BaseArmorEquipment)
				if armor_item:
					val +=  armor_item.get_armor_value()
	return val

func get_total_equipment_ward()->int:
	var val = 0
	for slot in _equipment_slot_to_item_id.keys():
		if (slot == BaseEquipmentItem.EquipmentSlots.Head or
			slot == BaseEquipmentItem.EquipmentSlots.Body or
			slot == BaseEquipmentItem.EquipmentSlots.Feet or
			slot == BaseEquipmentItem.EquipmentSlots.Trinket):
				var armor_item = (get_item_in_slot(slot) as BaseArmorEquipment)
				if armor_item:
					val +=  armor_item.get_ward_value()
	return val


func equipt_que(que:BaseQueEquipment):
	_set_equipment(BaseEquipmentItem.EquipmentSlots.Que, que)

func equipt_bag(bag:BaseBagEquipment):
	_set_equipment(BaseEquipmentItem.EquipmentSlots.Bag, bag)

func equipt_armor(armor:BaseArmorEquipment):
	var slot = armor.get_equip_slot()
	_set_equipment(slot, armor)

func equipt_trinket(armor:BaseArmorEquipment):
	var slot = armor.get_equip_slot()
	_set_equipment(slot, armor)

func _set_equipment(slot:BaseEquipmentItem.EquipmentSlots, item:BaseEquipmentItem):
	if not _equipment_slot_to_item_id.keys().has(slot):
		printerr("EquipmentHolder.set_equipment: Actor '%s' does not have slot of type '%s'." % [_actor.Id, slot])
		return
	_equipment_slot_to_item_id[slot] = item.Id

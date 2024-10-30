class_name BaseEquipmentItem
extends BaseItem

signal equipt_actor_change

enum EquipmentSlots {Que, Bag, Weapon, Shield, Head, Body, Feet, Trinket}

var _equipt_to_actor_id:String:
	get: return get_load_val("EquiptToActorId", '')
	set(val): _data['EquiptToActorId'] = val

func get_item_type()->ItemTypes:
	return ItemTypes.Equipment

func get_equip_slot()->EquipmentSlots:
	var type_str = self.get_load_val("EquipSlot", "")
	if type_str and EquipmentSlots.keys().has(type_str):
		return EquipmentSlots.get(type_str)
	else:
		printerr("BaseEquipmentItem.get_equip_slot: %s has unknown EquipSlot '%s'." % [ItemKey, type_str])
	return EquipmentSlots.Trinket

func clear_equipt_actor():
	var slot = self.get_equip_slot()
	var old_actor_id = _equipt_to_actor_id
	_equipt_to_actor_id = ''
	if old_actor_id != '':
		var current_actor = ActorLibrary.get_actor(old_actor_id)
		current_actor.equipment.clear_slot(slot)
	equipt_actor_change.emit()

func set_equipt_actor(actor:BaseActor):
	if _equipt_to_actor_id == actor.Id:
		return
		
	var slot = self.get_equip_slot()
	var old_actor_id = _equipt_to_actor_id
	_equipt_to_actor_id = actor.Id
	if old_actor_id != '':
		var current_actor = ActorLibrary.get_actor(old_actor_id)
		current_actor.equipment.clear_slot(slot)
	
	if actor.equipment.has_item_in_slot(slot):
		var cur_item = actor.equipment.get_item_in_slot(slot)
		if cur_item != self:
			cur_item.clear_equipt_actor()
	equipt_actor_change.emit()

func get_equipt_to_actor_id():
	return _equipt_to_actor_id

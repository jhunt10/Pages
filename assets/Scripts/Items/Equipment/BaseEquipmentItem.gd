class_name BaseEquipmentItem
extends BaseItem

signal equipt_actor_change

var _equipt_to_actor_id:String:
	get: return get_load_val("EquiptToActorId", '')
	set(val): _data['EquiptToActorId'] = val
var _equipt_slot_index:int:
	get: return get_load_val("EquiptSlotIndex", -1)
	set(val): _data['EquiptSlotIndex'] = val

func get_item_type()->ItemTypes:
	return ItemTypes.Equipment

func get_equipment_slot_type()->String:
	return self.get_load_val("EquipSlot", "UNSET")

func get_armor_value()->int:
	return self.get_load_val("Armor", 0)
func get_ward_value()->int:
	return self.get_load_val("Ward", 0)

## Returns true if this item is equipped to provided actor, or any actor if none is provided
func is_equipped_to_actor(actor:BaseActor=null)->bool:
	if actor:
		return actor.Id == _equipt_to_actor_id
	else:
		return _equipt_to_actor_id != null

func clear_equipt_actor():
	var old_actor_id = _equipt_to_actor_id
	_equipt_to_actor_id = ''
	_equipt_slot_index = -1
	if old_actor_id != '':
		var current_actor = ActorLibrary.get_actor(old_actor_id)
		current_actor.equipment.remove_equipment(self)
	equipt_actor_change.emit()

func set_equipt_actor(actor:BaseActor, slot:int):
	if _equipt_to_actor_id == actor.Id:
		return
	
	var old_actor_id = _equipt_to_actor_id
	
	_equipt_to_actor_id = actor.Id
	_equipt_slot_index = slot
	
	if old_actor_id != '':
		var current_actor = ActorLibrary.get_actor(old_actor_id)
		current_actor.equipment.remove_equipment(self)
	
	# Chack if actor know's it's equipped
	if not actor.equipment.has_equipment_in_slot(slot, self):
		actor.equipment.equip_item_to_slot(slot, self)
	equipt_actor_change.emit()

func get_equipt_to_actor_id():
	return _equipt_to_actor_id

func get_stat_mods()->Array:
	var stat_mod_datas:Dictionary = get_load_val("StatMods", {})
	var out_list = []
	for mod_data in stat_mod_datas.values():
		out_list.append(BaseStatMod.new(Id, mod_data))
	return out_list

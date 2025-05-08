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

func get_item_tags()->Array:
	var tags = super()
	if !tags.has("Equipment"):
		tags.append("Equipment")
	return tags

func get_equipment_slot_type()->String:
	return self.get_load_val("EquipSlot", "UNSET")

## Returns true if this item is equipped to provided actor, or any actor if none is provided
func is_equipped_to_actor(actor:BaseActor=null)->bool:
	if actor:
		return actor.Id == _equipt_to_actor_id
	else:
		return _equipt_to_actor_id != null

func clear_equipt_actor():
	pass
	#var old_actor_id = _equipt_to_actor_id
	#_equipt_to_actor_id = ''
	#_equipt_slot_index = -1
	#if old_actor_id != '':
		#var current_actor = ActorLibrary.get_actor(old_actor_id)
		#current_actor.equipment.remove_equipment(self)
	#equipt_actor_change.emit()

func set_equipt_actor(actor:BaseActor, slot:int):
	pass
	#if _equipt_to_actor_id == actor.Id:
		#return
	#
	## Return if actor can not equipe this item
	#if !actor.equipment.can_equip_item(self):
		## Unless they alreay think it's equiped
		#if not actor.equipment.has_equipment_in_slot(slot, self):
			#return
	#
	#var old_actor_id = _equipt_to_actor_id
	#
	#_equipt_to_actor_id = actor.Id
	#_equipt_slot_index = slot
	#
	#if old_actor_id != '':
		#var current_actor = ActorLibrary.get_actor(old_actor_id)
		#if current_actor:
			#current_actor.equipment.remove_equipment(self)
	#
	## Chack if actor know's it's equipped
	#if not actor.equipment.has_equipment_in_slot(slot, self):
		#actor.equipment.equip_item_to_slot(slot, self)
	#equipt_actor_change.emit()

func get_equipt_to_actor_id():
	return _equipt_to_actor_id

func get_sprite_sheet_file_path():
	var file_name = get_load_val("SpriteSheet", null)
	if !file_name:
		return null
	return _def_load_path.path_join(file_name)

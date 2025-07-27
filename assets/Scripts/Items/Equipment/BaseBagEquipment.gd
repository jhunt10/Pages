class_name BaseBagEquipment
extends BaseEquipmentItem
var _cached_slots_data:Array[Dictionary] = []
func get_equipment_slot_type()->String:
	return "Bag"

func get_tags()->Array:
	var tags = super()
	tags.append("SupplyBag")
	return tags


func get_item_slot_data()->Array[Dictionary]:
	if _cached_slots_data.size() == 0:
		var slot_datas = equipment_data.get("ItemSlotsData", [])
		for slot_data:Dictionary in slot_datas:
			if not slot_data.keys().has("SourceItemId"):
				slot_data["SourceItemId"] = self.Id
			_cached_slots_data.append(slot_data)
	return _cached_slots_data.duplicate()

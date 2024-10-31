class_name BaseBagEquipment
extends BaseEquipmentItem

func get_equipment_slot_type()->String:
	return "Bag"

func get_max_que_size()->int:
	var val = get_load_val("MaxQueSize", 0)
	return val

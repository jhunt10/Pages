class_name BaseBagEquipment
extends BaseEquipmentItem

func get_equip_slot()->EquipmentSlots:
	return EquipmentSlots.Bag

func get_max_que_size()->int:
	var val = get_load_val("MaxQueSize", 0)
	return val

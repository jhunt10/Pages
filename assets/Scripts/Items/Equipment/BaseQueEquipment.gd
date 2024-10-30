class_name BaseQueEquipment
extends BaseEquipmentItem

func get_equip_slot()->EquipmentSlots:
	return EquipmentSlots.Que

func get_max_page_count()->int:
	var val = get_load_val("MaxPageCount", 0)
	return val

func get_max_que_size()->int:
	var val = get_load_val("MaxQueSize", 0)
	return val

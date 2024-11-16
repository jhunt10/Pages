class_name BaseArmorEquipment
extends BaseEquipmentItem

func get_armor_value()->int:
	var val = get_load_val("Armor", 0)
	return val

func get_ward_value()->int:
	var val = get_load_val("Ward", 0)
	return val

func get_item_tags()->Array:
	var tags = super()
	tags.append("Armor")
	return tags

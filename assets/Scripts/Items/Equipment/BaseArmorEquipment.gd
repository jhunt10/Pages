class_name BaseArmorEquipment
extends BaseEquipmentItem

func get_tags()->Array:
	var tags = super()
	tags.append("Armor")
	return tags

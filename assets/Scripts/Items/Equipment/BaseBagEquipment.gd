class_name BaseBagEquipment
extends BaseEquipmentItem

func get_equipment_slot_type()->String:
	return "Bag"

func get_tags()->Array:
	var tags = super()
	tags.append("SupplyBag")
	return tags

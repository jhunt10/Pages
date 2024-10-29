class_name BaseEquipmentItem
extends BaseItem

enum EquipmentSlots {Que, Bag, Weapon, Shield, Head, Body, Feet, Trinket}

func get_item_type()->ItemTypes:
	return ItemTypes.Equipment

func get_equip_slot()->EquipmentSlots:
	var type_str = self.get_load_val("EquipSlot", "")
	if type_str and EquipmentSlots.keys().has(type_str):
		return EquipmentSlots.get(type_str)
	else:
		printerr("BaseEquipmentItem.get_equip_slot: %s has unknown EquipSlot '%s'." % [ItemKey, type_str])
	return EquipmentSlots.Trinket

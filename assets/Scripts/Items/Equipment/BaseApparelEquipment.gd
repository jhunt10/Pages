class_name BaseApparelEquipment
extends BaseEquipmentItem

enum ApparelClasses {Clothes, LightWard, LightArmor, HeavyWard, HeavyArmor}

var apparel_data:Dictionary:
	get:
		return _def.get("ApparelData", {})

func _get_object_specific_tags()->Array:
	var apparel_class = ApparelClasses.keys()[get_apparel_class()]
	var apparel_slot = get_equipment_slot_type()
	var tags = [apparel_class, apparel_slot, "Apparel"]
	TagHelper.merge_lists(tags, super())
	return tags

func get_apparel_class()->ApparelClasses:
	var val = apparel_data.get("ApparelClass", null)
	if ApparelClasses.keys().has(val):
		return ApparelClasses.get(val)
	return ApparelClasses.Clothes

func get_armor_value()->int:
	return apparel_data.get("ProvidedArmor", 0)
	
func get_ward_value()->int:
	return apparel_data.get("ProvidedWard", 0)

## Returns what sub data has Mods
func get_data_containing_mods()->Dictionary:
	return apparel_data

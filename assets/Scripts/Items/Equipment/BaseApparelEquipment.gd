class_name BaseApparelEquipment
extends BaseEquipmentItem

enum ApparelClasses {LightWard, LightArmor, HeavyWard, HeavyArmor}

var apparel_data:Dictionary:
	get:
		return _def.get("ApparelData", {})

func get_tags()->Array:
	var tags = super()
	tags.append("Apparel")
	var apparel_class = get_apparel_class()
	match apparel_class:
		ApparelClasses.LightWard:
			if not tags.has('LightWard'):
				tags.append("LightWard")
		ApparelClasses.LightArmor:
			if not tags.has('LightArmor'):
				tags.append("LightArmor")
		ApparelClasses.HeavyWard:
			if not tags.has('HeavyWard'):
				tags.append("HeavyWard")
		ApparelClasses.HeavyArmor:
			if not tags.has('HeavyArmor'):
				tags.append("HeavyArmor")
	return tags

func get_apparel_class()->ApparelClasses:
	var val = apparel_data.get("ApparelClass", null)
	if ApparelClasses.keys().has(val):
		return ApparelClasses.get(val)
	return ApparelClasses.LightArmor

func get_armor_value()->int:
	return apparel_data.get("ProvidedArmor", 0)
	
func get_ward_value()->int:
	return apparel_data.get("ProvidedWard", 0)

## Returns what sub data has Mods
func get_data_containing_mods()->Dictionary:
	return apparel_data

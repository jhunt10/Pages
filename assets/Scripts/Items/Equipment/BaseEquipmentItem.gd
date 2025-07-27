class_name BaseEquipmentItem
extends BaseItem


var equipment_data:Dictionary:
	get:
		return get_load_val("EquipmentData", {})

func get_item_type()->ItemTypes:
	return ItemTypes.Equipment

func get_tags()->Array:
	var tags = super()
	if !tags.has("Equipment"):
		tags.append("Equipment")
	return tags

func get_equipment_slot_type()->String:
	return equipment_data.get("EquipSlot", "UNSET")

func has_spite_sheet()->bool:
	return equipment_data.get("SpriteData", {}).has('SpriteSheet')
func get_sprite_sheet_file_path():
	var file_name = equipment_data.get("SpriteData", {}).get('SpriteSheet', null)
	if !file_name:
		return null
	return _def_load_path.path_join(file_name)

func get_tags_added_to_actor()->Array:
	return equipment_data.get("AddTags", [])

## Returns what sub data has Mods
func get_data_containing_mods()->Dictionary:
	return equipment_data

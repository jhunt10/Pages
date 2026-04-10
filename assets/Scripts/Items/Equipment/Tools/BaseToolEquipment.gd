class_name BaseToolEquipment
extends BaseEquipmentItem



enum ToolTypes {
	OffHand, # Can only go in OffHand
	Light,
	Medium,
	Heavy,
}

func _get_object_specific_tags()->Array:
	var tags = ["Tool"]
	TagHelper.merge_lists(tags, super())
	return tags

func get_equipment_slot_type()->String:
	return "Hand"

func get_tool_size_str()->String:
	return "OffHand"

func can_main_hand()->bool:
	return true
	
func can_off_hand()->bool:
	return true

func can_one_hand()->bool:
	return true
	
func can_two_hand()->bool:
	return false

class_name BaseShieldEquipment
extends BaseToolEquipment

func get_equipment_slot_type()->String:
	return "Hand"

func can_main_hand()->bool:
	return false
	
func can_off_hand()->bool:
	return true


func _get_object_specific_tags()->Array:
	var tags = ["Shield"]
	TagHelper.merge_lists(tags, super())
	return tags

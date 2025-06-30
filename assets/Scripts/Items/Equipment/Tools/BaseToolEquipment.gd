class_name BaseToolEquipment
extends BaseEquipmentItem



enum ToolTypes {
	OffHand, # Can only go in OffHand
	Light,
	Medium,
	Heavy,
}

func get_equipment_slot_type()->String:
	return "Hand"

func can_main_hand()->bool:
	return true
	
func can_off_hand()->bool:
	return true

func can_two_hand()->bool:
	return false

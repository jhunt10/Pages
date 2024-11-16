@tool
class_name MouseOverWeaponContainer
extends BackPatchContainer

@export var range_display:MiniRangeDisplay
@export var label:Label

func set_weapon(weapon:BaseWeaponEquipment):
	range_display.load_area_matrix(weapon.target_parmas.target_area)
	label.text = weapon.details.display_name

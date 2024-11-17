@tool
class_name MouseOverWeaponContainer
extends BackPatchContainer

@export var range_display:MiniRangeDisplay
@export var label:Label
@export var tags_label:Label
@export var damage_label:Label

@export var physical_attack_icon:TextureRect
@export var magic_attack_icon:TextureRect

func set_weapon(weapon:BaseWeaponEquipment):
	range_display.load_area_matrix(weapon.target_parmas.target_area)
	label.text = weapon.details.display_name
	var tags_string = ''
	for tag in weapon.get_item_tags():
		tags_string += tag + ", "
	tags_label.text = "Tags: " + tags_string.trim_suffix(", ")
	var damage_data = weapon.get_damage_data()
	damage_label.text = "%s ±%s%% %s" % [damage_data.get("BaseDamage"), damage_data.get("DamageVarient", 0) * 100, damage_data.get("DamageType")]
	if damage_data.get("DefenseType") == "Armor":
		physical_attack_icon.visible = true
		magic_attack_icon.visible = false
	elif damage_data.get("DefenseType") == "Ward":
		physical_attack_icon.visible = false
		magic_attack_icon.visible = true
	else:
		physical_attack_icon.visible = false
		magic_attack_icon.visible = false

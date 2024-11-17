class_name WeaponInfoSubContainer
extends Container

@export var range_display:MiniRangeDisplay
@export var class_label:Label
@export var attack_power_label:Label
@export var damage_var_label:Label
@export var damage_type_label:Label

@export var physical_attack_icon:TextureRect
@export var magic_attack_icon:TextureRect

func set_weapon(weapon:BaseWeaponEquipment):
	range_display.load_area_matrix(weapon.target_parmas.target_area)
	class_label.text = str(BaseWeaponEquipment.WeaponClasses.keys()[weapon.get_weapon_class()])
	var tags_string = ''
	for tag in weapon.get_item_tags():
		tags_string += tag + ", "
	var damage_data = weapon.get_damage_data()
	attack_power_label.text = str(damage_data.get("BaseDamage"))
	damage_var_label.text = str(damage_data.get("DamageVarient", 0) * 100) + "%"
	damage_type_label.text = damage_data.get("DamageType")
	if damage_data.get("DefenseType") == "Armor":
		physical_attack_icon.visible = true
		magic_attack_icon.visible = false
	elif damage_data.get("DefenseType") == "Ward":
		physical_attack_icon.visible = false
		magic_attack_icon.visible = true
	else:
		physical_attack_icon.visible = false
		magic_attack_icon.visible = false

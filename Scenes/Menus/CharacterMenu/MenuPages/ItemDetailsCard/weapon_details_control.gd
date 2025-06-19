class_name WeaponDetailsControl
extends Control

@export var parent_card_control:ItemDetailsCard
@export var weapon_class_label:Label
@export var phy_damage_icon:TextureRect
@export var mag_damage_icon:TextureRect
@export var attack_power_label:Label
@export var damage_type_label:Label
@export var description_box:RichTextLabel
@export var range_display:MiniRangeDisplay

var _item:BaseWeaponEquipment
var _actor:BaseActor

func set_weapon(actor:BaseActor, weapon:BaseWeaponEquipment):
	_actor = actor
	_item = weapon
	weapon_class_label.text = BaseWeaponEquipment.WeaponClasses.keys()[weapon.get_weapon_class()]
	var damage_data = weapon.get_damage_datas()
	damage_data =damage_data.values()[0]
	var defense_type = damage_data.get("DefenseType", null)
	
	var damage_type = damage_data.get("DamageType")
	if defense_type == "AUTO":
		if DamageHelper.ElementalDamageTypes_Strings.has(damage_type):
			defense_type = "Ward"
		elif DamageHelper.PhysicalDamageTypes_Strings.has(damage_type):
			defense_type = "Armor"
		else:
			defense_type = "None"
		
	if defense_type == "Ward":
		mag_damage_icon.show()
		phy_damage_icon.hide()
	else:
		phy_damage_icon.show()
		mag_damage_icon.hide()
	var base_power = damage_data.get("AtkPwrBase", 0)
	var power_range = damage_data.get("AtkPwrRange", 0)
	var power_scale = damage_data.get("AtkPwrScale", 1)
	base_power = base_power * power_scale
	power_range = power_range * power_scale
	attack_power_label.text = ("%s±%s" % [base_power, (power_range)]) + "%"
	damage_type_label.text = damage_type
	description_box.text = weapon.get_description()
	range_display.load_area_matrix(weapon.target_parmas.target_area)
	
	#if _actor.equipment.has_item(_item.Id):
		#parent_card_control.equip_label.text = "Remove"	
	#elif _actor.equipment.can_equip_item(_item):
		#parent_card_control.equip_label.text = "Equip"
	#else:
		#parent_card_control.equip_button_background.hide()
	#

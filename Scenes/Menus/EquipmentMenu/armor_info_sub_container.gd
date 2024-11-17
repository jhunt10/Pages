class_name ArmorInfoSubContainer
extends HBoxContainer

@export var slot_label:Label
@export var armor_icon:TextureRect
@export var armor_label:Label
@export var ward_icon:TextureRect
@export var ward_label:Label

func set_armor(armor:BaseArmorEquipment):
	slot_label.text = armor.get_equipment_slot_type()
	var armor_val = armor.get_armor_value()
	if armor_val > 0:
		armor_icon.visible = true
		armor_label.visible = true
		armor_label.text = str(armor_val)
	else:
		armor_icon.visible = false
		armor_label.visible = false
		
	var ward_val = armor.get_ward_value()
	if ward_val > 0:
		ward_icon.visible = true
		ward_label.visible = true
		ward_label.text = str(ward_val)
	else:
		ward_icon.visible = false
		ward_label.visible = false

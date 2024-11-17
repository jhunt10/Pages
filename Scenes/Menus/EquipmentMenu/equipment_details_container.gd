@tool
class_name EquipmentDetailsContainer
extends BackPatchContainer

@export var icon:TextureRect
@export var title_label:Label
@export var tags_label:Label
@export var description_label:Label

@export var armor_details:ArmorInfoSubContainer
@export var weapon_details:WeaponInfoSubContainer
@export var book_details:BookInfoSubContainer

func set_item(item:BaseEquipmentItem):
	icon.texture = item.get_small_icon()
	title_label.text = item.details.display_name
	
	var tags_string = 'Tags: '
	for tag in item.get_item_tags():
		tags_string += tag + ", "
	tags_label.text = tags_string.trim_suffix(", ")
	
	description_label.text = item.details.description
	
	if item is BaseArmorEquipment:
		var armor = item as BaseArmorEquipment
		armor_details.visible = true
		armor_details.set_armor(armor)
	else:
		armor_details.visible = false

	if item is BaseWeaponEquipment:
		var weapon = item as BaseWeaponEquipment
		weapon_details.visible = true
		weapon_details.set_weapon(weapon)
	else:
		weapon_details.visible = false
	
	if item is BaseQueEquipment:
		var book = item as BaseQueEquipment
		book_details.visible = true
		book_details.set_item(book)
	else:
		book_details.visible = false

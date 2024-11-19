@tool
class_name EquipmentDetailsContainer
extends BackPatchContainer

signal close_menu

@export var close_button:Button
@export var icon:TextureRect
@export var title_label:Label
@export var tags_label:Label
@export var description_label:Label
@export var equip_button:Button

@export var armor_details:ArmorInfoSubContainer
@export var weapon_details:WeaponInfoSubContainer
@export var book_details:BookInfoSubContainer

var _actor:BaseActor
var _item: BaseItem

func _ready() -> void:
	close_button.pressed.connect(_close_menu)
	equip_button.pressed.connect(on_equip_button)

func set_actor(actor:BaseActor):
	_actor = actor

func _close_menu():
	close_menu.emit()

func on_equip_button():
	if !_actor or !_item:
		return
	var equipment = _item as BaseEquipmentItem
	if !equipment:
		return
	if equipment.is_equipped_to_actor(_actor):
		_actor.equipment.remove_equipment(equipment)
	elif _actor.equipment.can_equip_item(equipment):
		_actor.equipment.try_equip_item(equipment, true)
	set_item(_item)

func set_item(item:BaseItem):
	_item = item
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
	
	if item is BaseEquipmentItem:
		if item.is_equipped_to_actor(_actor):
			equip_button.text = "Remove"
			equip_button.visible = true
		elif _actor:
			equip_button.visible = true
			if _actor.equipment.can_equip_item(item):
				equip_button.text = "Equip"
			else:
				equip_button.text = "Missing Stat"
		else:
			equip_button.visible = false
	else:
		equip_button.visible = false

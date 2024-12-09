class_name ArmorDetailsControl
extends Control

@export var parent_card_control:ItemDetailsCard
@export var slot_label:Label
@export var phy_icon:TextureRect
@export var mag_icon:TextureRect
@export var armor_label:Label
@export var ward_label:Label
@export var description_box:RichTextLabel
@export var equip_button_background:NinePatchRect
@export var equip_button:Button
@export var equip_label:Label

var _item:BaseEquipmentItem
var _actor:BaseActor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	equip_button.pressed.connect(on_eqiup_button_pressed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_armor(actor:BaseActor, armor:BaseArmorEquipment):
	_actor = actor
	_item = armor
	slot_label.text = armor.get_equipment_slot_type()
	if armor.get_armor_value() > 0:
		phy_icon.show()
		armor_label.show()
		armor_label.text = str(armor.get_armor_value())
	else:
		phy_icon.hide()
		armor_label.hide()
	if armor.get_ward_value() > 0:
		mag_icon.show()
		ward_label.show()
		ward_label.text = str(armor.get_ward_value())
	else:
		mag_icon.hide()
		ward_label.hide()
	description_box.text = armor.details.description
	
	if _actor.equipment.has_item(_item.Id):
		equip_label.text = "Remove"	
	elif _actor.equipment.can_equip_item(_item):
		equip_label.text = "Equip"
	else:
		equip_button_background.hide()
	

func on_eqiup_button_pressed():
	if _actor.equipment.has_item(_item.Id):
		_actor.equipment.remove_equipment(_item)
	elif _actor.equipment.can_equip_item(_item):
		_actor.equipment.try_equip_item(_item, true)
	parent_card_control.start_hide()

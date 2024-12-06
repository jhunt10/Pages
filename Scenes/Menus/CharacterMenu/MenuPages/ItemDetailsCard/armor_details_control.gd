class_name ArmorDetailsControl
extends Control

@export var slot_label:Label
@export var phy_icon:TextureRect
@export var mag_icon:TextureRect
@export var armor_label:Label
@export var ward_label:Label
@export var description_box:RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_armor(armor:BaseArmorEquipment):
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
	

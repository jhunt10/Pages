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
@export var equip_button_background:NinePatchRect
@export var equip_button:Button
@export var equip_label:Label

var _item:BaseWeaponEquipment
var _actor:BaseActor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	equip_button.pressed.connect(on_eqiup_button_pressed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_weapon(actor:BaseActor, weapon:BaseWeaponEquipment):
	_actor = actor
	_item = weapon
	weapon_class_label.text = BaseWeaponEquipment.WeaponClasses.keys()[weapon.get_weapon_class()]
	var damage_data = weapon.get_damage_data()
	var defense_type = damage_data.get("DefenseType", null)
	if defense_type == "Ward":
		mag_damage_icon.show()
		phy_damage_icon.hide()
	else:
		phy_damage_icon.show()
		mag_damage_icon.hide()
	var base_damage = damage_data.get("AtkPower", 0)
	var damage_var = damage_data.get("DamageVarient", 0)
	attack_power_label.text = "%s±%s" % [base_damage, (damage_var * base_damage)]
	var damage_type = damage_data.get("DamageType")
	damage_type_label.text = damage_type
	description_box.text = weapon.details.description
	range_display.load_area_matrix(weapon.target_parmas.target_area)
	
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

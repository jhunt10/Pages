class_name WeaponDetailsControl
extends Control

@export var weapon_class_label:Label
@export var phy_damage_icon:TextureRect
@export var mag_damage_icon:TextureRect
@export var attack_power_label:Label
@export var damage_type_label:Label
@export var description_box:RichTextLabel
@export var range_display:MiniRangeDisplay

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_weapon(weapon:BaseWeaponEquipment):
	weapon_class_label.text = BaseWeaponEquipment.WeaponClasses.keys()[weapon.get_weapon_class()]
	var damage_data = weapon.get_damage_data()
	var defense_type = damage_data.get("DefenseType", null)
	if defense_type == "Ward":
		mag_damage_icon.show()
		phy_damage_icon.hide()
	else:
		phy_damage_icon.show()
		mag_damage_icon.hide()
	var base_damage = damage_data.get("BaseDamage", 0)
	var damage_var = damage_data.get("DamageVarient", 0)
	attack_power_label.text = "%s±%s" % [base_damage, (damage_var * base_damage)]
	var damage_type = damage_data.get("DamageType")
	damage_type_label.text = damage_type
	description_box.text = weapon.details.description
	range_display.load_area_matrix(weapon.target_parmas.target_area)
	

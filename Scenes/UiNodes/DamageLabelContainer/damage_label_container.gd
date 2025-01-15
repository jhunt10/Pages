@tool
class_name DamageLabelContainer
extends HBoxContainer

enum DamageTypes {	
	Test, RAW, Healing, Percent,
	Light, Dark, Chaos, Psycic,
	Pierce, Slash, Blunt, Crash, # Usually negated by Armor
	Fire, Ice, Electric, Poison, # Usually negated by Ward
}

@export var defense_type:String:
	set(val):
		defense_type = val
		if damage_icon_rect:
			if defense_type == "Armor":
				damage_icon_rect.texture = phy_damage_icon
			elif defense_type == "Ward":
				damage_icon_rect.texture = mag_damage_icon
			else:
				damage_icon_rect.texture = abb_damage_icon
				
			
@export var damage_type:DamageTypes:
	set(val):
		damage_type = val
		if damage_type_label:
			if damage_type == DamageTypes.Healing:
				damage_type_label.text = DamageTypes.keys()[val]
			else:
				damage_type_label.text = DamageTypes.keys()[val] + " Dmg"
			
			
			if damage_type == DamageTypes.Slash:
				damage_type_label.add_theme_color_override("font_color", Color("8c4f4f"))
			elif damage_type == DamageTypes.Blunt:
				damage_type_label.add_theme_color_override("font_color", Color("597882"))
			elif damage_type == DamageTypes.Pierce:
				damage_type_label.add_theme_color_override("font_color", Color("ccc583"))
			elif damage_type == DamageTypes.Crash:
				damage_type_label.add_theme_color_override("font_color", Color("b4b991"))
			
			elif damage_type == DamageTypes.Fire:
				damage_type_label.add_theme_color_override("font_color", Color("cb0000"))
			elif damage_type == DamageTypes.Ice:
				damage_type_label.add_theme_color_override("font_color", Color("65c1ef"))
			elif damage_type == DamageTypes.Electric:
				damage_type_label.add_theme_color_override("font_color", Color("f2da00"))
			elif damage_type == DamageTypes.Poison:
				damage_type_label.add_theme_color_override("font_color", Color("00a355"))
			else:
				damage_type_label.add_theme_color_override("font_color", Color("780000"))
			
			if damage_type == DamageTypes.Healing:
				damage_type_label.add_theme_color_override("font_color", Color("00ff84"))
				atk_power_label.add_theme_color_override("font_color", Color("00ff84"))
				variant_label.add_theme_color_override("font_color", Color("00ff84"))
				plus_minus_label.add_theme_color_override("font_color", Color("00ff84"))
			else:
				plus_minus_label.add_theme_color_override("font_color", Color("780000"))
				atk_power_label.add_theme_color_override("font_color", Color("780000"))
				variant_label.add_theme_color_override("font_color", Color("780000"))


@export var attack_power:int:
	set(val):
		attack_power = val
		if atk_power_label: atk_power_label.text = str(attack_power)

@export var attack_variant:int:
	set(val):
		attack_variant = val
		if variant_label:
			variant_label.text = str(attack_variant) 

@export var damage_icon_rect:TextureRect
@export var atk_power_label:Label
@export var plus_minus_label:Label
@export var percent_label:Label
@export var variant_label:Label
@export var damage_type_label:Label

@export var abb_damage_icon:Texture2D
@export var phy_damage_icon:Texture2D
@export var mag_damage_icon:Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_damage_data(damage_data:Dictionary, actor:BaseActor = null):
	var defense_type = damage_data.get("DefenseType", null)
	if defense_type == "Ward":
		damage_icon_rect.texture = mag_damage_icon
	elif defense_type == "Armor":
		damage_icon_rect.texture = phy_damage_icon
	else:
		damage_icon_rect.texture = abb_damage_icon
	
	var fixed_base_damage = damage_data.get("FixedBaseDamage")
	if fixed_base_damage:
		plus_minus_label.hide()
		variant_label.hide()
		percent_label.hide()
		attack_power = fixed_base_damage
	elif actor:
		var min_max = DamageHelper.get_min_max_damage(actor, damage_data)
		attack_power = min_max[0]
		attack_variant = min_max[1]
		plus_minus_label.text = " - "
		percent_label.hide()
	else:
		attack_power = damage_data.get("AtkPower", 0)
		attack_variant = damage_data.get("DamageVarient", 0)
		if attack_variant == 0:
			variant_label.hide()
			plus_minus_label.hide()
	
	defense_type = damage_data.get("DefenseType")
	var type_string = damage_data.get("DamageType")
	var type = DamageTypes.get(type_string)
	if type == null:
		type = DamageTypes.Test
	damage_type = type

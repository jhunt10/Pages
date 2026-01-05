@tool
class_name DamageLabelContainer
extends HBoxContainer

enum DamageTypes {	
	Test, RAW, Healing, Percent,
	Light, Dark, Chaos, Psycic,
	Pierce, Slash, Blunt, Crash, # Usually negated by Armor
	Fire, Cold, Shock, Poison, # Usually negated by Ward
}

@export var font_size_override:int = -1:
	set(val):
		font_size_override = val
		if font_size_override > 0:
			if atk_power_label: atk_power_label.add_theme_font_size_override('font_size', font_size_override)
			if plus_minus_label: plus_minus_label.add_theme_font_size_override('font_size', font_size_override)
			if percent_label: percent_label.add_theme_font_size_override('font_size', font_size_override)
			if variant_label: variant_label.add_theme_font_size_override('font_size', font_size_override)
			if damage_type_label: damage_type_label.add_theme_font_size_override('font_size', font_size_override)
@export var defense_type:String:
	set(val):
		defense_type = val
				
			
@export var damage_type:DamageTypes:
	set(val):
		damage_type = val
		#if damage_type_label:
			#if damage_type == DamageTypes.Healing:
				#damage_type_label.text = DamageTypes.keys()[val]
			#else:
				#damage_type_label.text = DamageTypes.keys()[val] + " Dmg"
			#
			#
			#if damage_type == DamageTypes.Slash:
				#damage_type_label.add_theme_color_override("font_color", Color("8c4f4f"))
			#elif damage_type == DamageTypes.Blunt:
				#damage_type_label.add_theme_color_override("font_color", Color("597882"))
			#elif damage_type == DamageTypes.Pierce:
				#damage_type_label.add_theme_color_override("font_color", Color("ccc583"))
			#elif damage_type == DamageTypes.Crash:
				#damage_type_label.add_theme_color_override("font_color", Color("b4b991"))
			#
			#elif damage_type == DamageTypes.Fire:
				#damage_type_label.add_theme_color_override("font_color", Color("cb0000"))
			#elif damage_type == DamageTypes.Cold:
				#damage_type_label.add_theme_color_override("font_color", Color("65c1ef"))
			#elif damage_type == DamageTypes.Shock:
				#damage_type_label.add_theme_color_override("font_color", Color("f2da00"))
			#elif damage_type == DamageTypes.Poison:
				#damage_type_label.add_theme_color_override("font_color", Color("00a355"))
			#else:
				#damage_type_label.add_theme_color_override("font_color", Color("780000"))
			#
			#if damage_type == DamageTypes.Light:
				#damage_type_label.add_theme_color_override("font_color", Color("00ff84"))
				#atk_power_label.add_theme_color_override("font_color", Color("00ff84"))
				#variant_label.add_theme_color_override("font_color", Color("00ff84"))
				#plus_minus_label.add_theme_color_override("font_color", Color("00ff84"))
			#else:
				#plus_minus_label.add_theme_color_override("font_color", Color("780000"))
				#atk_power_label.add_theme_color_override("font_color", Color("780000"))
				#variant_label.add_theme_color_override("font_color", Color("780000"))


@export var attack_power:int:
	set(val):
		attack_power = val
		if atk_power_label: atk_power_label.text = str(attack_power)

@export var attack_variant:float:
	set(val):
		attack_variant = val
		if variant_label:
			variant_label.text = str(floori(attack_variant)) 

@export var attack_scale:float

@export var atk_power_and_scale_container:Container
@export var atk_power_label:Label
@export var plus_minus_label:Label
@export var percent_label:Label
@export var variant_label:Label

@export var min_max_damage_container:Container
@export var min_damage_label:Label
@export var avg_damage_label:Label
@export var max_damage_label:Label

@export var damage_type_label:Label
@export var multiplier_label:Label
@export var count_label:Label

@export var atk_stat_icon:TextureRect
@export var vs_lable:Label
@export var defense_stat_icon:TextureRect
@export var defense_stat_label:Label

@export var abb_damage_icon:Texture2D
@export var phy_damage_icon:Texture2D
@export var mag_damage_icon:Texture2D

@export var popup_container:BackPatchContainer
@export var popup_message:RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if popup_container:
		popup_container.hide()
		self.mouse_entered.connect(_on_mouse_enter)
		self.mouse_exited.connect(_on_mouse_exit)
	pass # Replace with function body.


func _on_mouse_enter():
	popup_container.show()

func _on_mouse_exit():
	popup_container.hide()

func set_damage_data(damage_data:Dictionary, actor:BaseActor = null,  count = 1):
	
	if damage_data.get("ActorlessWeapon", false):
		var attack_scale = damage_data.get("AtkPwrScale", 1)
		atk_stat_icon.hide()
		defense_stat_icon.hide()
		atk_power_label.hide()
		plus_minus_label.hide()
		variant_label.hide()
		percent_label.hide()
		vs_lable.hide()
		min_max_damage_container.hide()
		damage_type_label.text = "Wpn"
		if attack_scale != 1:
			damage_type_label.text += " X " + str(attack_scale)
		multiplier_label.hide()
		count_label.hide()
		return
	
	var attack_stat = damage_data.get("AtkStat", "Weapon")
	attack_power = damage_data.get("AtkPwrBase", 0)
	attack_variant = damage_data.get("AtkPwrRange", 0)
	var attack_scale = damage_data.get("AtkPwrScale", 1)
	
	if count > 1:
		count_label.text = str(count) + "x"
		count_label.show()
	else:
		count_label.hide()
	
	var average_damage = 0
	
	if damage_data.get("AtkStat") == "Fixed":
		plus_minus_label.hide()
		variant_label.hide()
		percent_label.hide()
		attack_power = damage_data.get("BaseDamage")
		
		atk_power_and_scale_container.show()
		min_max_damage_container.hide()
	elif actor:
		min_max_damage_container.show()
		atk_power_and_scale_container.hide()
		var min_max = DamageHelper.get_min_max_damage(actor, damage_data)
		min_damage_label.text = str(min_max[0])
		max_damage_label.text = str(min_max[1])
		avg_damage_label.text  = str((min_max[0] + min_max[1]) / 2)
	else:
		if attack_variant == 0:
			variant_label.hide()
			plus_minus_label.hide()
		atk_power_and_scale_container.show()
		min_max_damage_container.hide()
	
	if popup_message:
		var line = attack_stat + " X " + str(attack_power) + " @ " + str(attack_variant)
		if attack_scale != 1:
			line = line + " X " + str(attack_scale)
		popup_message.text = line
	
	
	var type_string = damage_data.get("DamageType")
	var type = DamageTypes.get(type_string)
	if type == null:
		type = DamageTypes.Test
	damage_type = type
	damage_type_label.text = " "+ DamageTypes.keys()[damage_type]
	#var damage_color = DamageHelper.get_damage_color(damage_type)
	#plus_minus_label.add_theme_color_override("font_color", damage_color)
	#atk_power_label.add_theme_color_override("font_color", damage_color)
	#percent_label.add_theme_color_override("font_color", damage_color)
	#variant_label.add_theme_color_override("font_color", damage_color)
	#damage_type_label.add_theme_color_override("font_color", damage_color)
	
	var atk_stat = damage_data.get("AtkStat")
	if atk_stat == "Fixed":
		atk_stat_icon.hide()
	else:
		atk_stat_icon.texture = StatHelper.get_stat_icon(atk_stat)
	
	var def_type_val = damage_data.get("DefenseType")
	if def_type_val == "AUTO":
		if DamageHelper.ElementalDamageTypes_Strings.has(type_string):
			defense_type = "Ward"
		elif DamageHelper.PhysicalDamageTypes_Strings.has(type_string):
			defense_type = "Armor"
		else:
			defense_type = "None"
	else:
		defense_type = def_type_val
	
	if defense_type == "Ward" or defense_type == "Armor":
		defense_stat_icon.texture = StatHelper.get_stat_icon(defense_type)
		defense_stat_label.text = " " + StatHelper.get_stat_abbr(defense_type)
		defense_stat_icon.show()
		defense_stat_label.show()
		vs_lable.show()
	else:
		defense_stat_icon.hide()
		defense_stat_label.hide()
		vs_lable.hide()
	

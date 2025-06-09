class_name BaseWeaponEquipment
extends BaseEquipmentItem

enum WeaponClasses {Light, Medium, Heavy}

var target_parmas:TargetParameters

var _loaded_sprites:bool = false
var _main_hand_sprite:Texture2D
var _off_hand_sprite:Texture2D
var _two_hand_sprite:Texture2D


var weapon_details:Dictionary:
	get:
		return _def.get("WeaponDetails", {})

var weapon_attack_data:Dictionary:
	get:
		return _def.get("WeaponDetails", {}).get("AttackData", {})


func _init(key:String, def_load_path:String, def:Dictionary, id:String='', data:Dictionary={}) -> void:
	super(key, def_load_path, def, id, data)
	target_parmas = TargetParameters.new("Weapon", weapon_details.get("AttackData", {}).get("TargetParams", {}))
	for damage_data_key in weapon_attack_data.get("DamageDatas", {}).keys():
		weapon_attack_data['DamageDatas'][damage_data_key]['DamageDataKey'] = damage_data_key
		weapon_attack_data['DamageDatas'][damage_data_key]['DisplayName'] = self.get_display_name()

func get_equipment_slot_type()->String:
	return "Weapon"

func get_item_type()->ItemTypes:
	return ItemTypes.Weapon
	
func get_item_tags()->Array:
	var tags = super()
	if !tags.has("Weapon"):
		tags.append("Weapon")
	var weapon_class = get_weapon_class()
	if weapon_class == WeaponClasses.Light:
		if !tags.has("LightWpn"):
			tags.append("LightWpn")
	elif weapon_class == WeaponClasses.Medium:
		if !tags.has("MediumWpn"):
			tags.append("MediumWpn")
	elif weapon_class == WeaponClasses.Heavy:
		if !tags.has("HeavyWpn"):
			tags.append("HeavyWpn")
	if is_ranged_weapon():
		if !tags.has("RangedWpn"):
			tags.append("RangedWpn")
		
	return tags

func get_weapon_class()->WeaponClasses:
	var val = weapon_details.get("WeaponClass", null)
	if !val: # TODO: Obsoleate
		val = get_load_val("WeaponClass", '')
	if WeaponClasses.keys().has(val):
		return WeaponClasses.get(val)
	return WeaponClasses.Medium

func is_ranged_weapon()->bool:
	return weapon_details.get("IsRanged", false)
	
func is_melee_weapon()->bool:
	return not weapon_details.get("IsRanged", false)

func get_damage_datas()->Dictionary:
	return weapon_attack_data.get("DamageDatas", {})

func get_effect_on_attack_data()->Dictionary:
	return weapon_attack_data.get("EffectDatas", {})

func get_misile_data()->Dictionary:
	return get_load_val("MissileData", {})

func get_default_weapon_animation_name()->String:
	return weapon_details.get("WeaponSpriteData", {}).get("WeaponAnimation", "")

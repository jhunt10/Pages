class_name BaseWeaponEquipment
extends BaseToolEquipment

enum WeaponClasses {Light, Medium, Heavy}

var target_parmas:TargetParameters

var _loaded_sprites:bool = false
var _main_hand_sprite:Texture2D
var _off_hand_sprite:Texture2D
var _two_hand_sprite:Texture2D


var weapon_data:Dictionary:
	get:
		return _def.get("WeaponData", {})

var weapon_attack_data:Dictionary:
	get:
		return _def.get("WeaponData", {}).get("AttackData", {})

func get_tool_size_str()->String:
	return  weapon_data.get("WeaponClass", "Medium")

func _init(key:String, def_load_path:String, def:Dictionary, id:String='', data:Dictionary={}) -> void:
	super(key, def_load_path, def, id, data)
	_cache_after_loading_def()
	
func get_tags()->Array:
	var tags = super()
	if not tags.has("Weapon"):
		tags.append("Weapon")
	var wpn_class = get_weapon_class()
	match wpn_class:
		WeaponClasses.Light:
			if not tags.has("LightWpn"):
				tags.append("LightWpn")
		WeaponClasses.Medium:
			if not tags.has("MediumWpn"):
				tags.append("MediumWpn")
		WeaponClasses.Heavy:
			if not tags.has("HeavyWpn"):
				tags.append("HeavyWpn")
	if not (tags.has("MeleeWpn") or tags.has("RangeWpn")):
		if is_melee_weapon():
			tags.append("MeleeWpn")
		if is_ranged_weapon():
			tags.append("RangeWpn")
	return tags

func can_main_hand()->bool:
	return true
	
func can_off_hand()->bool:
	return get_weapon_class() == WeaponClasses.Light

func can_one_hand()->bool:
	return get_weapon_class() != WeaponClasses.Heavy
	
func can_two_hand()->bool:
	return get_weapon_class() != WeaponClasses.Light

func reload_def(load_path:String, def:Dictionary):
	super(load_path, def)
	_cache_after_loading_def()

func get_target_param_def()->Dictionary:
	return  weapon_data.get("AttackData", {}).get("TargetParams", {}).duplicate(true)

func _cache_after_loading_def():
	target_parmas = TargetParameters.new("Weapon", weapon_data.get("AttackData", {}).get("TargetParams", {}))
	for damage_data_key in weapon_attack_data.get("DamageDatas", {}).keys():
		weapon_attack_data['DamageDatas'][damage_data_key]['DamageDataKey'] = damage_data_key
		weapon_attack_data['DamageDatas'][damage_data_key]['DisplayName'] = self.get_display_name()

func get_item_type()->ItemTypes:
	return ItemTypes.Weapon

func get_weapon_class()->WeaponClasses:
	var val = weapon_data.get("WeaponClass", null)
	if !val: # TODO: Obsoleate
		val = get_load_val("WeaponClass", '')
	if WeaponClasses.keys().has(val):
		return WeaponClasses.get(val)
	return WeaponClasses.Medium

func is_ranged_weapon()->bool:
	return weapon_data.get("IsRanged", false)
	
func is_melee_weapon()->bool:
	return not weapon_data.get("IsRanged", false)

func get_damage_datas()->Dictionary:
	return weapon_attack_data.get("DamageDatas", {})

func get_effect_on_attack_data()->Dictionary:
	return weapon_attack_data.get("EffectDatas", {})

func get_misile_data()->Dictionary:
	return get_load_val("MissileData", {})

func get_default_weapon_animation_name()->String:
	return weapon_data.get("WeaponSpriteData", {}).get("WeaponAnimation", "")

class_name BaseWeaponEquipment
extends BaseEquipmentItem

enum WeaponClasses {Light, Medium, Heavy}

var target_parmas:TargetParameters

func _init(key:String, def_load_path:String, def:Dictionary, id:String='', data:Dictionary={}) -> void:
	super(key, def_load_path, def, id, data)
	target_parmas = TargetParameters.new("Weapon", get_load_val("TargetParams", {}))

func get_equipment_slot_type()->String:
	return "Weapon"

func get_weapon_class()->WeaponClasses:
	var val = get_load_val("WeaponClass", '')
	if WeaponClasses.keys().has(val):
		return WeaponClasses.get(val)
	return WeaponClasses.Medium

func get_damage_data()->Dictionary:
	return get_load_val("DamageData", {})

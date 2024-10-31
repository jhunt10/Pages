class_name BaseWeaponEquipment
extends BaseEquipmentItem

var target_parmas:TargetParameters


func _init(key:String, def_load_path:String, def:Dictionary, id:String='', data:Dictionary={}) -> void:
	super(key, def_load_path, def, id, data)
	target_parmas = TargetParameters.new("TargetParams", get_load_val("TargetParams", {}))

func get_equip_slot()->String:
	return "Weapon"

func get_damage_data()->Dictionary:
	return get_load_val("DamageData", {})

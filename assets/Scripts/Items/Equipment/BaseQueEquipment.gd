class_name BaseQueEquipment
extends BaseEquipmentItem

func get_equipment_slot_type()->String:
	return "Que"

func _init(key:String, def_load_path:String, def:Dictionary, id:String='', data:Dictionary={}) -> void:
	super(key, def_load_path, def, id, data)

func get_max_page_count()->int:
	var val = get_load_val("MaxPageCount", 0)
	return val

func get_pages_per_round()->int:
	return get_load_val("PagesPerRound", 0)

func get_stat_mods()->Array:
	print("PagesPerRound: %s" % [get_pages_per_round()])
	var ppr_mod = BaseStatMod.new(_id, "PagesPerRound", "", BaseStatMod.ModTypes.Add, get_pages_per_round())
	return [ppr_mod]

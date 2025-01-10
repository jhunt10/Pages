class_name PassiveStatModEffect
extends BaseEffect

var _stat_mods:Dictionary = {}

func _init(key:String, def_load_path:String, def:Dictionary, id:String='', data:Dictionary={}) -> void:
	super(key, def_load_path, def, id, data)
	var mod_datas = get_load_val("StatMods", {}) 
	for mod_key in mod_datas.keys():
		var mod_data = mod_datas[mod_key]
		_stat_mods[mod_key] = BaseStatMod.create_from_data(self.Id, mod_data)


func show_in_hud()->bool:
	return false

func get_active_stat_mods():
	return _stat_mods.values()

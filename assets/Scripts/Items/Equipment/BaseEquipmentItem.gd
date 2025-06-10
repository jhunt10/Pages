class_name BaseEquipmentItem
extends BaseItem


var equipment_data:Dictionary:
	get:
		return _def.get("EquipmentData", {})

func get_item_type()->ItemTypes:
	return ItemTypes.Equipment

func get_item_tags()->Array:
	var tags = super()
	if !tags.has("Equipment"):
		tags.append("Equipment")
	return tags

func get_equipment_slot_type()->String:
	return equipment_data.get("EquipSlot", "UNSET")

func has_spite_sheet()->bool:
	return equipment_data.get("SpriteData", {}).has('SpriteSheet')
func get_sprite_sheet_file_path():
	var file_name = equipment_data.get("SpriteData", {}).get('SpriteSheet', null)
	if !file_name:
		return null
	return _def_load_path.path_join(file_name)

func get_passive_stat_mods()->Array:
	var stat_mod_datas:Dictionary = equipment_data.get("StatMods", {})
	var out_list = []
	for mod_data in stat_mod_datas.values():
		if not mod_data.has("DisplayName"):
			mod_data['DisplayName'] = self.get_display_name()
		out_list.append(BaseStatMod.create_from_data(Id, mod_data))
	return out_list

func get_target_mods()->Array:
	var stat_mod_datas:Dictionary = equipment_data.get("TargetMods", {})
	var out_list = []
	for mod_data in stat_mod_datas.values():
		out_list.append(mod_data.duplicate())
	return out_list

func get_damage_mods()->Dictionary:
	var mod_datas:Dictionary = equipment_data.get("DamageMods", {})
	var out_dict = {}
	for mod_key in mod_datas.keys():
		var mod_data = mod_datas[mod_key]
		if mod_data.has("DamageModKey"):
			mod_key = mod_data['DamageModKey']
		else:
			mod_data['DamageModKey'] = mod_key
		if not mod_data.has("DisplayName"):
			mod_data['DisplayName'] = self.get_display_name()
		
		out_dict[mod_key] = mod_data
	return out_dict

func get_attack_mods()->Dictionary:
	var mod_datas:Dictionary = equipment_data.get("AttackMods", {})
	var out_dict = {}
	for mod_key in mod_datas.keys():
		var mod_data = mod_datas[mod_key]
		if mod_data.has("AttackModKey"):
			mod_key = mod_data['AttackModKey']
		else:
			mod_data['AttackModKey'] = mod_key
		if not mod_data.has("DisplayName"):
			mod_data['DisplayName'] = self.get_display_name()
		
		out_dict[mod_key] = mod_data
	return out_dict

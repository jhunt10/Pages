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

func get_tags_added_to_actor()->Array:
	return equipment_data.get("AddTags", [])

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

func get_ammo_mods()->Dictionary:
	var mod_datas:Dictionary = equipment_data.get("AmmoMods", {})
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

## Returns a diction of failed requirements, mapped by requirment type 
func get_cant_use_reasons(actor:BaseActor):
	var requirment_data = equipment_data.get("Requirments", {})
	var missing_requirements = super(actor)
	
	for tag in requirment_data.get("ReqTags", []):
		if not actor.get_tags().has(tag):
			if not missing_requirements.has("Tags"):
				missing_requirements['Tags'] = []
			missing_requirements['Tags'].append(tag)
	
	var req_stat_data = requirment_data.get("ReqStats", {})
	for stat_name in req_stat_data.keys():
		var req_val = req_stat_data[stat_name]
		var stat_val = actor.stats.get_stat(stat_name)
		if stat_val < req_val:
			if not missing_requirements.has("Stats"):
				missing_requirements['Stats'] = {}
			missing_requirements['Stats'][stat_name] = req_val
	
	var req_equipment_data = requirment_data.get("ReqEquip", {})
	for weapon_filter in req_equipment_data.get("WeaponFilters", []):
		var weapons = actor.equipment.get_filtered_weapons(weapon_filter)
		if weapons.size() == 0:
			if not missing_requirements.has("Equipment"):
				missing_requirements['Equipment'] = []
			var weapon_slots = weapon_filter.get("IncludeSlots", [])
			if weapon_slots.size() == 1:
				missing_requirements['Equipment'].append(weapon_slots[0] + " Weapon")
			else:
				missing_requirements['Equipment'].append("Weapon")
	for slot_name in req_equipment_data.get("SlotToTag", {}).keys():
		var req_tag = req_equipment_data[slot_name]
		var equipt_items = actor.equipment.get_equipt_items_of_slot_type(slot_name)
		if req_tag == "Any" and equipt_items.size() > 0:
			continue
		var has_tag = false
		for equipt_item:BaseEquipmentItem in equipt_items:
			if equipt_item.get_item_tags().has(req_tag):
				has_tag = true
				break
		if not has_tag:
			if not missing_requirements.has("Equipment"):
				missing_requirements['Equipment'] = []
			if req_tag == "Any":
				missing_requirements['Equipment'].append(slot_name)
			else:
				missing_requirements['Equipment'].append(req_tag)
	return missing_requirements
	return {}

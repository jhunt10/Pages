class_name BasePageItem
extends BaseItem

var has_action:bool = false

var page_data:Dictionary:
	get:
		return _def.get("PageData", {})

func get_item_type()->ItemTypes:
	return ItemTypes.Page

func _init(key:String, def_load_path:String, def:Dictionary, id:String='', data:Dictionary={}) -> void:
	super(key, def_load_path, def, id, data)
	var details_data = def.get("Details", {})
	var page_data = def.get("PageData", {})
	var action_key = page_data.get("ActionKey")
	var effect_key = page_data.get("EffectKey")
	if action_key and not effect_key:
		has_action = true
		var action_def = ActionLibrary.get_action_def(action_key)
		var org_detail_data =  action_def.get("Details", {"Tags":[]})
		if not org_detail_data['Tags'].has("Action"):
			org_detail_data['Tags'].append("Action")
		details_data = BaseLoadObjectLibrary._merge_defs(details_data,org_detail_data)
		if ActionLibrary.Instance._defs_to_load_paths.has(action_key):
			details = ObjectDetailsData.new(ActionLibrary.Instance._defs_to_load_paths[action_key], details_data)
	if effect_key and not action_key:
		var effect_def = EffectLibrary.get_effect_def(effect_key)
		var org_detail_data =  effect_def.get("Details", {"Tags":[]})
		if not org_detail_data['Tags'].has("Passive"):
			org_detail_data['Tags'].append("Passive")
		details_data = BaseLoadObjectLibrary._merge_defs(details_data,org_detail_data)
		details = ObjectDetailsData.new(EffectLibrary.Instance._defs_to_load_paths[effect_key], details_data)
	#self._data['ItemDetails'] = details_data

func is_passive_page():
	var action_key = get_load_val("ActionKey", '')
	return action_key == null or action_key == ''

func get_action_key():
	return get_load_val("ActionKey")

func get_action()->BaseAction:
	var action_key = get_load_val("ActionKey")
	if action_key:
		return ActionLibrary.get_action(action_key)
	return null

func get_effect_def():
	var effect_data:Dictionary = page_data.get("EffectDatas", {})
	var effect_key = effect_data.get("EffectKey", null)
	if !effect_key:
		var effect_datas = effect_data
	if effect_key:
		return EffectLibrary.get_merged_effect_def(effect_key, effect_data)
	return null


func get_item_tags()->Array:
	var tags = []
	if has_action: 
		var action = get_action()
		if action: 
			tags = action.get_tags()
	else:
		tags = super()
	if not tags.has("Page"):
		tags.append("Page")
	return tags
func get_display_name()->String:
	if has_action: 
		var action = get_action()
		if action: return action.get_display_name()
	return super()
func get_description()->String:
	if has_action: 
		var action = get_action()
		if action: return action.get_description()
	return super()
func get_snippet()->String:
	if has_action: 
		var action = get_action()
		if action: return action.get_snippet()
	return super()
func get_large_icon()->Texture2D:
	if has_action: 
		var action = get_action()
		if action: return action.get_large_icon()
	return super()
func get_small_icon()->Texture2D:
	if has_action: 
		var action = get_action()
		if action: return action.get_small_icon()
	return super()
func get_tags()->Array:
	if has_action: 
		var action = get_action()
		if action: return action.get_tags()
	return super()

func get_tags_added_to_actor()->Array:
	return page_data.get("AddTags", [])


func get_rarity_background()->Texture2D:
	return ItemHelper.get_rarity_background(self.get_item_rarity(), is_passive_page())

func has_spite_sheet()->bool:
	return get_load_val("SpriteSheet", null) != null

func get_sprite_sheet_file_path():
	var file_name = get_load_val("SpriteSheet", null)
	if !file_name:
		return null
	return _def_load_path.path_join(file_name)


func get_passive_stat_mods()->Array:
	var stat_mod_datas:Dictionary = page_data.get("StatMods", {})
	var out_list = []
	for mod_data in stat_mod_datas.values():
		if not mod_data.has("DisplayName"):
			mod_data['DisplayName'] = self.get_display_name()
		out_list.append(BaseStatMod.create_from_data(Id, mod_data))
	return out_list

func get_damage_mods()->Dictionary:
	var mod_datas:Dictionary = page_data.get("DamageMods", {})
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
	var mod_datas:Dictionary = page_data.get("AttackMods", {})
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

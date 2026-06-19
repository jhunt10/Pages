class_name PageItemAction
extends BasePageItem

const SUB_ACTIONS_PER_ACTION = 24

signal ammo_changed

var action_data:Dictionary:
	get:
		return get_load_val("ActionData", {})
var ActionKey:String:
	get:
		return _key

var _target_params:Dictionary
var _init_data:Dictionary
var _action_mods_cache:Dictionary

var _current_ammo:float = 0

func get_tagable_id(): return ActionKey

func _init(key:String, def_load_path:String, def:Dictionary, id:String='', data:Dictionary={}) -> void:
	super(key, def_load_path, def, id, data)
	_init_data = data.duplicate(true)
	_cache_after_loading_def()

func reload_def(load_path:String, def:Dictionary):
	super(load_path, def)
	_cache_after_loading_def()

func _cache_after_loading_def():
	# Build Target Params
	if _def.get("ActionData", {}).has('TargetParams'):
		var targ_parms = _def.get("ActionData", {}).get('TargetParams')
		for tparm_key in targ_parms.keys():
			if tparm_key == "WeaponParamOverride":
				_target_params[tparm_key] = targ_parms[tparm_key]
			else:
				_target_params[tparm_key] = TargetParameters.new(tparm_key, targ_parms[tparm_key])

func get_tags()->Array:
	var tags = super()
	if not tags.has("Action"):
		tags.append("Action")
	return tags

func _get_object_specific_tags()->Array:
	var tags = []
	var sub_act_datas = get_sub_action_data()
	for sub_act_data in sub_act_datas.values():
		var script_path = sub_act_data.get("!SubActionScript")
		var script:BaseSubAction = ActionLibrary.get_sub_action_script(script_path)
		if !script:
			printerr("%s.get_tags: Failed to find SubAction script '%s'." %[self.ActionKey, script_path])
			continue
		var sub_tags = script.get_action_tags(self, sub_act_data)
		TagHelper.merge_lists(tags, sub_tags)
	
	if not tags.has("Action"):
		tags.append("Action")
	TagHelper.merge_lists(tags, super())
	return tags

func save_data()->Dictionary:
	var data = _init_data.duplicate()
	data['ObjectKey'] = self._key
	data['Id'] = self._id
	return data

#######################
##   Actions Mods    ##
#######################
func get_action_mods_meta_data()->Dictionary:
	return _action_mods_cache

func add_action_mod(mod_data:Dictionary):
	var mod_key = mod_data.get("ModKey")
	if !mod_key:
		printerr("PageItemAction.add_action_mod: No 'ModKey' found on mod_data.")
		return
	# Mod already added
	if _action_mods_cache.keys().has(mod_key):
		return
	var mod_def_data = mod_data.get("ModdedDefData", {})
	_action_mods_cache[mod_key] = {
		"ModKey": mod_key,
		"DisplayName": mod_data.get("DisplayName", mod_key),
		"SourceItemId": mod_data.get("SourceItemId", "")
	}
	self._data = BaseLoadObjectLibrary._merge_defs(mod_def_data, self._data)
	# Build Target Params
	if mod_def_data.get("ActionData", {}).has('TargetParams'):
		_target_params.clear()
		var targ_parms = action_data.get('TargetParams')
		for tparm_key in targ_parms.keys():
			_target_params[tparm_key] = TargetParameters.new(tparm_key, targ_parms[tparm_key])

func clear_action_mods():
	var rebuild_targets = _action_mods_cache.size() > 0
	_action_mods_cache.clear()
	self._data = self._init_data.duplicate(true)
	if rebuild_targets:
		_target_params.clear()
		var targ_parms = action_data.get('TargetParams')
		if targ_parms:
			for tparm_key in targ_parms.keys():
				_target_params[tparm_key] = TargetParameters.new(tparm_key, targ_parms[tparm_key])
	
	

#######################
##    Sub Actions    ##
#######################

## Returns raw Dictionary of SubAction data
func get_sub_action_data()->Dictionary:
	return action_data.get("SubActions", {})

func get_sub_action_datas_for_frame(frame_index:int)->Array:
	var out_list = []
	var sub_actions_data = get_sub_action_data()
	for key in sub_actions_data.keys():
		var data = sub_actions_data[key]
		if data.get("#FrameIndex", -1) == frame_index:
			out_list.append(data)
	out_list.sort_custom(sort_subacts_ascending)
	return out_list
	
func sort_subacts_ascending(a, b):
	if a.get("#SubIndex", 0) < b.get("#SubIndex", 0):
		return true
	return false


########################
##    Icons  Data     ##
########################

func get_qued_icon(turn_index:int, que:ActionQue, override_actor:BaseActor =  null)->Texture2D:
	# If qued by a Carrier Actor, we need to use thier QueExecData
	if action_data.get("Preview", {}).get("UseDynamicIcons", false):
		var turn_data = que.QueExecData.get_data_for_turn(turn_index)
		var icon = turn_data.on_que_data.get("OverrideQueIcon", null)
		if icon:
			return icon
	var use_actor = override_actor
	if use_actor == null and has_holding_actor():
		use_actor = get_holding_actor()
	var equip_slot = action_data.get("Preview", {}).get("UseEquipmentIcon", null)
	if equip_slot:
		var equipments = use_actor.equipment.get_equipt_items_of_slot_type(equip_slot)
		if equipments.size() > 0:
			var equipment:BaseEquipmentItem = equipments[0]
			var overlay_sprite = action_data.get("Preview", {}).get("OverlaySprite", '')
			if overlay_sprite and overlay_sprite != '':
				return SpriteCache.get_item_overlay_sprite(equipment, get_load_path().path_join(overlay_sprite))
			else:
				return equipment.get_small_icon()
	return get_small_page_icon(use_actor)

# Should Page be duplicated in the ActionQueInput when merged players have multiple copies
# Naive Actions like "Move XXX" should not be duplicated
# Actor specific Actions like "Weapon Attack" should be duplicated
func is_duplicated_when_merged()->bool:
	if action_data.get("Preview", {}).get("UseEquipmentIcon", null) != null:
		return true
	return false

func use_equipment_icon()->bool:
	return action_data.get("Preview", {}).get("UseEquipmentIcon", null) != null

func  get_small_page_icon(override_actor:BaseActor = null)->Texture2D:
	var use_actor = override_actor
	if use_actor == null and has_holding_actor():
		use_actor = get_holding_actor()
	if use_actor:
		var equip_slot = action_data.get("Preview", {}).get("UseEquipmentIcon", null)
		if equip_slot:
			var equipments = use_actor.equipment.get_equipt_items_of_slot_type(equip_slot)
			if equipments.size() > 0:
				var equipment:BaseEquipmentItem = equipments[0]
				var overlay_sprite = action_data.get("Preview", {}).get("OverlaySprite", '')
				if overlay_sprite and overlay_sprite != '':
					return SpriteCache.get_item_overlay_sprite(equipment, get_load_path().path_join(overlay_sprite))
				else:
					return equipment.get_large_icon()
	return get_small_icon()

func  get_large_page_icon(override_actor:BaseActor = null)->Texture2D:
	var use_actor = override_actor
	if use_actor == null and has_holding_actor():
		use_actor = get_holding_actor()
	if use_actor:
		var equip_slot = action_data.get("Preview", {}).get("UseEquipmentIcon", null)
		if equip_slot:
			var equipments = use_actor.equipment.get_equipt_items_of_slot_type(equip_slot)
			if equipments.size() > 0:
				var equipment:BaseEquipmentItem = equipments[0]
				var overlay_sprite = action_data.get("Preview", {}).get("OverlaySprite", '')
				if overlay_sprite and overlay_sprite != '':
					return SpriteCache.get_item_overlay_sprite(equipment, get_load_path().path_join(overlay_sprite))
				else:
					return equipment.get_large_icon()
	return get_large_icon()



########################
##    Preview Data    ##
########################
var _cached_preview_move_offset = null
func has_preview_move_offset()->bool:
	if _cached_preview_move_offset != null:
		return true
	var preview_data:Dictionary = action_data.get("Preview", {})
	var preview_key = preview_data.get("PreviewMoveOffset", null)
	return preview_key and preview_key != ''
	
func get_preview_move_offset()->MapPos:
	if _cached_preview_move_offset != null:
		return _cached_preview_move_offset
	if !has_preview_move_offset():
		return null
	var preview_data:Dictionary = action_data.get("Preview", {})
	var pre_move_arr = preview_data.get("PreviewMoveOffset", null)
	if !pre_move_arr:
		return null
	if pre_move_arr is String:
		pre_move_arr = JSON.parse_string(pre_move_arr)
	_cached_preview_move_offset = MapPos.new(pre_move_arr[0],pre_move_arr[1],pre_move_arr[2],pre_move_arr[3])
	return _cached_preview_move_offset

func has_preview_target()->bool:
	var preview_data:Dictionary = action_data.get("Preview", {})
	var preview_key = preview_data.get("PreviewTargetKey", null)
	return preview_key and preview_key != ''

func get_preview_target_params(actor:BaseActor)->TargetParameters:
	var preview_data:Dictionary = action_data.get("Preview", {})
	var preview_key = preview_data.get("PreviewTargetKey", null)
	if not preview_key or preview_key == '':
		printerr("No preview key")
		return null
	return get_targeting_params(preview_key, actor)

func has_preview_damage()->bool:
	var preview_data:Dictionary = action_data.get("Preview", {})
	var preview_key = preview_data.get("PreviewDamageKey", null)
	if preview_key and preview_key != '':
		return true
	var preview_keys = preview_data.get("PreviewDamageKeys", [])
	return preview_keys.size() > 0

func get_preview_damage_datas(actor:BaseActor=null)->Dictionary:
	var preview_data:Dictionary = action_data.get("Preview", {})
	var preview_key = preview_data.get("PreviewDamageKey", null)
	var preview_keys = preview_data.get("PreviewDamageKeys", [])
	if preview_key and preview_key != '' and not preview_keys.has(preview_key):
		preview_keys.append(preview_key)
	#if not preview_key or preview_key == '':
		#printerr("%s.get_preview_damage_datas: No preview key" % [self.ActionKey])
		#return {}
	var damage_datas = get_damage_datas(actor, preview_keys)
	
	if preview_data.keys().has("PreviewDamageCounts"):
		var damage_counts = preview_data['PreviewDamageCounts']
		for key in damage_counts.keys():
			if damage_datas.keys().has(key):
				damage_datas[key]['PreviewCount'] = damage_counts[key]
	return damage_datas


########################
##      Get Datas     ##
########################
func get_targeting_params(target_param_key, actor:BaseActor)->TargetParameters:
	var params = null
	# Self Targeting
	if target_param_key == "Self":
		params = TargetParameters.SelfTargetParams
	# Weapon based Targeting
	elif target_param_key == "Weapon":
		if actor:
			var param_def:Dictionary = actor.get_weapon_attack_target_param_def(target_param_key)
			if _target_params.has("WeaponParamOverride"):
				var weapon_override = _target_params.get("WeaponParamOverride")
				param_def = BaseLoadObjectLibrary._merge_defs(param_def, weapon_override)
			return TargetParameters.new(target_param_key, param_def)
		else:
			printerr("%s.get_targeting_params: Requested Weapon TargetParams without an Actor.")
			return null
	# From Def
	elif _target_params.keys().has(target_param_key):
		params = _target_params.get(target_param_key, null)
	
	if !params:
		printerr("%s.get_targeting_params: No Target Params found for key '%s'." % [self.ActionKey, target_param_key])
		return null
	
	# Apply target mods from actor
	if actor:
		var self_tags = self.get_tags()
		for mod in actor.get_targeting_mods():
			var action_tag_filters = mod.get('ActionTagFilters', [])
			if TagHelper.filters_accept_tags(action_tag_filters, self_tags):
				params = params.apply_target_mod(mod)
	return params

func get_damage_data_single(actor:BaseActor, damage_key:String)->Dictionary:
	var datas = get_damage_datas(actor, [damage_key])
	if damage_key.contains("Weapon"):
		printerr("PageItemAction.get_damage_data_single probably used on Weapon Damage Data (which is sometimes not single)")
	return datas.get(damage_key, {})

func get_damage_datas(actor:BaseActor, damage_keys)->Dictionary:
	var out_dict = {}
	if damage_keys is String:
		if damage_keys.to_lower() == "all":
			damage_keys = action_data.get("DamageDatas", {}).keys()
		else:
			damage_keys = [damage_keys]
	
	var preview_data:Dictionary = action_data.get("Preview", {})
	var preview_damage_counts = preview_data.get("PreviewDamageCounts", {})
	for key in damage_keys:
		var damage_data = action_data.get("DamageDatas", {}).get(key, {}).duplicate(true)
		# Weapon Damage Data
		if damage_data.has("WeaponFilter"):
			var page_owner_actor = self.get_holding_actor()
			var use_actor = actor
			if use_actor == null:
				use_actor = page_owner_actor
			elif use_actor != page_owner_actor and use_actor is CarrierActor: 
				if (use_actor as CarrierActor).is_holding_actor(page_owner_actor):
					use_actor = page_owner_actor
			if use_actor:
				damage_data['ActorlessWeapon'] = false
				var weapon_filter = damage_data['WeaponFilter']
				var override_data = damage_data.duplicate()
				override_data.erase("WeaponFilter")
				var weapon_damage_datas = use_actor.get_weapon_damage_datas(weapon_filter)
				print(weapon_filter)
				for weapon_damage_key in weapon_damage_datas.keys():
					var sub_key = key + ":" + weapon_damage_key
					out_dict[sub_key] = BaseLoadObjectLibrary._merge_defs(damage_data, weapon_damage_datas[weapon_damage_key])
			else:
				# Page requires weapon but provided actor has non
				damage_data['ActorlessWeapon'] = true
				out_dict[key] = damage_data
		elif damage_data.size() > 0:
			out_dict[key] = damage_data
		else:
			printerr("%s.get_damage_datas: No Damage Data found for key '%s'." % [self.ActionKey, key])
			continue
		if preview_damage_counts.keys().has(key):
			out_dict[key]['PreviewCount'] = preview_damage_counts[key]
	return out_dict

########################
##    Icons  Data     ##
########################

func _get_ammo_data():
	var ammo_data = action_data.get("AmmoData", 
	{
		"AmmoType": "None",
		"Clip": 0,
		"Cost": 0
	})
	ammo_data['AmmoKey'] = self._key # size() is checked later in has_ammo
	return ammo_data

func has_ammo()->bool:
	if not action_data.has("AmmoData"):
		return false
	var ammo_data = _get_ammo_data()
	return ammo_data['AmmoType'] != "None"

func get_ammo_type()->AmmoItem.AmmoTypes:
	var ammo_data = _get_ammo_data()
	var val = AmmoItem.AmmoTypes[ammo_data['AmmoType']]
	if val :
		return val
	return AmmoItem.AmmoTypes.None

func get_ammo_max():
	var ammo_data = _get_ammo_data()
	return ammo_data.get("Clip", 0)

func get_ammo_cost_per_use():
	var ammo_data = _get_ammo_data()
	return ammo_data.get("Cost", 0)

func get_ammo_current():
	return _current_ammo

func get_ammo_remaining_uses()->int:
	var ammo_data = _get_ammo_data()
	var cost = ammo_data.get("Cost", 0)
	var remaining = floori(_current_ammo / cost)
	return remaining

func refill_ammo():
	_current_ammo = get_ammo_max()
	ammo_changed.emit()

func can_pay_ammo_cost()->bool:
	var cost = get_ammo_cost_per_use()
	return  cost <= _current_ammo

func pay_ammo_cost():
	var cost = get_ammo_cost_per_use()
	_current_ammo = max(0, _current_ammo - cost)
	ammo_changed.emit()
		

func get_on_que_options(actor:BaseActor, game_state:GameStateData):
	var out_dict = {}
	var sub_action_datas = get_sub_action_data()
	for sub_action_data in sub_action_datas.values():
		var sub_action = ActionLibrary.get_sub_action_script(sub_action_data['!SubActionScript'])
		if !sub_action:
			printerr("PageAction.get_on_que_options: Failed to find SubActionScript '%s'." % [sub_action_data['!SubActionScript']])
			continue
		var options = sub_action.get_on_que_options(self, sub_action_data, actor, game_state)
		for option:OnQueOptionsData in options:
			out_dict[option.option_key] = option
	return out_dict

func get_effect_data(effect_data_key:String)->Dictionary:
	var effect_datas = action_data.get("EffectDatas", {})
	if effect_datas.has(effect_data_key):
		return effect_datas[effect_data_key].duplicate()
	return {}

func get_missile_data(missile_key:String)->Dictionary:
	var missile_data = action_data.get("MissileDatas", {})
	if missile_data.has(missile_key):
		var data = missile_data[missile_key].duplicate()
		data['LoadPath'] = _def_load_path
		return data
	return {}

func get_attack_details()->Dictionary:
	return action_data.get("AttackDetails", {})

func get_attack_vfx_data():
	var attack_details = action_data.get("AttackDetails", {})
	var vfx_key = attack_details.get("AttackVfxKey")
	var vfx_data = attack_details.get("AttackVfxData", {})
	var vfx_def = VfxLibrary.get_vfx_def(vfx_key, vfx_data, self)
	return vfx_def
		
func get_zone_data(zone_key:String)->Dictionary:
	var zones = action_data.get("ZoneDatas", {})
	return zones.get(zone_key, {})

	

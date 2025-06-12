class_name PageItemAction
extends BasePageItem

const SUB_ACTIONS_PER_ACTION = 24

var action_data:Dictionary:
	get:
		return get_load_val("ActionData", {})

var ActionKey:String:
	get:
		return _key

var _target_params:Dictionary

func _init(key:String, def_load_path:String, def:Dictionary, id:String='', data:Dictionary={}) -> void:
	super(key, def_load_path, def, id, data)
	# Build Target Params
	if def.get("ActionData", {}).has('TargetParams'):
		var targ_parms = def.get("ActionData", {}).get('TargetParams')
		for tparm_key in targ_parms.keys():
			_target_params[tparm_key] = TargetParameters.new(tparm_key, targ_parms[tparm_key])



func get_item_tags()->Array:
	var tags = []
	tags = super()
	if not tags.has("Action"):
		tags.append("Action")
	return tags

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
func get_qued_icon(turn_index:int, actor:BaseActor =  null)->Texture2D:
	if action_data.get("Preview", {}).get("UseDynamicIcons", false):
		var turn_data = actor.Que.QueExecData.get_data_for_turn(turn_index)
		var icon = turn_data.on_que_data.get("OverrideQueIcon", null)
		if icon:
			return icon
	var equip_slot = action_data.get("Preview", {}).get("UseEquipmentIcon", null)
	if equip_slot:
		var equipments = actor.equipment.get_equipt_items_of_slot_type(equip_slot)
		if equipments.size() > 0:
			var equipment:BaseEquipmentItem = equipments[0]
			return equipment.get_small_icon()
	return get_small_page_icon(actor)

func use_equipment_icon()->bool:
	return action_data.get("Preview", {}).get("UseEquipmentIcon", null) != null

func  get_small_page_icon(actor:BaseActor = null)->Texture2D:
	if actor:
		var equip_slot = action_data.get("Preview", {}).get("UseEquipmentIcon", null)
		if equip_slot:
			var equipments = actor.equipment.get_equipt_items_of_slot_type(equip_slot)
			if equipments.size() > 0:
				var equipment:BaseEquipmentItem = equipments[0]
				return equipment.get_large_icon()
	return get_small_icon()

func  get_large_page_icon(actor:BaseActor = null)->Texture2D:
	if actor:
		var equip_slot = action_data.get("Preview", {}).get("UseEquipmentIcon", null)
		if equip_slot:
			var equipments = actor.equipment.get_equipt_items_of_slot_type(equip_slot)
			if equipments.size() > 0:
				var equipment:BaseEquipmentItem = equipments[0]
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
	return preview_key and preview_key != ''

func get_preview_damage_datas(actor:BaseActor=null)->Dictionary:
	var preview_data:Dictionary = action_data.get("Preview", {})
	var preview_key = preview_data.get("PreviewDamageKey", null)
	if not preview_key or preview_key == '':
		printerr("%s.get_preview_damage_datas: No preview key" % [self.ActionKey])
		return {}
	return get_damage_datas(actor, preview_key)


########################
##      Get Datas     ##
########################
func get_targeting_params(target_param_key, actor:BaseActor)->TargetParameters:
	var params = null
	if target_param_key == "Self":
		params = TargetParameters.SelfTargetParams
	elif target_param_key == "Weapon":
		if actor:
			params = actor.get_weapon_attack_target_params(target_param_key)
	else:
		params = _target_params.get(target_param_key, null)
	if !params:
		printerr("%s.get_targeting_params: No Target Params found for key '%s'." % [self.ActionKey, target_param_key])
		return null
	if actor:
		var targeting_mods = actor.get_targeting_mods()
		var self_tags = self.get_tags()
		for mod in targeting_mods:
			var required_tags = mod.get('RequiredActionTags', [])
			var can_use = true
			for required in required_tags:
				if not self_tags.has(required):
					can_use = false
					break
			if can_use:
				params = params.apply_target_mod(mod)
	return params

func get_damage_datas(actor:BaseActor, damage_keys)->Dictionary:
	var out_dict = {}
	if damage_keys is String:
		damage_keys = [damage_keys]
	for key in damage_keys:
		var damage_data = action_data.get("DamageDatas", {}).get(key, {})
		if damage_data.has("WeaponFilter"):
			if actor:
				var weapon_filter = damage_data['WeaponFilter']
				var override_data = damage_data.duplicate()
				override_data.erase("WeaponFilter")
				var weapon_damage_datas = actor.get_weapon_damage_datas(weapon_filter)
				for weapon_damage_key in weapon_damage_datas.keys():
					var sub_key = key + ":" + weapon_damage_key
					out_dict[sub_key] = BaseLoadObjectLibrary._merge_defs(damage_data, weapon_damage_datas[weapon_damage_key])
			else:
				damage_data['ActorlessWeapon'] = true
				out_dict[key] = damage_data
		elif damage_data.size() > 0:
			out_dict[key] = damage_data
		else:
			printerr("%s.get_damage_datas: No Damage Data found for key '%s'." % [self.ActionKey, key])
			continue
	return out_dict

func has_ammo(actor:BaseActor=null):
	var ammo_data = action_data.get("AmmoData", null)
	return ammo_data and ammo_data.size() > 0

func get_ammo_data():
	var ammo_data = action_data.get("AmmoData", null)
	if ammo_data:
		ammo_data['AmmoKey'] = self._key
	return ammo_data
		

func get_on_que_options(actor:BaseActor, game_state:GameStateData):
	var out_dict = {}
	for sub_action_data in get_sub_action_data().values():
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

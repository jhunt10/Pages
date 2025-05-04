class_name BaseAction
extends BaseLoadObject

#const TargetParameters = preload("res://assets/Scripts/Targeting/TargetParameters.gd")

const SUB_ACTIONS_PER_ACTION = 24

var ActionKey:String:
	get: return self._key

var SubActionData:Array = []

var CostData:Dictionary:
		get: return get_load_val('CostData', {})
var DamageDatas:Dictionary:
		get: return get_load_val('DamageDatas', {})
var _missile_data
var MissileDatas:Dictionary:
		get:
			if _missile_data == null:
				_missile_data = get_load_val('MissileDatas', {})
				for key in _missile_data.keys():
					if not _missile_data[key].has("DisplayName"):
						_missile_data[key]['DisplayName'] = details.display_name + " Missile"
			return _missile_data

var OnQueUiState:String:
	get: return get_load_val("OnQueUiState", "")
var _target_params:Dictionary

func get_tagable_id(): return ActionKey
func get_tags(): return details.tags

var PreviewMoveOffset:MapPos

func _init(key:String, def_load_path:String, def:Dictionary, id:String='', data:Dictionary={}) -> void:
	super(key, def_load_path, def, id, data)
	# Load Targeting Parameters
	if def.has('TargetParams'):
		if def['TargetParams'] is Array:
			for tparm in def['TargetParams']:
				_target_params[tparm['TargetKey']] = TargetParameters.new(tparm['TargetKey'], tparm)
		if def['TargetParams'] is Dictionary:
			for tparm_key in def['TargetParams'].keys():
				_target_params[tparm_key] = TargetParameters.new(tparm_key, def['TargetParams'][tparm_key])
		
	# Load SubAction Data, missing indexes are left null
	# The ActionQueController will create the subaction on demand
	SubActionData = []
	for index in range(SUB_ACTIONS_PER_ACTION):
		var subData = def.get('SubActions', {}).get(str(index), null)
		if not subData:
			SubActionData.append(null)
		elif subData is Dictionary:
			if subData.has('SubActionScript'):
				SubActionData.append([subData])
		elif subData is Array:
			SubActionData.append(subData)
		else:
			printerr("Uknown SubActionType: " + str(subData))
	
	if def.keys().has("Preview"):
		var preview_data = def.get("Preview", {})
		if preview_data.keys().has("PreviewMoveOffset"):
			var pre_move_arr = []
			if preview_data['PreviewMoveOffset'] is Array:
				pre_move_arr = def["PreviewMoveOffset"]
			if preview_data['PreviewMoveOffset'] is String:
				pre_move_arr = JSON.parse_string(preview_data['PreviewMoveOffset'])
			PreviewMoveOffset = MapPos.new(pre_move_arr[0],pre_move_arr[1],pre_move_arr[2],pre_move_arr[3])

func get_qued_icon(turn_index:int, actor:BaseActor =  null)->Texture2D:
	if self.get_load_val("UseDynamicIcons", false):
		var turn_data = actor.Que.QueExecData.get_data_for_turn(turn_index)
		var icon = turn_data.on_que_data.get("OverrideQueIcon", null)
		if icon:
			return icon
	var equip_slot = get_load_val("UseEquipmentIcon", null)
	if equip_slot:
		var equipments = actor.equipment.get_equipt_items_of_slot_type(equip_slot)
		if equipments.size() > 0:
			var equipment:BaseEquipmentItem = equipments[0]
			return equipment.get_small_icon()
	return get_small_page_icon(actor)

func  get_small_page_icon(actor:BaseActor = null)->Texture2D:
	if actor:
		var equip_slot = get_load_val("UseEquipmentIcon", null)
		if equip_slot:
			var equipments = actor.equipment.get_equipt_items_of_slot_type(equip_slot)
			if equipments.size() > 0:
				var equipment:BaseEquipmentItem = equipments[0]
				return equipment.get_large_icon()
	return SpriteCache.get_sprite(details.small_icon_path)

func use_equipment_icon()->bool:
	return get_load_val("UseEquipmentIcon", null) != null

func  get_large_page_icon(actor:BaseActor = null)->Texture2D:
	if actor:
		var equip_slot = get_load_val("UseEquipmentIcon", null)
		if equip_slot:
			var equipments = actor.equipment.get_equipt_items_of_slot_type(equip_slot)
			if equipments.size() > 0:
				var equipment:BaseEquipmentItem = equipments[0]
				return equipment.get_large_icon()
	return SpriteCache.get_sprite(details.large_icon_path)

func list_sub_action_datas()->Array:
	var out_list = []
	for frame_sub_actions in SubActionData:
		if frame_sub_actions and frame_sub_actions is Array:
			for data in frame_sub_actions:
				out_list.append(data)
	return out_list

func get_damage_data(damage_data_key:String, actor:BaseActor=null)->Dictionary:
	if damage_data_key == "Weapon":
		if actor == null:
			printerr("BaseAction.get_damage_data: Null Actor when asking for Weapon damage.")
			return {}
		var weapon = actor.equipment.get_primary_weapon()
		if !weapon:
			printerr("BaseAction.get_damage_data: No Weapon when asking for Weapon damage.")
			return {}
		return weapon.get_damage_data()
	var damage_datas = get_load_val("DamageDatas", {})
	if damage_datas.has(damage_data_key):
		return damage_datas[damage_data_key].duplicate()
	return {}

func get_damage_data_for_subaction(actor:BaseActor, subaction_data:Dictionary)->Dictionary:
	var damage_key = subaction_data.get("DamageKey", "")
	if damage_key == null or damage_key == '':
		return {}
	if damage_key == "Weapon":
		if actor == null:
			printerr("BaseAction.get_damage_data_for_subaction: Null Actor when asking for Weapon damage.")
			return {}
		var weapon = actor.equipment.get_primary_weapon()
		if !weapon:
			printerr("BaseAction.get_damage_data_for_subaction: No Weapon when asking for Weapon damage.")
			return {}
		return (weapon as BaseWeaponEquipment).get_damage_data()
	return DamageDatas.get(damage_key, subaction_data.get("DamageData", {}))

func get_targeting_params(target_param_key, actor:BaseActor)->TargetParameters:
	if actor and target_param_key == "Weapon":
		var weapon = actor.equipment.get_primary_weapon()
		if !weapon:
			printerr("No Weapon")
			return null
		return (weapon as BaseWeaponEquipment).target_parmas
	if target_param_key == "Self":
		return TargetParameters.SelfTargetParams
	var params = _target_params.get(target_param_key, null)
	if !params:
		printerr("No Params")
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

func has_preview_target()->bool:
	var preview_data:Dictionary = get_load_val("Preview", {})
	var preview_key = preview_data.get("PreviewTargetKey", null)
	return preview_key and preview_key != ''

func get_preview_target_params(actor:BaseActor)->TargetParameters:
	var preview_data:Dictionary = get_load_val("Preview", {})
	var preview_key = preview_data.get("PreviewTargetKey", null)
	if not preview_key or preview_key == '':
		printerr("No preview key")
		return null
	return get_targeting_params(preview_key, actor)

func has_preview_damage()->bool:
	var preview_data:Dictionary = get_load_val("Preview", {})
	var preview_key = preview_data.get("PreviewDamageKey", null)
	return preview_key and preview_key != ''

func get_preview_damage_datas(actor:BaseActor=null)->Dictionary:
	var preview_data:Dictionary = get_load_val("Preview", {})
	var preview_key = preview_data.get("PreviewDamageKey", null)
	if not preview_key or preview_key == '':
		printerr("No preview key")
		return {}
	if preview_key == "Weapon" and actor:
		return actor.get_weapon_damage_datas()
	if preview_key == "Default" and actor:
		return actor.get_default_attack_damage_datas()
	var damage_datas = get_load_val("DamageDatas", {})
	var preview_damage = damage_datas.get(preview_key)
	if preview_damage: 
		return {"Preview": preview_damage}
	return {}


func has_ammo(actor:BaseActor=null):
	var ammo_data = get_load_val("AmmoData", null)
	if ammo_data and ammo_data.get("UseWeaponAmmo", false):
		if actor:
			var weapon = actor.equipment.get_primary_weapon()
			var weapon_ammo = weapon.get_ammo_data()
			if weapon_ammo.size() > 0:
				return true
			else:
				return false
		else:
			return false
	return ammo_data != null

func get_ammo_data(actor:BaseActor=null):
	var ammo_data = get_load_val("AmmoData", null)
	if ammo_data and ammo_data.get("UseWeaponAmmo", false):
		if actor:
			var weapon = actor.equipment.get_primary_weapon()
			if !weapon:
				return null
			var weapon_ammo = weapon.get_ammo_data()
			if weapon_ammo.size() > 0:
				weapon_ammo['AmmoKey'] = "Weapon"
				return weapon_ammo
		return null
	if ammo_data:
		ammo_data['AmmoKey'] = ActionKey
	return ammo_data
		

func get_on_que_options(actor:BaseActor, game_state:GameStateData):
	var out_list = []
	for sub_action_data in list_sub_action_datas():
		var sub_action = ActionLibrary.get_sub_action_script(sub_action_data['SubActionScript'])
		if !sub_action:
			printerr("BaseAction.get_on_que_options: Failed to find SubActionScript '%s'." % [sub_action_data['SubActionScript']])
			continue
		out_list.append_array(sub_action.get_on_que_options(self, sub_action_data, actor, game_state))
	return out_list

func get_effect_data(effect_data_key:String)->Dictionary:
	var effect_datas = get_load_val("EffectDatas", {})
	if effect_datas.has(effect_data_key):
		return effect_datas[effect_data_key].duplicate()
	return {}

func has_sustain_data()->bool:
	var sustain_data = get_load_val("SustainData", {})
	return sustain_data.size() > 0
	
func get_sustain_data()->Dictionary:
	var sustain_data = get_load_val("SustainData", {})
	return sustain_data

func get_zone_data(zone_data_key:String)->Dictionary:
	var zone_datas = get_load_val("ZoneDatas", {})
	if zone_datas.has(zone_data_key):
		return zone_datas[zone_data_key].duplicate()
	return {}

###################################
##		AI Info
###################################
func is_attack(actor:BaseActor)->bool:
	var damage_data = get_preview_damage_datas(actor)
	if has_preview_target() and damage_data.size() > 0:
		return true
	if get_load_val("AiInfo",{"IsAttack":false})['IsAttack']:
		return true
	return false

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
var MissileDatas:Dictionary:
		get: return get_load_val('MissileDatas', {})

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
	return get_small_page_icon(actor)

func  get_small_page_icon(actor:BaseActor = null)->Texture2D:
	if actor and self.get_load_val("UseWeaponIcons", false):
		var main_weapon:BaseWeaponEquipment = actor.equipment.get_primary_weapon()
		if main_weapon:
			return load(main_weapon.details.small_icon_path)
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

func get_damage_data(actor:BaseActor, subaction_data:Dictionary)->Dictionary:
	var damage_key = subaction_data.get("DamageKey", "")
	if damage_key == null or damage_key == '':
		return {}
	if damage_key == "Weapon":
		var weapon = actor.equipment.get_primary_weapon()
		if !weapon:
			printerr("No Weapon")
			return {}
		return (weapon as BaseWeaponEquipment).get_damage_data()
	return DamageDatas.get(damage_key, subaction_data.get("DamageData", null))

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


func has_ammo():
	return get_load_val("AmmoData", {}).size() > 0

func get_ammo_data():
	return get_load_val("AmmoData")

func get_on_que_options(actor:BaseActor, game_state:GameStateData):
	var out_list = []
	for sub_action_data in list_sub_action_datas():
		var sub_action:BaseSubAction = ActionLibrary.get_sub_action_script(sub_action_data['SubActionScript'])
		if !sub_action:
			printerr("BaseAction.get_on_que_options: Failed to find SubActionScript '%s'." % [sub_action_data['SubActionScript']])
			continue
		out_list.append_array(sub_action.get_on_que_options(self, sub_action_data, actor, game_state))
	return out_list
		

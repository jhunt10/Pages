class_name BaseAction
extends BaseLoadObject

#const TargetParameters = preload("res://assets/Scripts/Targeting/TargetParameters.gd")

const SUB_ACTIONS_PER_ACTION = 24

var ActionKey:String:
	get: return self._key

var details:ObjectDetailsData

var SubActionData:Array = []

var CostData:Dictionary:
		get: return get_load_val('CostData', {})
var DamageDatas:Dictionary:
		get: return get_load_val('DamageDatas', {})
var MissileDatas:Dictionary:
		get: return get_load_val('MissileDatas', {})

var OnQueUiState:String:
	get: return get_load_val("OnQueUiState")
var _target_params:Dictionary

func _init(key:String, def_load_path:String, def:Dictionary, id:String='', data:Dictionary={}) -> void:
	super(key, def_load_path, def, id, data)
	
	details = ObjectDetailsData.new(self._def_load_path, self._def.get("Details", {}))
	
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
		if preview_data.keys().has("PreviewTargetKey"):
			PreviewTargetKey = preview_data["PreviewTargetKey"]
		if preview_data.keys().has("PreviewMoveOffset"):
			var pre_move_arr = []
			if preview_data['PreviewMoveOffset'] is Array:
				pre_move_arr = def["PreviewMoveOffset"]
			if preview_data['PreviewMoveOffset'] is String:
				pre_move_arr = JSON.parse_string(preview_data['PreviewMoveOffset'])
			PreviewMoveOffset = MapPos.new(pre_move_arr[0],pre_move_arr[1],pre_move_arr[2],pre_move_arr[3])


func get_tagable_id(): return ActionKey
func get_tags(): return details.tags

var _loaded_from_file:String
var LoadPath:String:
	get: return _loaded_from_file.get_base_dir()
#var DisplayName:String
#var SnippetDesc:String
#var Description:String
#var Tags:Array = ActionData.get("Tags", [])

#var TargetParams:Dictionary = {}
#var SubActionData:Array = []
#var ActionData:Dictionary = {}

var PreviewTargetKey:String
var PreviewMoveOffset:MapPos

#func _init(file_load_path:String, def:Dictionary) -> void:
	#_loaded_from_file = file_load_path
	#ActionKey = def['ActionKey']
	#ActionData = def
	
	#TODO: Translations
	#var details = def.get("Details", def)
	#DisplayName = details['DisplayName']
	#SnippetDesc = details['SnippetDesc']
	#Description = details['Description']
	#Tags = details['Tags']
	
	#details = ObjectDetailsData.new(LoadPath, def.get("Details", {}))
	
func  get_small_page_icon()->Texture2D:
	return ActionLibrary.get_action_icon(details.small_icon_path)

func  get_large_page_icon()->Texture2D:
	return ActionLibrary.get_action_icon(details.large_icon_path)

func list_sub_action_datas()->Array:
	var out_list = []
	for frame_sub_actions in SubActionData:
		if frame_sub_actions and frame_sub_actions is Array:
			for data in frame_sub_actions:
				out_list.append(data)
	return out_list

func get_damage_data(subaction_data:Dictionary):
	return DamageDatas.get(subaction_data.get("DamageKey", ""), subaction_data.get("DamageData", null))

func get_targeting_params(target_param_key)->TargetParameters:
	return _target_params.get(target_param_key, null)
		
	

func get_on_que_options(actor:BaseActor, game_state:GameStateData):
	var out_list = []
	for sub_action_data in list_sub_action_datas():
		var sub_action:BaseSubAction = ActionLibrary.get_sub_action_script(sub_action_data['SubActionScript'])
		if !sub_action:
			printerr("BaseAction.get_on_que_options: Failed to find SubActionScript '%s'." % [sub_action_data['SubActionScript']])
			continue
		out_list.append_array(sub_action.get_on_que_options(self, sub_action_data, actor, game_state))
	return out_list
		

class_name BaseAction

#const TargetParameters = preload("res://assets/Scripts/Targeting/TargetParameters.gd")

const SUB_ACTIONS_PER_ACTION = 24

func get_tagable_id(): return ActionKey
func get_tags(): return Tags

var _loaded_from_file:String
var LoadPath:String:
	get: return _loaded_from_file.get_base_dir()
var ActionKey:String 
var DisplayName:String
var SnippetDesc:String
var Description:String
var Tags:Array = ActionData.get("Tags", [])

var TargetParams:Dictionary = {}
var SubActionData:Array = []
var ActionData:Dictionary = {}
var CostData:Dictionary:
		get: return ActionData.get('CostData', {})
var DamageDatas:Dictionary:
		get: return ActionData.get('DamageDatas', {})
var MissileDatas:Dictionary:
		get: return ActionData.get('MissileDatas', {})

var PreviewTargetKey:String
var PreviewMoveOffset:MapPos
var OnQueUiState:String

var SmallSprite:String 
var LargeSprite:String 

func _init(file_load_path:String, args:Dictionary) -> void:
	_loaded_from_file = file_load_path
	ActionKey = args['ActionKey']
	ActionData = args
	
	#TODO: Translations
	DisplayName = args['DisplayName']
	SnippetDesc = args['SnippetDesc']
	Description = args['Description']
	Tags = args['Tags']
	
	SmallSprite = args['SmallSprite']
	LargeSprite = args.get('LargeSprite', '')
	if args.keys().has("OnQueUiState"):
		OnQueUiState = args['OnQueUiState']
	
	# Load Targeting Parameters
	if args.has('TargetParams'):
		if args['TargetParams'] is Array:
			for tparm in args['TargetParams']:
				TargetParams[tparm['TargetKey']] = TargetParameters.new(tparm['TargetKey'], tparm)
		if args['TargetParams'] is Dictionary:
			for tparm_key in args['TargetParams'].keys():
				TargetParams[tparm_key] = TargetParameters.new(tparm_key, args['TargetParams'][tparm_key])
		
	# Load SubAction Data, missing indexes are left null
	# The ActionQueController will create the subaction on demand
	SubActionData = []	
	for index in range(SUB_ACTIONS_PER_ACTION):
		var subData = args.get('SubActions', {}).get(str(index), null)
		if not subData:
			SubActionData.append(null)
		elif subData is Dictionary:
			if subData.has('SubActionScript'):
				SubActionData.append([subData])
		elif subData is Array:
			SubActionData.append(subData)
		else:
			printerr("Uknown SubActionType: " + str(subData))
	
	if args.has("PreviewTargetKey"):
		PreviewTargetKey = args["PreviewTargetKey"]
	if args.has("PreviewMoveOffset"):
		var pre_move_arr = []
		if args['PreviewMoveOffset'] is Array:
			pre_move_arr = args["PreviewMoveOffset"]
		if args['PreviewMoveOffset'] is String:
			pre_move_arr = JSON.parse_string(args['PreviewMoveOffset'])
		PreviewMoveOffset = MapPos.new(pre_move_arr[0],pre_move_arr[1],pre_move_arr[2],pre_move_arr[3])

func  get_small_sprite()->Texture2D:
	var path = LoadPath.path_join(LargeSprite)
	return ActionLibrary.get_action_icon(path)

func  get_large_sprite()->Texture2D:
	var path = LoadPath.path_join(SmallSprite)
	return ActionLibrary.get_action_icon(path)

func list_sub_action_datas()->Array:
	var out_list = []
	for frame_sub_actions in SubActionData:
		if frame_sub_actions and frame_sub_actions is Array:
			for data in frame_sub_actions:
				out_list.append(data)
	return out_list

func get_damage_data(subaction_data:Dictionary):
	return DamageDatas.get(subaction_data.get("DamageKey", ""), subaction_data.get("DamageData", null))

func get_on_que_options(actor:BaseActor, game_state:GameStateData):
	var out_list = []
	for sub_action_data in list_sub_action_datas():
		var sub_action:BaseSubAction = ActionLibrary.get_sub_action_script(sub_action_data['SubActionScript'])
		if !sub_action:
			printerr("BaseAction.get_on_que_options: Failed to find SubActionScript '%s'." % [sub_action_data['SubActionScript']])
			continue
		out_list.append_array(sub_action.get_on_que_options(self, sub_action_data, actor, game_state))
	return out_list
		

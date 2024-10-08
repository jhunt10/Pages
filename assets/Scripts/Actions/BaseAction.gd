class_name BaseAction

#const TargetParameters = preload("res://assets/Scripts/Targeting/TargetParameters.gd")

const SUB_ACTIONS_PER_ACTION = 24

var _loaded_from_file:String
var LoadPath:String:
	get: return _loaded_from_file.get_base_dir()
var ActionKey:String 
var DisplayName:String
var SnippetDesc:String
var Description:String
var Tags:Array = []
var TargetParams:Dictionary = {}
var SubActionData:Array = []
var ActionData:Dictionary = {}
var CostData:Dictionary:
		get: return ActionData.get('CostData', {})
var DamageDatas:Dictionary:
		get: return ActionData.get('DamageDatas', {})

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
	LargeSprite = args['LargeSprite']
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
	return load(LoadPath + "/" +SmallSprite)
	
func  get_large_sprite()->Texture2D:
	return load(LoadPath + "/" +SmallSprite)
	
func get_damage_data(subaction_data:Dictionary):
	return DamageDatas.get(subaction_data.get("DamageKey", ""), subaction_data.get("DamageData", null))

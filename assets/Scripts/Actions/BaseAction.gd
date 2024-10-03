class_name BaseAction

#const TargetParameters = preload("res://assets/Scripts/Targeting/TargetParameters.gd")

const SUB_ACTIONS_PER_ACTION = 24

var LoadPath:String
var ActionKey:String 
var DisplayName:String
var SnippetDesc:String
var Description:String
var Tags:Array = []
var TargetParams:Dictionary = {}
var SubActionData:Array = []
var ActionData:Dictionary = {}

var PreviewTargetKey:String
var PreviewMoveOffset:MapPos
var OnQueUiState:String

var SmallSprite:String 
var LargeSprite:String 

func _init(load_path:String, args:Dictionary) -> void:
	LoadPath = load_path
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
		for tparm in args['TargetParams']:
			TargetParams[tparm['TargetKey']] = TargetParameters.new(tparm)
		
	# Load SubAction Data, missing indexes are left null
	# The ActionQueController will create the subaction on demand
	SubActionData = []	
	for index in range(SUB_ACTIONS_PER_ACTION):
		var subData:Dictionary = args['SubActions'].get(str(index), {})
		if subData.has('SubActionScript'):
			SubActionData.append(subData)
		else:
			SubActionData.append(null)
	
	if args.has("PreviewTargetKey"):
		PreviewTargetKey = args["PreviewTargetKey"]
	if args.has("PreviewMoveOffset"):
		var pre_move_arr = args["PreviewMoveOffset"]
		PreviewMoveOffset = MapPos.new(pre_move_arr[0],pre_move_arr[1],pre_move_arr[2],pre_move_arr[3])
			
func  get_small_sprite()->Texture2D:
	return load(LoadPath + "/" +SmallSprite)
	
func  get_large_sprite()->Texture2D:
	return load(LoadPath + "/" +SmallSprite)
	

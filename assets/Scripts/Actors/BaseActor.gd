class_name BaseActor

# Actor holds no references to the current map state so this method is called by MapState.set_actor_pos()
signal on_move(old_pos:MapPos, new_pos:MapPos, move_type:String, moved_by:BaseActor)

var Que:ActionQue
var node:ActorNode
var stats:StatHolder
var effects:EffectHolder
var items:ItemHolder

var Id : String = str(ResourceUID.create_id())
var FactionIndex : int
var LoadPath:String
var ActorData:Dictionary
var ActorKey:String 
var DisplayName:String
var SnippetDesc:String
var Description:String
var Tags:Array = []

var _default_sprite:String
var _allow_auto_que:bool = false

var is_dead:bool = false

func _init(args:Dictionary, faction_index:int) -> void:
	LoadPath = args['LoadPath']
	ActorKey = args['ActorKey']
	ActorData = args
	FactionIndex = faction_index
	
	#TODO: Translations
	DisplayName = args['DisplayName']
	SnippetDesc = args['SnippetDesc']
	Description = args['Description']
	Tags = args['Tags']
	
	_default_sprite = args['Sprite']
	_allow_auto_que = args.get('AutoQueing', false)
	
	Que = ActionQue.new(self)
	
	var stat_data = args["Stats"]
	stats = StatHolder.new(self, stat_data)
	effects = EffectHolder.new(self)
	items = ItemHolder.new(self)
	
func on_death():
	is_dead = true
	node.sprite.texture = get_coprse_texture()
	
func  get_default_sprite()->Texture2D:
	return load(LoadPath + "/" +_default_sprite)
	
func get_portrait_sprite()->Texture2D:
	return load(LoadPath + "/" +_default_sprite)

func get_coprse_texture()->Texture2D:
	if ActorData.has("CorpseSprite"):
		return load(LoadPath + "/" +ActorData['CorpseSprite'])
	return MainRootNode.actor_libary.get_default_corpse_texture()

func auto_build_que(current_turn:int):
	if !_allow_auto_que:
		return
	print("Auto Que for : " + ActorKey)
	if Que:
		if Que.available_action_list.size() > 0:
			var action = MainRootNode.action_libary.get_action(Que.available_action_list[0])
			for n in range(Que.que_size):
				print("AutoQue: " + action.ActionKey)
				Que.que_action(action)
			

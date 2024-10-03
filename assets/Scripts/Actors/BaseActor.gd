class_name BaseActor

# Actor holds no references to the current map state so this method is called by MapState.set_actor_pos()
signal on_move(old_pos:MapPos, new_pos:MapPos, move_type:String, moved_by:BaseActor)

var Que:ActionQue
var node:ActorNode
var stats:StatHolder
var effects:EffectHolder
var items:ItemHolder

var Id : String = str(ResourceUID.create_id())
var LoadPath:String
var ActorData:Dictionary
var ActorKey:String 
var DisplayName:String
var SnippetDesc:String
var Description:String
var Tags:Array = []

var _default_sprite:String

func _init(args:Dictionary) -> void:
	LoadPath = args['LoadPath']
	ActorKey = args['ActorKey']
	ActorData = args
	
	#TODO: Translations
	DisplayName = args['DisplayName']
	SnippetDesc = args['SnippetDesc']
	Description = args['Description']
	Tags = args['Tags']
	
	_default_sprite = args['Sprite']
	
	Que = ActionQue.new(self)
	
	var stat_data = args["Stats"]
	stats = StatHolder.new(self, stat_data)
	effects = EffectHolder.new(self)
	items = ItemHolder.new(self)
	
func on_death():
	node.sprite.texture = get_coprse_texture()
	
func  get_default_sprite()->Texture2D:
	return load(LoadPath + "/" +_default_sprite)

func get_coprse_texture()->Texture2D:
	if ActorData.has("CorpseSprite"):
		return load(LoadPath + "/" +ActorData['CorpseSprite'])
	return MainRootNode.actor_libary.get_default_corpse_texture()

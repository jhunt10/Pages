class_name BaseItem

var Id : String = str(ResourceUID.create_id())
var LoadPath:String
var ItemData:Dictionary
var ItemKey:String 
var DisplayName:String
var SnippetDesc:String
var Description:String
var Tags:Array = []

func _init(args:Dictionary) -> void:
	LoadPath = args['LoadPath']
	ItemKey = args['ItemKey']
	ItemData = args
	#TODO: Translations
	DisplayName = args['DisplayName']
	SnippetDesc = args['SnippetDesc']
	Description = args['Description']
	Tags = args['Tags']

func use_on_actor(actor:BaseActor):
	var effect_key = ItemData['EffectKey']
	var effect_data = {}
	if ItemData.has('EffectData'):
		effect_data = ItemData['EffectData']
	actor.effects.add_effect(effect_key, effect_data)

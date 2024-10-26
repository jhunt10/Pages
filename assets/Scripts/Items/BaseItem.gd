class_name BaseItem

enum ItemTypes {KeyItem, Consumable, Equipment, Material, }

var Id : String = str(ResourceUID.create_id())


var ItemKey:String 
var ItemDef:Dictionary

var _load_path:String
var details:ObjectDetailsData

var item_type:ItemTypes
var can_stack:bool

func _init(load_path:String, def:Dictionary, data:Dictionary={}) -> void:
	ItemKey = def['ItemKey']
	ItemDef = def.duplicate()
	
	_load_path = load_path
	details = ObjectDetailsData.new(load_path, ItemDef.get("Details", {}))
	can_stack = ItemDef.get("CanStack", false)
	
	var item_type_str = ItemDef.get("ItemType", "")
	if item_type_str and ItemTypes.keys().has(item_type_str):
		item_type = ItemTypes.get(item_type_str)
	else:
		printerr("BaseItem._init: %s has unknown ItemType '%s'." % [ItemKey, item_type_str])

func get_large_icon()->Texture2D:
	return SpriteCache.get_sprite(details.large_icon_path)
func get_small_icon()->Texture2D:
	return SpriteCache.get_sprite(details.large_icon_path)

#func use_on_actor(actor:BaseActor):
	#var effect_key = ItemData['EffectKey']
	#var effect_data = {}
	#if ItemData.has('EffectData'):
		#effect_data = ItemData['EffectData']
	#actor.effects.add_effect(effect_key, effect_data)

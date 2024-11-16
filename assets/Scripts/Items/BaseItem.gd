class_name BaseItem
extends BaseLoadObject

enum ItemTypes {KeyItem, Consumable, Equipment, Material, }

var Id:String: 
	get: return self._id
var ItemKey:String:
	get: return self._key

var details:ObjectDetailsData
var can_stack:bool

func _init(key:String, def_load_path:String, def:Dictionary, id:String='', data:Dictionary={}) -> void:
	super(key, def_load_path, def, id, data)
	
	details = ObjectDetailsData.new(self._def_load_path, self._def.get("Details", {}))
	can_stack = self._def.get("CanStack", false)

func get_item_type()->ItemTypes:
	var item_type_str = self._def.get("ItemType", "")
	if item_type_str and ItemTypes.keys().has(item_type_str):
		return ItemTypes.get(item_type_str)
	else:
		printerr("BaseItem.get_item_type: %s has unknown ItemType '%s'." % [ItemKey, item_type_str])
	return ItemTypes.KeyItem

func get_item_tags()->Array:
	return details.tags

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

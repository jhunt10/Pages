class_name BaseItem
extends BaseLoadObject

enum ItemTypes {KeyItem, Consumable, Equipment, Material, }

var Id:String: 
	get: return self._id
var ItemKey:String:
	get: return self._key

var details:ObjectDetailsData
var can_stack:bool:
	get:
		return get_load_val("CanStack", false)

## A semi-typed path for the inventory currently holding this item 
## Examples: "PlayerInventory", "Actor:TestActor_ID"
var inventory_path:String:
	get:
		return get_load_val("InventoryPath", "")

func _init(key:String, def_load_path:String, def:Dictionary, id:String='', data:Dictionary={}) -> void:
	super(key, def_load_path, def, id, data)
	
	details = ObjectDetailsData.new(self._def_load_path, self._def.get("Details", {}))

func get_item_type()->ItemTypes:
	var item_type_str = self._def.get("ItemType", "")
	if item_type_str and ItemTypes.keys().has(item_type_str):
		return ItemTypes.get(item_type_str)
	else:
		printerr("BaseItem.get_item_type: %s has unknown ItemType '%s'." % [ItemKey, item_type_str])
	return ItemTypes.KeyItem

func get_item_tags()->Array:
	return details.tags.duplicate()

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

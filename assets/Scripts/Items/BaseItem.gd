class_name BaseItem
extends BaseLoadObject

enum ItemTypes {KeyItem, Page, Consumable, Ammo, Equipment, Material}
enum ItemRarity {Mundane, Common, Rare, Legendary, Unique}

var Id:String: 
	get: return self._id
var ItemKey:String:
	get: return self._key

var can_stack:bool:
	get:
		return get_load_val("CanStack", false)

## A semi-typed path for the inventory currently holding this item 
## Examples: "PlayerInventory", "Actor:TestActor_ID"
var inventory_path:String:
	get:
		return get_load_val("InventoryPath", "")

var item_details:Dictionary

func _init(key:String, def_load_path:String, def:Dictionary, id:String='', data:Dictionary={}) -> void:
	super(key, def_load_path, def, id, data)
	item_details = get_load_val("ItemDetails", {})

func save_me()->bool:
	return true

func get_item_type()->ItemTypes:
	var item_type_str = item_details.get("ItemType", null)
	if item_type_str and ItemTypes.keys().has(item_type_str):
		return ItemTypes.get(item_type_str)
	else:
		printerr("BaseItem.get_item_type: %s has unknown ItemType '%s'." % [ItemKey, item_type_str])
	return ItemTypes.KeyItem

func get_item_rarity()->ItemRarity:
	var type_str = item_details.get("Rarity", null)
	if type_str and ItemRarity.keys().has(type_str):
		return ItemRarity.get(type_str)
	else:
		printerr("BaseItem.get_item_rarity: %s has unknown ItemRarity '%s'." % [ItemKey, type_str])
	return ItemRarity.Mundane

func get_item_tags()->Array:
	return details.tags.duplicate()

func get_large_icon()->Texture2D:
	return SpriteCache.get_sprite(details.large_icon_path)
func get_small_icon()->Texture2D:
	return SpriteCache.get_sprite(details.small_icon_path)

func get_rarity_background()->Texture2D:
	return ItemHelper.get_rarity_background(self.get_item_rarity())
#func use_on_actor(actor:BaseActor):
	#var effect_key = ItemData['EffectKey']
	#var effect_data = {}
	#if ItemData.has('EffectData'):
		#effect_data = ItemData['EffectData']
	#actor.effects.add_effect(effect_key, effect_data)

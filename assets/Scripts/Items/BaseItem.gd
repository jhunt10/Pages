class_name BaseItem
extends BaseLoadObject

enum ItemTypes {KeyItem, Page, Consumable, Ammo, Equipment, Weapon, Money}
enum ItemRarity {Mundane, Common, Rare, Legendary, Unique}

var Id:String: 
	get: return self._id
var ItemKey:String:
	get: return self._key

#var can_stack:bool:
	#get:
		#return true #get_load_val("CanStack", false)

## A semi-typed path for the inventory currently holding this item 
## Examples: "PlayerInventory", "Actor:TestActor_ID"
var inventory_path:String:
	get:
		return get_load_val("InventoryPath", "")

var item_data:Dictionary:
	get:
		return _def.get("ItemData", {})

func _init(key:String, def_load_path:String, def:Dictionary, id:String='', data:Dictionary={}) -> void:
	super(key, def_load_path, def, id, data)

func save_me()->bool:
	return true

func get_item_type()->ItemTypes:
	var item_type_str = item_data.get("ItemType", null)
	if item_type_str and ItemTypes.keys().has(item_type_str):
		return ItemTypes.get(item_type_str)
	else:
		printerr("BaseItem.get_item_type: %s has unknown ItemType '%s'." % [ItemKey, item_type_str])
	return ItemTypes.KeyItem

func get_item_rarity()->ItemRarity:
	var type_str = item_data.get("Rarity", null)
	if type_str and ItemRarity.keys().has(type_str):
		return ItemRarity.get(type_str)
	else:
		printerr("BaseItem.get_item_rarity: %s has unknown ItemRarity '%s'." % [ItemKey, type_str])
	return ItemRarity.Mundane

func get_item_value()->int:
	return item_data.get("Value", 0)

func get_item_tags()->Array:
	return get_tags()

func get_rarity_background()->Texture2D:
	return ItemHelper.get_rarity_background(self.get_item_rarity())

## Returns a diction of failed requirements, mapped by requirment type 
func get_cant_use_reasons(actor:BaseActor):
	var missing_requirements = {}
	
	return missing_requirements

func get_passive_stat_mods()->Array:
	return []
	#var stat_mod_datas:Dictionary = get_load_val("StatMods", {})
	#var out_list = []
	#for mod_data in stat_mod_datas.values():
		#if not mod_data.has("DisplayName"):
			#mod_data['DisplayName'] = self.get_display_name()
		#out_list.append(BaseStatMod.create_from_data(Id, mod_data))
	#return out_list

func get_target_mods()->Array:
	return []
	#var stat_mod_datas:Dictionary = get_load_val("TargetMods", {})
	#var out_list = []
	#for mod_data in stat_mod_datas.values():
		#out_list.append(mod_data.duplicate())
	#return out_list

func get_damage_mods()->Dictionary:
	return {}
	#var mod_datas:Dictionary = get_load_val("DamageMods", {})
	#var out_dict = {}
	#for mod_key in mod_datas.keys():
		#var mod_data = mod_datas[mod_key]
		#if mod_data.has("DamageModKey"):
			#mod_key = mod_data['DamageModKey']
		#else:
			#mod_data['DamageModKey'] = mod_key
		#if not mod_data.has("DisplayName"):
			#mod_data['DisplayName'] = self.get_display_name()
		#
		#out_dict[mod_key] = mod_data
	#return out_dict

func get_ammo_mods()->Dictionary:
	return {}
	#var mod_datas:Dictionary = get_load_val("AmmoMods", {})
	#var out_dict = {}
	#for mod_key in mod_datas.keys():
		#var mod_data = mod_datas[mod_key]
		#if mod_data.has("AmmoModKey"):
			#mod_key = mod_data['AmmoModKey']
		#else:
			#mod_data['AmmoModKey'] = mod_key
		#if not mod_data.has("DisplayName"):
			#mod_data['DisplayName'] = self.get_display_name()
		#
		#out_dict[mod_key] = mod_data
	#return out_dict

func get_attack_mods()->Dictionary:
	return {}
	#var mod_datas:Dictionary = get_load_val("AttackMods", {})
	#var out_dict = {}
	#for mod_key in mod_datas.keys():
		#var mod_data = mod_datas[mod_key]
		#if mod_data.has("AttackModKey"):
			#mod_key = mod_data['AttackModKey']
		#else:
			#mod_data['AttackModKey'] = mod_key
		#if not mod_data.has("DisplayName"):
			#mod_data['DisplayName'] = self.get_display_name()
		#
		#out_dict[mod_key] = mod_data
	#return out_dict

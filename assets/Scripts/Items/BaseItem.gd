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


func get_item_type_string()->String:
	var val  = get_item_type()
	if val >= 0:
		return ItemTypes.keys()[val]
	return ""

func get_item_rarity()->ItemRarity:
	var type_str = item_data.get("Rarity", null)
	if type_str and ItemRarity.keys().has(type_str):
		return ItemRarity.get(type_str)
	else:
		printerr("BaseItem.get_item_rarity: %s has unknown ItemRarity '%s'." % [ItemKey, type_str])
	return ItemRarity.Mundane

func get_item_value()->int:
	return item_data.get("Value", 0)


func get_rarity_string()->String:
	var rarity = get_item_rarity()
	if rarity >= 0:
		return ItemRarity.keys()[rarity]
	return ""

func get_rarity_background()->Texture2D:
	return ItemHelper.get_rarity_background(self.get_item_rarity())

## Returns a diction of failed requirements, mapped by requirment type 
func get_cant_use_reasons(actor:BaseActor)->Dictionary:
	var missing_requirements = {}
	
	var requirments = get_data_containing_mods().get("Requirments", {})
	var required_stats = requirments.get("ReqStats", {})
	var missing_stats = {}
	for stat_name in required_stats.keys():
		var req_val = required_stats[stat_name]
		var stat_val = actor.stats.get_stat(stat_name)
		if req_val > stat_val:
			missing_stats[stat_name] = req_val
	if missing_stats.size() > 0:
		missing_requirements["Stats"] = missing_stats
	
	
	return missing_requirements

## Returns what sub data has Mods
func get_data_containing_mods()->Dictionary:
	return item_data

func has_spite_sheet()->bool:
	return false

func _get__mods(mod_prop_name:String)->Dictionary:
	var sub_data = get_data_containing_mods()
	var mod_datas:Dictionary = sub_data.get(mod_prop_name, {})
	var out_dict = {}
	var key_prop_name = mod_prop_name + "Key"
	if mod_prop_name.ends_with("Mods"):
		key_prop_name = mod_prop_name.trim_suffix("s") + "Key"
	
	for mod_key in mod_datas.keys():
		var mod_data = mod_datas[mod_key]
		if mod_data.has("Key"):
			mod_key = mod_data['Key']
			mod_data.erase("Key")
			mod_data[mod_prop_name] = mod_key
		elif mod_data.has(key_prop_name):
			mod_key = mod_data[key_prop_name]
		else:
			mod_data[key_prop_name] = mod_key
		if not mod_data.has("DisplayName"):
			mod_data['DisplayName'] = self.get_display_name()
		mod_data['SourceItemId'] = self.Id
		
		out_dict[mod_key] = mod_data
	return out_dict

func get_passive_stat_mods()->Array:
	var sub_data = get_data_containing_mods()
	var stat_mod_datas:Dictionary = sub_data.get("StatMods", {})
	var out_list = []
	for mod_data in stat_mod_datas.values():
		if not mod_data.has("DisplayName"):
			mod_data['DisplayName'] = self.get_display_name()
			mod_data['SourceItemId'] = self.Id
		out_list.append(BaseStatMod.create_from_data(Id, mod_data))
	return out_list

func get_stat_mod_datas()->Dictionary:
	return _get__mods("StatMods")

func get_item_slots_mods()->Dictionary:
	return _get__mods("ItemSlotsMods")

func get_target_mods()->Array:
	return _get__mods("TargetMods").values()

func get_ammo_mods()->Dictionary:
	return _get__mods("AmmoMods")
	
func get_attack_mods()->Dictionary:
	return _get__mods("AttackMods")
	
func get_damage_mods()->Dictionary:
	return _get__mods("DamageMods")
	
func get_weapon_mods()->Dictionary:
	return _get__mods("WeaponMods")

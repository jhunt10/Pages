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

var item_details:Dictionary:
	get:
		return _def.get("ItemDetails", {})

func _init(key:String, def_load_path:String, def:Dictionary, id:String='', data:Dictionary={}) -> void:
	super(key, def_load_path, def, id, data)

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

func get_item_value()->int:
	return item_details.get("Value", 0)

func get_item_tags()->Array:
	return details.tags.duplicate()

func get_large_icon()->Texture2D:
	return SpriteCache.get_sprite(details.large_icon_path)
func get_small_icon()->Texture2D:
	return SpriteCache.get_sprite(details.small_icon_path)

func get_rarity_background()->Texture2D:
	return ItemHelper.get_rarity_background(self.get_item_rarity())

## Returns a diction of failed requirements, mapped by requirment type 
func get_cant_use_reasons(actor:BaseActor):
	var requirment_data = get_load_val("Requirments", {})
	var missing_requirements = {}
	
	#for tag in requirment_data.get("ReqTags", []):
		#if not actor.get_tags().has(tag):
			#if not missing_requirements.has("Tags"):
				#missing_requirements['Tags'] = []
			#missing_requirements['Tags'].append(tag)
	#
	var req_stat_data = requirment_data.get("ReqStats", {})
	for stat_name in req_stat_data.keys():
		var req_val = req_stat_data[stat_name]
		var stat_val = actor.stats.get_stat(stat_name)
		if stat_val < req_val:
			if not missing_requirements.has("Stats"):
				missing_requirements['Stats'] = {}
			missing_requirements['Stats'][stat_name] = req_val
	
	var req_equipment_data = requirment_data.get("ReqEquip", {})
	for weapon_filter in req_equipment_data.get("WeaponFilters", []):
		var weapons = actor.equipment.get_filtered_weapons(weapon_filter)
		if weapons.size() == 0:
			if not missing_requirements.has("Equipment"):
				missing_requirements['Equipment'] = []
			var weapon_slots = weapon_filter.get("IncludeSlots", [])
			if weapon_slots.size() == 1:
				missing_requirements['Equipment'].append(weapon_slots[0] + " Weapon")
			else:
				missing_requirements['Equipment'].append("Weapon")
	for slot_name in req_equipment_data.get("SlotToTag", {}).keys():
		var req_tag = req_equipment_data[slot_name]
		var equipt_items = actor.equipment.get_equipt_items_of_slot_type(slot_name)
		if req_tag == "Any" and equipt_items.size() > 0:
			continue
		var has_tag = false
		for equipt_item:BaseEquipmentItem in equipt_items:
			if equipt_item.get_item_tags().has(req_tag):
				has_tag = true
				break
		if not has_tag:
			if not missing_requirements.has("Equipment"):
				missing_requirements['Equipment'] = []
			if req_tag == "Any":
				missing_requirements['Equipment'].append(slot_name)
			else:
				missing_requirements['Equipment'].append(req_tag)
	return missing_requirements
	return {}

func get_passive_stat_mods()->Array:
	var stat_mod_datas:Dictionary = get_load_val("StatMods", {})
	var out_list = []
	for mod_data in stat_mod_datas.values():
		if not mod_data.has("DisplayName"):
			mod_data['DisplayName'] = self.details.display_name
		out_list.append(BaseStatMod.create_from_data(Id, mod_data))
	return out_list

func get_target_mods()->Array:
	var stat_mod_datas:Dictionary = get_load_val("TargetMods", {})
	var out_list = []
	for mod_data in stat_mod_datas.values():
		out_list.append(mod_data.duplicate())
	return out_list

func get_damage_mods()->Dictionary:
	var mod_datas:Dictionary = get_load_val("DamageMods", {})
	var out_dict = {}
	for mod_key in mod_datas.keys():
		var mod_data = mod_datas[mod_key]
		if mod_data.has("DamageModKey"):
			mod_key = mod_data['DamageModKey']
		else:
			mod_data['DamageModKey'] = mod_key
		if not mod_data.has("DisplayName"):
			mod_data['DisplayName'] = self.details.display_name
		
		out_dict[mod_key] = mod_data
	return out_dict

func get_attack_mods()->Dictionary:
	var mod_datas:Dictionary = get_load_val("AttackMods", {})
	var out_dict = {}
	for mod_key in mod_datas.keys():
		var mod_data = mod_datas[mod_key]
		if mod_data.has("AttackModKey"):
			mod_key = mod_data['AttackModKey']
		else:
			mod_data['AttackModKey'] = mod_key
		if not mod_data.has("DisplayName"):
			mod_data['DisplayName'] = self.details.display_name
		
		out_dict[mod_key] = mod_data
	return out_dict

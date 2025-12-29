class_name BaseActor
extends BaseLoadObject

# These signals are emited by ActionQueController
## Emitted only when this Actor starts a turn (not emitted on gap turns)
signal turn_starting
## Emitted only when this Actor ends a turn (not emitted on gap turns)
signal turn_ended
# This is just here because I don't want all the Holders to have to connect dirrectly to ActionQueController
signal round_starting
signal round_ended
signal action_failed

signal stats_changed
signal equipment_changed
signal page_list_changed
signal bag_items_changed
signal effacts_changed
signal health_changed

# Actor holds no references to the current map state so this method is called by set_actor_pos()
signal on_move(old_pos:MapPos, new_pos:MapPos, move_data:Dictionary)
signal on_move_failed(cur_pos:MapPos)
signal on_death()
signal on_revive()
signal sprite_changed()

var Que:ActionQue
#var node:BaseActorNode
var sprite:ActorSpriteHolder
var stats:StatHolder
var effects:EffectHolder
var items:SupplyHolder
var equipment:EquipmentHolder
var pages:PageHolder
var aggro:AggroHandler

var Id : String:
	get: return _id
var ActorKey : String:
	get: return _key
func get_tagable_id(): return Id

var actor_data:Dictionary:
	get:
		return get_load_val("ActorData", {})

var FactionIndex : int
var enemy_npc_index:int = -1

var spawn_map_layer

var use_ai:bool: 
	get: return ai_def.size() > 0
var ai_def:Dictionary = {}

var is_player:bool:
	get:
		return StoryState._party_actor_ids.has(self.Id)
var is_dead:bool = false

func _init(key:String, load_path:String, def:Dictionary, id:String, data:Dictionary) -> void:
	super(key, load_path, def, id, data)
	spawn_map_layer = _def.get('SpawnOnMapLayer', 0)
	
	var stat_data = _def["Stats"]
	ai_def = get_load_val("AiData", {})
	aggro = AggroHandler.new(self)
	sprite = ActorSpriteHolder.new(self)
	stats = StatHolder.new(self, stat_data)
	stats.held_stats_changed.connect(_on_stat_change)
	stats.health_changed.connect(_on_health_change)
	effects = EffectHolder.new(self)
	#details = ObjectDetailsData.new(_def_load_path, _def.get("#ObjDetails", {}))
	equipment = EquipmentHolder.new(self)
	items = SupplyHolder.new(self)
	pages = PageHolder.new(self)
	
	# Que requires info from Pages and Equipment so must be inited after item validation
	Que = ActionQue.new(self)
	if get_load_val("IsPlayer", false):
		is_player = true
	_cache_after_loading_def()

func reload_def(load_path:String, def:Dictionary):
	super(load_path, def)
	_cache_after_loading_def()

func _cache_after_loading_def():
	stats.dirty_stats()

var alphabet = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z']

func get_npc_index_str()->String:
	if enemy_npc_index >= 0:
		return alphabet[enemy_npc_index]
	else:
		return ""

func get_display_name()->String:
	var dis_name = super()
	if pages:
		var title_page:BasePageItem = pages.get_item_in_slot(0)
		if title_page:
			dis_name = title_page.get_display_name()
	if enemy_npc_index >= 0:
		dis_name += " " + alphabet[enemy_npc_index]
		
	return dis_name

func get_title()->String:
	if pages:
		var title_page = pages.get_title_page()
		if title_page:
			return title_page.get_title_key()
	return get_display_name()

func get_tags()->Array: 
	var tag_list = []
	tag_list.append_array(super())
	var aditional_tags = pages.get_tags_added_to_actor()
	aditional_tags.append_array(effects.get_tags_added_to_actor())
	aditional_tags.append_array(equipment.get_tags_added_to_actor())
	for added_tag in aditional_tags:
		if not tag_list.has(added_tag):
			tag_list.append(added_tag)
	return tag_list

func get_stat_scaling()->Dictionary:
	return actor_data.get("StatScaling", 
	{
		"STR": 0.25,
		"AGI": 0.25,
		"INT": 0.25,
		"WIS": 0.25,
	})


func _on_stat_change():
	stats_changed.emit()

func _on_health_change():
	health_changed.emit()

###################################
#######   Item Management   #######
###################################
var suppress_equipment_changed:bool = false

func on_held_items_change(item_holder_name:String, change_data:Dictionary):
	print("ItemChange: %s %s %s" % [self._id, item_holder_name, change_data])
	var holder:BaseItemHolder = null
	if item_holder_name == equipment.get_holder_name():
		holder = equipment
	elif item_holder_name == pages.get_holder_name():
		holder = pages
	elif item_holder_name == items.get_holder_name():
		holder = items
	else:
		printerr("Actor.on_held_items_change: Unknown Holder Name '%s'." % [item_holder_name])
	
	var added_item_ids = change_data.get("AddedItemIds", [])
	var removed_item_ids = change_data.get("RemovedItemIds", [])
	
	var rebuild_sprite = false
	var recache_stats = false
	var rebuild_slots = false
	var rechache_action_mods = false
	
	# Check all Removed Items
	for removed_item_id in removed_item_ids:
		# Check if item was involved in sprite
		if sprite.has_item_cached_in_sprite(removed_item_id):
			rebuild_sprite = true
		# Check if item was modding slots
		if pages._slot_mod_source_item_ids.has(removed_item_id):
			rebuild_slots = true
		if equipment._slot_mod_source_item_ids.has(removed_item_id):
			rebuild_slots = true
		if items._slot_mod_source_item_ids.has(removed_item_id):
			rebuild_slots = true
		# Check for Action Mods
		if pages.cached_action_mod_source_ids.has(removed_item_id):
			rechache_action_mods = true
			
	
	# Chack all Added Items
	for add_item_id in added_item_ids:
		var item:BaseItem = ItemLibrary.get_item(add_item_id)
		# Check if item will change sprite
		if item.has_spite_sheet():
			rebuild_sprite = true
		# Check if tiem will change slots
		if (item.get_item_slots_mods().size() > 0
			or item.get_taxonomy().has("PageBook")
			or item.get_taxonomy().has("Bag")):
			rebuild_slots = true
		if item.get_attack_mods().size() > 0:
			rechache_action_mods = true
	
	Que.rechache_page_ammo()
	
	# Rebuild Item Holder Slots
	if rebuild_slots:
		pages._build_slots_list()
		equipment._build_slots_list()
		items._build_slots_list()
	validate_itemholders()
	
	stats.recache_stats(false)
	
	if rechache_action_mods:
		pages._cache_action_mods()
	
	if holder == pages:
		page_list_changed.emit()
	
	if rebuild_sprite:
		sprite._build_sprite_sheet()
	

func validate_itemholders():
	pages.validate_items()
	equipment.validate_items()
	items.validate_items()
	
	for invalid_item:BaseItem in pages.list_invalid_items():
		if invalid_item.get_item_slots_mods().size() > 0:
			printerr("We have a problem.")
	Que.dirty_ammo_mods()

## Called by ItemHolders when they build slot sets.
## On first pass, we give all items benifit of doubt 
var _validate_items_for_slot_mods:bool = true
func get_item_slot_mods_for_holder(holder_name:String)->Dictionary:
	var out_dict = { "Equipment": {}, "Pages":{}, "Supplies":{} }
	# Get all held items including invalid ones
	var item_list = []
	item_list.append_array(pages.list_items(true))
	item_list.append_array(equipment.list_items(true))
	item_list.append_array(items.list_items(true))
	for item:BaseItem in item_list:
		var added_slots = item.get_item_slots_mods()
		# Item doesn't mod slots
		if added_slots.size() == 0:
			continue
		if _validate_items_for_slot_mods:
			var cant_use_reason = item.get_cant_use_reasons(self)
			if cant_use_reason.size() > 0:
				continue
		for key:String in added_slots.keys():
			var slot_set_data = added_slots[key]
			var modded_holder = slot_set_data.get("ItemHolder")
			if not out_dict.keys().has(modded_holder):
				printerr("Unknown ItemHolder '%s' on ItemSlotMod '%s'." % [modded_holder, key])
				continue
			out_dict[modded_holder][key] = slot_set_data
	return out_dict.get(holder_name, {})

func save_me()->bool:
	return self.is_player

func save_data()->Dictionary:
	var data = super()
	data['Pages'] = pages.build_save_data()
	data['BagItems'] = items.build_save_data()
	data['Equipment'] = equipment.build_save_data()
	data['Stats'] = stats.build_save_data()
	return data

func load_data(loading_data:Dictionary):
	_data = loading_data
	var stat_data = loading_data.get('Stats', {})
	stats.load_data(stat_data)
	
	var equipment_data = loading_data['Equipment']
	loading_data.erase('Equipment')
	equipment.load_save_data(equipment_data)
	
	var page_data = loading_data['Pages']
	loading_data.erase('Pages')
	pages.load_save_data(page_data)
	
	var bag_data = loading_data['BagItems']
	loading_data.erase('BagItems')
	items.load_save_data(bag_data)
	
	_validate_items_for_slot_mods = false
	pages._build_slots_list()
	equipment._build_slots_list()
	items._build_slots_list()
	_validate_items_for_slot_mods = true
	
	validate_itemholders()
	pages._cache_action_mods()
	stats.recache_stats(false)

func build_spawned_with_items():
	equipment._build_slots_list()
	var equipment_list = get_load_val("SpawnEquipmentArr", [])
	_build_spawn_items(equipment_list, equipment)
	
	pages._build_slots_list()
	items._build_slots_list()
	var page_list = get_load_val("SpawnPageArr", [])
	_build_spawn_items(page_list, pages)
	var item_list = get_load_val("SpawnItemArr", [])
	_build_spawn_items(item_list, items)
	
	validate_itemholders()
	
	pages._cache_action_mods()
	stats.recache_stats(false)
	

func _build_spawn_items(item_list:Array, holder:BaseItemHolder):
	for item_key in item_list:
		if item_key == '':
			continue
		var item = ItemLibrary.create_item(item_key, {}, "")
		if not item:
			printerr("Actor.build_spawned_with_items: Failed to create item with key '%s'." % [item_key])
			continue
		var slot = holder.get_first_valid_slot_for_item(item, false)
		if slot >= 0:
			holder._direct_set_item_in_slot(slot, item)
			print("Spawned Item '%s' into slot %s." % [item.Id, slot])

func clean_state():
	self.is_dead = false
	Que.fill_page_ammo()
	stats.prep_for_combat()

func on_combat_start():
	clean_state()
	effects.on_combat_start()

func on_delete():
	if is_deleted:
		return
	pages._delete_all_items()
	items._delete_all_items()
	equipment._delete_all_items()
	super()

func leaves_corpse()->bool:
	return is_player

func die():
	if is_dead:
		return
	is_dead = true
	var map_pos = CombatRootControl.Instance.GameState.get_actor_pos(self)
	if map_pos:
		# Roll for item drop
		var drop_items = actor_data.get("DropItemsSet", {})
		var item_key = Roll.from_set(drop_items)
		if item_key != "":
			if item_key.begins_with("Money"):
				var tokens = item_key.split(':')
				item_key = "MoneyItem"
				var item = ItemHelper.spawn_item(item_key, {}, map_pos)
				item.item_data['Value'] = int(tokens[1])
			else:
				ItemHelper.spawn_item(item_key, {}, map_pos)
	on_death.emit()

func revive():
	is_dead = false
	on_revive.emit()

func can_act()->bool:
	if stats.get_stat('Frozen', -1) > 0:
		return false
	return true

func get_action_key_list()->Array:
	var list = pages.list_action_keys()
	if list.size() > 0:
		return list
	return get_load_val("AiData", {}).get("ActionsArr", [])


func get_effect_immunity()->Array:
	var immunities = actor_data.get("ImmuneToEffects", [])
	immunities.append_array(effects.get_effect_immunities())
	return immunities

func is_adirectional()->bool:
	return actor_data.get("IsAdirectional", false)


########################
##      Weapons       ##
########################
func get_weapon_attack_target_param_def(target_param_key)->Dictionary:
	var weapon = equipment.get_primary_weapon()
	if weapon:
		return weapon.get_target_param_def()
	var default_attack_data = get_load_val("UnarmedAttackData", {})
	var default = default_attack_data.get("TargetParams", {})
	return default
	
func get_weapon_attack_target_params(target_param_key)->TargetParameters:
	var def = get_weapon_attack_target_param_def(target_param_key)
	return TargetParameters.new(target_param_key, def)

func get_unarmed_attack_weapon_animation():
	var unarmed_data = get_load_val("UnarmedAttackData")
	return unarmed_data.get("DefaultAnimation", "")

## Get damage data for equippted weapon(s)
## If no weapons are equipt, default to Unarmed Damage Data from Actor Def
##  damage_params filters which weapons are returned
##  	Weapon:[Melee|Ranged]:Tags
##			Just 'Weapon' will return MainHand and only include OffHand if Range/Melee matches MainHand
##			[Melee or Ranged] Limit to just Melee or just Ranged Weapons.
##			[Off] Always 
##		Ex. "Weapon" Returns MainHand and includes OffHand if Range/Melee matches MainHand
##			"Weapon:Main" for just MainHand weapon
##			"Weapon:Melee:Off" for OffHand weapon if it's Melee
##			"Weapon:Range" for Ranged weapons regardless of hand
##			"Weapon:Range:Melee" for Main Weapon regardless of Ranged or Melee
## When one of "Melee" or "Ranged" is included, the other will be excluded. 
## When neither are included, Offhand will only be added if Range/Melee matches MainHand
## When one of "Main" or "Off" is included, the other will be excluded. 
func get_weapon_damage_datas(weapon_filter)->Dictionary:
	var out_dict = {}
	var weapons = equipment.get_filtered_weapons(weapon_filter)
	# No weapons found
	if weapons.size() == 0 and weapon_filter.get("FallbackToUnarmed", true):
		var unarmed_data = get_load_val("UnarmedAttackData")
		return unarmed_data.get("DamageDatas", {})
	var index = 0
	var weapon_mods = get_wepaon_mods()
	for weapon:BaseWeaponEquipment in weapons:
		var weapon_damage = weapon.get_damage_datas()
		var applicable_mods = weapon_mods.get(weapon.Id, {})
		for damage_data_key in weapon_damage.keys():
			var sub_key = "Weapon" + str(index) + ":" + damage_data_key
			var damage_data = weapon_damage[damage_data_key].duplicate(true)
			for weapon_mod in applicable_mods.values():
				var mod_datas = weapon_mod.get("WeaponMods", {})
				for mod_data in mod_datas.values():
					if not _does_weapon_mod_apply_to_item(mod_data, weapon):
						continue
					var prop_key = mod_data.get("ModProperty", "")
					if !prop_key:
						continue
					var new_prop_val = mod_data.get("ModValue")
					var org_prop_val = damage_data.get(prop_key)
					var mod_type = mod_data.get("ModType", "")
					if mod_type != "Set":
						printerr("Unsuported WeaponMod Type: " + str(mod_type))
						continue
					damage_data[prop_key] = new_prop_val
			damage_data['IsWeaponDamage'] = true
			out_dict[sub_key] = damage_data
			
		index += 1
	return out_dict

func get_targeting_mods()->Array:
	var out_list = []
	var actor_mods:Array = actor_data.get("StaticTargetMods", [])
	if actor_mods.size() > 0:
		out_list.append_array(actor_mods)
	out_list.append_array(pages.get_targeting_mods())
	return out_list

## Returns All direct DamageMods from Effects and Pages.
## DamageMods from Attack Mods are not included.
func get_damage_mods()->Dictionary:
	var out_dict = {}
	var mods_list = []
	mods_list.append_array(effects.get_damage_mods().values())
	mods_list.append_array(pages.get_damage_mods().values())
	for mod_data in mods_list:
		var mod_key = mod_data['DamageModKey']
		var mod_id = mod_key 
		if mod_data.get("CanStack", false):
			mod_id = mod_key + ":" + Id
		mod_data['DamageModId'] = mod_id
		mod_data['SourceActorId'] = Id
		mod_data['SourceActorFaction'] = FactionIndex
		out_dict[mod_id] = mod_data
	return out_dict

func get_ammo_mods()->Dictionary:
	var out_dict = {}
	out_dict.merge(effects.get_ammo_mods())
	out_dict.merge(pages.get_ammo_mods())
	return out_dict

func get_attack_mods()->Dictionary:
	var out_dict = {}
	var mods_list = []
	mods_list.append_array(effects.get_attack_mods().values())
	mods_list.append_array(pages.get_attack_mods().values())
	mods_list.append_array(equipment.get_attack_mods().values())
	for mod_data in mods_list:
		var mod_key = mod_data['AttackModKey']
		var mod_id = mod_key 
		if mod_data.get("CanStack", false):
			mod_id = mod_key + ":" + Id
		mod_data['AttackModId'] = mod_id
		mod_data['SourceActorId'] = Id
		mod_data['SourceActorFaction'] = FactionIndex
		
		for damage_mod_key in mod_data.get('DamageMods', {}).keys():
			var damage_mod = mod_data['DamageMods'][damage_mod_key]
			damage_mod['DamageModKey'] = damage_mod_key
			damage_mod['DamageModId'] = damage_mod_key
			damage_mod['SourceActorId'] = Id
			damage_mod['SourceActorFaction'] = FactionIndex
			if not damage_mod.has("DisplayName"):
				damage_mod['DisplayName'] = mod_data.get("DisplayName", "")
		
		out_dict[mod_id] = mod_data
	return out_dict

## Returns nested Dic of "Weapon_Id": { "WepaonModId": { Mod data } }
func get_wepaon_mods()->Dictionary:
	var out_dict = {}
	var mods_list = []
	#mods_list.append_array(effects.get_weapon_mods().values())
	mods_list.append_array(pages.get_weapon_mods().values())
	
	var all_hand_items = equipment.list_all_tools_in_hands()
	
	for mod_data in mods_list:
		# Check if mod applies
		if not _does_weapon_mod_apply_to_actor(mod_data):
			continue
		
		var mod_key = mod_data['WeaponModKey']
		var mod_id = mod_key 
		if mod_data.get("CanStack", false):
			mod_id = mod_key + ":" + Id
		mod_data['WeaponModId'] = mod_id
		mod_data['SourceActorId'] = Id
		
		for tool:BaseToolEquipment in all_hand_items:
			if not _does_weapon_mod_apply_to_item(mod_data, tool):
				continue
			if not out_dict.has(tool.Id):
				out_dict[tool.Id] = {}
			out_dict[tool.Id][mod_id] = mod_data.duplicate()
		
	return out_dict

func _does_weapon_mod_apply_to_actor(mod_data:Dictionary)->bool:
	var conditions:Dictionary = mod_data.get("Conditions", {})
	# No Conditions
	if conditions.size() == 0:
		return true
	# Check Actor Tag Requirements
	if conditions.has("ActorTagFilters"):
		if not TagHelper.check_tag_filters("ActorTagFilters", conditions, self):
			return false
	
	# Check MainHand Requirements
	var main_hand_req = conditions.get("RequireMainHand", "Ignore")
	var primary_weapon = equipment.get_primary_weapon()
	
	if main_hand_req == "Empty" and primary_weapon:
		return false
	elif main_hand_req == "Require" and not primary_weapon:
		return false
	if conditions.has("MainHandTagFilters"):
		if not TagHelper.check_tag_filters("MainHandTagFilters", conditions, primary_weapon):
			return false
	
	# Check OffHand Requirements
	var off_hand_req = conditions.get("RequireOffHand", "Ignore")
	var offhand_items = equipment.list_tools_in_offhands()
	
	if off_hand_req == "Empty" and offhand_items.size() > 0:
		return false
	elif (off_hand_req == "All" or off_hand_req == "Any") and offhand_items.size() == 0:
		return false
		
	if conditions.has("OffHandTagFilters"):
		var require_all = off_hand_req == "Any"
		var offhands_valid = not require_all # All: True until false | Any: False until true
		for off_hand_item in offhand_items:
			# Item is match
			if TagHelper.check_tag_filters("OffHandTagFilters", conditions, off_hand_item):
				# All needed to match
				if not require_all:
					offhands_valid = true
					break
			# Only one needed to match
			elif require_all:
				offhands_valid = false
		if not offhands_valid:
			return false
	return true

func _does_weapon_mod_apply_to_item(mod_data:Dictionary, item:BaseToolEquipment)->bool:
	var conditions:Dictionary = mod_data.get("Conditions", {})
	# No Conditions
	if conditions.size() == 0:
		return true
	if conditions.has("TagFilters"):
		if not TagHelper.check_tag_filters("TagFilters", conditions, item):
			return false
	return true

func get_hands_conditions_for_tool(tool:BaseToolEquipment)->Dictionary:
	var equipment_constraints = actor_data.get("EquipmentConstraints", {})
	var hand_conditions = []
	for page:PageItemPassive in pages.list_passives():
		hand_conditions.append_array(page.get_hand_mods())
	var default_hand_conditions = equipment_constraints.get("HandConditions", [])
	hand_conditions.append_array(default_hand_conditions)
		
	for condition in hand_conditions:
		if TagHelper.check_tag_filters("ToolTagFilters", condition, tool):
			return condition
	
	printerr("BaseActor.get_hand_condition: No Conditions found for Tool: '%s" % [tool.Id])
	return {}

class_name ObjectActor
extends BaseActor


func _init(key:String, load_path:String, def:Dictionary, id:String, data:Dictionary) -> void:
	super(key, load_path, def, id, data)

func reload_def(load_path:String, def:Dictionary):
	super(load_path, def)
	_cache_after_loading_def()

func _cache_after_loading_def():
	stats.dirty_stats()
	self.dirty_tags()

func get_npc_index_str()->String:
	return super()

func get_node_scene_path()->String:
	return super()
	
func get_display_name(with_letter:bool=false)->String:
	var dis_name = super(with_letter)
	return dis_name

func get_faction_key()->String:
	if self.is_player:
		return "Player"
	return actor_data.get("Faction", "NO_FACTION")

func is_being_carried()->bool:
	return parent_carrier_actor_id != null

func get_carrier_actor()->CarrierActor:
	if is_being_carried():
		return ActorLibrary.get_actor(parent_carrier_actor_id)
	return null

func get_title()->String:
	return ""

func get_level()->int:
	return 1

func get_xp()->int:
	return 0

func get_xp_to_next_level(_current_level:int=-1)->int:
	return 1

func get_unspent_skill_points()->int:
	return 0

func add_xp(_value:int)->bool:
	return false
	
func get_title_page()->PageItemTitle:
	return null

func get_raw_base_stats()->Dictionary:
	var raw_stats = {}
	# Get base stats from Title Page
	#var title_page = get_title_page()
	#if title_page:
		#raw_stats = title_page.get_base_stats()
	# Override with stats from actor
	var actor_stats = actor_data.get("Stats", {})
	for key in actor_stats.keys():
		raw_stats[key] = actor_stats[key]
	return raw_stats
	

func get_stat_mods_granted_to_carrier()->Array:
	return []

func _get_object_specific_tags()->Array:
	var tag_list = []
	tag_list.append(self.get_faction_key())
	TagHelper.merge_lists(tag_list, super())
	#TagHelper.merge_lists(tag_list, pages.get_tags_added_to_actor())
	#TagHelper.merge_lists(tag_list, effects.get_tags_added_to_actor())
	#TagHelper.merge_lists(tag_list, equipment.get_tags_added_to_actor())
	return tag_list

func _on_stat_change():
	stats_changed.emit()

func _on_health_change():
	health_changed.emit()

###################################
#######   Item Management   #######
###################################

func on_held_items_change(_item_holder_name:String, _change_data:Dictionary):
	pass
	

func validate_itemholders():
	pages.validate_items()
	equipment.validate_items()
	items.validate_items()
	pages.validate_items()
	
	for invalid_item:BaseItem in pages.list_invalid_items():
		if invalid_item.get_item_slots_mods().size() > 0:
			printerr("We have a problem.")
	#Que.dirty_ammo_mods()
	self.dirty_tags()

## Called by ItemHolders when they build slot sets.
## On first pass, we give all items benifit of doubt 
func get_item_slot_mods_for_holder(_holder_name:String)->Dictionary:
	return {}

func save_me()->bool:
	return false

func save_data()->Dictionary:
	var data = super()
	data['Pages'] = pages.build_save_data()
	data['BagItems'] = items.build_save_data()
	data['Equipment'] = equipment.build_save_data()
	data['Title'] = {
		"Level": get_level(),
		"Xp": get_xp()
	}
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
	#
	#var title_data = loading_data.get('Title', {})
	#var title_page = get_title_page()
	#if title_page:
		#title_page.set_level_and_xp(title_data.get("Level", 1), title_data.get("Xp", 0))
	#
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
	for item_key:String in item_list:
		var force_item_id = ''
		if item_key == '':
			continue
			
		var item = ItemLibrary.create_item(item_key, {}, force_item_id)
		if not item:
			printerr("Actor.build_spawned_with_items: Failed to create item with key '%s'." % [item_key])
			continue
		var slot = holder.get_first_valid_slot_for_item(item, false)
		if slot >= 0:
			holder._direct_set_item_in_slot(slot, item)
			print("Spawned Item '%s' into slot %s." % [item.Id, slot])

func clean_state():
	self.is_dead = false
	fill_page_ammo()
	stats.reset_health()

func on_combat_start():
	clean_state()
	pages.sync_passive_page_effects()
	effects.on_combat_start()

func on_delete():
	if is_deleted:
		return
	pages._delete_all_items()
	items._delete_all_items()
	equipment._delete_all_items()
	super()

func leaves_corpse()->bool:
	return false

func apply_damage_event(damage_event:DamageEvent, trigger_effect:bool=false, game_state:GameStateData=null):
	if aggro:
		aggro.add_threat_from_actor(damage_event.attacker, damage_event.final_damage, game_state)
	if stats:
		stats.apply_damage_event(damage_event, trigger_effect, game_state)

func apply_healing(value:int, can_revive:bool=false):
	if stats:
		return stats.apply_healing(value, can_revive)
	
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
			ItemHelper.spawn_item(item_key, {}, map_pos)
	on_death.emit()

func revive():
	is_dead = false
	on_revive.emit()

func can_act()->bool:
	return false

# Overriden by Carrier Actor
func fill_page_ammo(action_id:String=''):
	pages.fill_page_ammo(action_id)

# Used by Que Input Control
func get_action_list()->Array:
	return []

# Used by Ai Handler
func get_action_key_list()->Array:
	var list = pages.list_action_keys()
	if list.size() > 0:
		return list
	return get_load_val("AiData", {}).get("ActionsArr", [])

func get_action_page(action_id)->PageItemAction:
	return ItemLibrary.get_item(action_id)

func get_effect_immunity()->Array:
	var immunities = actor_data.get("ImmuneToEffects", [])
	immunities.append_array(effects.get_effect_immunities())
	return immunities

func is_adirectional()->bool:
	return true


########################
##      Weapons       ##
########################
func get_weapon_attack_target_param_def(_target_param_key)->Dictionary:
	return {}
	
func get_weapon_attack_target_params(_target_param_key)->TargetParameters:
	return null

func get_unarmed_attack_weapon_animation():
	return ""

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
func get_weapon_damage_datas(_weapon_filter:Dictionary={})->Dictionary:
	return {}

########################
##        Mods        ##
########################
func get_targeting_mods()->Array:
	return []

## Returns All direct DamageMods from Effects and Pages.
## DamageMods from Attack Mods are not included.
func get_damage_mods()->Dictionary:
	return {}

func get_ammo_mods()->Dictionary:
	return {}

func get_attack_mods()->Dictionary:
	return {}

## Returns nested Dic of "Weapon_Id": { "WepaonModId": { Mod data } }
func get_wepaon_mods()->Dictionary:
	return {}

func _does_weapon_mod_apply_to_actor(_mod_data:Dictionary)->bool:
	return true

func _does_weapon_mod_apply_to_item(_mod_data:Dictionary, _item:BaseToolEquipment)->bool:
	return false

func get_hands_conditions_for_tool(_tool:BaseToolEquipment)->Dictionary:
	return {}

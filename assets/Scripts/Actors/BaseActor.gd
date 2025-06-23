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
var items:BagItemHolder
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

var spawn_map_layer

var use_ai:bool: 
	get: return ai_def.size() > 0
var ai_def:Dictionary = {}

var is_player:bool = false
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
	stats.bar_stat_changed.connect(_on_health_change)
	effects = EffectHolder.new(self)
	#details = ObjectDetailsData.new(_def_load_path, _def.get("#ObjDetails", {}))
	equipment = EquipmentHolder.new(self)
	equipment.items_changed.connect(_on_equipment_holder_items_change)
	items = BagItemHolder.new(self)
	pages = PageHolder.new(self)
	pages.class_page_changed.connect(_on_page_holder_items_change)
	
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

func get_name()->String:
	if pages:
		var title_page:BasePageItem = pages.get_item_in_slot(0)
		if title_page:
			return title_page.get_display_name()
	return get_display_name()

func get_title()->String:
	if pages:
		var title_page = pages.get_title_page()
		if title_page:
			return title_page.get_title_key()
	return get_display_name()

func get_tags(): 
	var tag_list = []
	tag_list.append_array(super())
	var aditional_tags = pages.get_tags_added_to_actor()
	aditional_tags.append_array(effects.get_tags_added_to_actor())
	for added_tag in aditional_tags:
		if not tag_list.has(added_tag):
			tag_list.append(added_tag)
	return tag_list

# Use load_data
#func post_creation():
	#suppress_equipment_changed = true
	#equipment.load_saved_items()
	#self.equipment_changed.emit()
	#
	#items.load_saved_items()
	#items.set_bag_item(equipment.get_bag_equipment())
	#
	#pages.load_saved_items()
	#pages.set_page_que_item(equipment.get_que_equipment())
	#pages.build_effects()
	#
	#equipment.validate_items()
	#items.validate_items()
	#pages.validate_items()
	#
	#stats.dirty_stats()
	#suppress_equipment_changed = false
	#self.equipment_changed.emit()

func _on_stat_change():
	stats_changed.emit()

func _on_health_change():
	health_changed.emit()

var suppress_equipment_changed:bool = false
func _on_equipment_holder_items_change():
	var bag = equipment.get_bag_equipment()
	if not bag and items.bag_item_id != null:
		items.set_bag_item(null)
	if bag and items.bag_item_id != bag.Id:
		items.set_bag_item(bag)
		
	var page_que = equipment.get_que_equipment()
	if not page_que and pages.page_que_item_id != null:
		pages.set_page_que_item(null)
	if page_que and pages.page_que_item_id != page_que.Id:
		pages.set_page_que_item(page_que)
	
	if not suppress_equipment_changed:
		self.equipment_changed.emit()
		self.stats.recache_stats()
		Que.rechache_page_ammo()

func _on_page_holder_items_change():
	stats.dirty_stats()
	stats.recache_stats()
	Que.rechache_page_ammo()
	#if not suppress_equipment_changed:
		#self.equipment_changed.emit()

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
	suppress_equipment_changed = true
	var stat_data = loading_data.get('Stats', {})
	stats.load_data(stat_data)
	
	var equipment_data = loading_data['Equipment']
	loading_data.erase('Equipment')
	equipment.load_save_data(equipment_data)
	
	var page_data = loading_data['Pages']
	loading_data.erase('Pages')
	pages.load_save_data(page_data)
	var que_item = equipment.get_que_equipment()
	pages.set_page_que_item(que_item, false)
	
	var bag_data = loading_data['BagItems']
	loading_data.erase('BagItems')
	items.load_save_data(bag_data)
	var bag_item = equipment.get_bag_equipment()
	items.set_bag_item(bag_item)
	
	pages.build_effects()
	
	suppress_equipment_changed = false
	equipment.validate_items()
	pages.validate_items()
	items.validate_items()
	stats.dirty_stats()

func prep_for_combat():
	self.is_dead = false
	stats.fill_bar_stats()
	

func on_combat_start():
	effects.on_combat_start()

func on_delete():
	if is_deleted:
		return
	for page in pages.list_items():
		ItemLibrary.delete_item(page)
	for bag_item in items.list_items():
		ItemLibrary.delete_item(bag_item)
	for equip_item in equipment.list_items():
		if !PlayerInventory.has_item(equip_item):
			ItemLibrary.delete_item(equip_item)
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
		var drop_items = get_load_val("DropItemsSet", {})
		var item_key = RandomHelper.roll_from_set(drop_items)
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

func get_weapon_attack_target_params(target_param_key)->TargetParameters:
	var weapon = equipment.get_primary_weapon()
	if weapon:
		return weapon.target_parmas
	var default_attack_data = get_load_val("UnarmedAttackData", {})
	var default = TargetParameters.new(target_param_key, default_attack_data.get("TargetParams", {}))
	return default

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
	var index = 0
	for weapon:BaseWeaponEquipment in weapons:
			var weapon_damage = weapon.get_damage_datas()
			for key in weapon_damage.keys():
				var sub_key = "Weapon" + str(index) + ":" + key
				out_dict[sub_key] = weapon_damage[key]
			index += 1
	return out_dict

func get_effect_immunity()->Array:
	var immunities = actor_data.get("ImmuneToEffects", [])
	immunities.append_array(effects.get_effect_immunities())
	return immunities

func get_targeting_mods()->Array:
	var out_list = []
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

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

# Actor holds no references to the current map state so this method is called by set_actor_pos()
signal on_move(old_pos:MapPos, new_pos:MapPos, move_data:Dictionary)
signal on_move_failed(cur_pos:MapPos)
signal on_death()
signal sprite_changed()

var Que:ActionQue
#var node:ActorNode
var sprite:ActorSprite
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

var FactionIndex : int

var LoadPath:String:
	get: return _def_load_path
var DisplayName:String:
	get: return _data.get("DisplayName", details.display_name)
	set(val): _data["DisplayName"] = val
var SnippetDesc:String:
	get: return details.snippet
var Description:String:
	get: return details.description
var Tags:Array:
	get:
		return details.tags

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
	sprite = ActorSprite.new(self)
	stats = StatHolder.new(self, stat_data)
	stats.stats_changed.connect(_on_stat_change)
	effects = EffectHolder.new(self)
	details = ObjectDetailsData.new(_def_load_path, _def.get("Details", {}))
	equipment = EquipmentHolder.new(self)
	equipment.items_changed.connect(_on_equipment_holder_items_change)
	items = BagItemHolder.new(self)
	pages = PageHolder.new(self)
	pages.class_page_changed.connect(_on_page_holder_items_change)
	
	# Que requires info from Pages and Equipment so must be inited after item validation
	Que = ActionQue.new(self)
	if get_load_val("IsPlayer", false):
		is_player = true

func get_name()->String:
	if pages:
		var title_page:BasePageItem = pages.get_item_in_slot(0)
		if title_page:
			return title_page.details.display_name
	return details.display_name

func get_tags(): 
	var tag_list = []
	tag_list.append_array(Tags)
	var aditional_tags = pages.get_tags_added_to_actor()
	aditional_tags.append_array(effects.get_tags_added_to_actor())
	for added_tag in aditional_tags:
		if not tag_list.has(added_tag):
			tag_list.append(added_tag)
	return tag_list

func post_creation():
	suppress_equipment_changed = true
	equipment.load_saved_items()
	self.equipment_changed.emit()
	
	items.load_saved_items()
	items.set_bag_item(equipment.get_bag_equipment())
	
	pages.load_saved_items()
	pages.set_page_que_item(equipment.get_que_equipment())
	
	equipment.validate_items()
	items.validate_items()
	pages.validate_items()
	
	stats.dirty_stats()
	suppress_equipment_changed = false
	self.equipment_changed.emit()

func _on_stat_change():
	stats_changed.emit()

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

func _on_page_holder_items_change():
	stats.dirty_stats()
	stats.recache_stats()
	if not suppress_equipment_changed:
		self.equipment_changed.emit()

func save_me()->bool:
	return self.is_player

func save_data()->Dictionary:
	var data = super()
	data['Pages'] = pages.build_save_data()
	data['BagItems'] = items.build_save_data()
	data['Equipment'] = equipment.build_save_data()
	data['Stats'] = stats.build_save_data()
	return data

func load_data(data:Dictionary):
	var stat_data = data.get('Stats', {})
	stats.load_data(stat_data)
	
	var equipment_data = data['Equipment']
	data.erase('Equipment')
	equipment.load_save_data(equipment_data)
	
	var page_data = data['Pages']
	data.erase('Pages')
	pages.load_save_data(page_data)
	var que_item = equipment.get_que_equipment()
	pages.set_page_que_item(que_item)
	
	var bag_data = data['BagItems']
	data.erase('BagItems')
	items.load_save_data(bag_data)
	var bag_item = equipment.get_bag_equipment()
	items.set_bag_item(bag_item)
	
	equipment.validate_items()
	pages.validate_items()
	items.validate_items()
	_data = data
	stats.dirty_stats()

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
				item.item_details['Value'] = int(tokens[1])
			else:
				ItemHelper.spawn_item(item_key, {}, map_pos)
	on_death.emit()

func can_act()->bool:
	if stats.get_stat('Frozen', -1) > 0:
		return false
	return true

func get_action_key_list()->Array:
	var list = pages.list_action_keys()
	if list.size() > 0:
		return list
	return get_load_val("AiData", {}).get("ActionsArr", [])

func get_default_attack_target_params()->TargetParameters:
	var weapon = equipment.get_primary_weapon()
	if weapon:
		return TargetParameters.new("Default", weapon.get_load_val("TargetParams"))
	var default_attack_data = get_load_val("DefaultAttackData", {})
	var default = TargetParameters.new("Default", default_attack_data.get("TargetParams", {}))
	return default

func get_default_attack_damage_datas()->Dictionary:
	var out_dict = get_weapon_damage_datas()
	if out_dict.size() == 0:
		var default_attack_data = get_load_val("DefaultAttackData", {}).duplicate()
		var default_damage_datas = default_attack_data.get("DamageDatas", {})
		for d_data_key in default_damage_datas.keys():
			var d_data = default_damage_datas[d_data_key]
			if not d_data.keys().has("DamageDataKey"):
				d_data["DamageDataKey"] = d_data_key
			out_dict[d_data_key] = d_data.duplicate()
	return out_dict

func get_weapon_damage_datas()->Dictionary:
	var out_dict = {}
	var weapon = equipment.get_primary_weapon()
	if weapon:
		var main_hand_data = weapon.get_damage_data().duplicate()
		if equipment.is_two_handing():
			var two_hand_mod = stats.get_stat(StatHelper.TwoHandMod)
			main_hand_data['AtkPower'] = main_hand_data['AtkPower'] * two_hand_mod
			out_dict['WeaponDamage'] = main_hand_data
		else:
			out_dict['WeaponDamage'] = main_hand_data
			var off_hand_weapon = equipment.get_offhand_weapon()
			if off_hand_weapon:
				var off_hand_data = off_hand_weapon.get_damage_data().duplicate()
				var off_hand_mod = stats.get_stat(StatHelper.OffHandMod)
				off_hand_data['AtkPower'] = off_hand_data['AtkPower'] * off_hand_mod
				out_dict['OffHandDamage'] = off_hand_data
	return out_dict

func get_targeting_mods()->Array:
	var out_list = []
	out_list.append_array(pages.get_targeting_mods())
	return out_list

func get_damage_mods(taking_damage:bool)->Array:
	var out_list = []
	if taking_damage:
		out_list.append_array(effects.get_on_take_damage_mods())
	else:
		out_list.append_array(effects.get_on_deal_damage_mods())
	out_list.append_array(pages.get_damage_mods(taking_damage))
	return out_list

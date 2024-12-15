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
signal turn_failed

signal equipment_changed
signal bag_items_changed
signal page_list_changed
signal action_que_changed
signal effacts_changed

# Actor holds no references to the current map state so this method is called by MapState.set_actor_pos()
signal on_move(old_pos:MapPos, new_pos:MapPos, move_data:Dictionary)
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

var Id : String:
	get: return _id
var ActorKey : String:
	get: return _key
func get_tagable_id(): return Id
func get_tags(): return Tags

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
var Tags:Array = []

var spawn_map_layer

var _allow_auto_que:bool = false

var is_player:bool = false
var is_dead:bool = false

func _init(key:String, load_path:String, def:Dictionary, id:String, data:Dictionary) -> void:
	super(key, load_path, def, id, data)
	spawn_map_layer = _def.get('SpawnOnMapLayer', MapStateData.DEFAULT_ACTOR_LAYER)
	
	var auto_que_list = _def.get("AutoQue", [])
	if auto_que_list is Array:
		_allow_auto_que = auto_que_list.size() > 0
	elif auto_que_list:
		_allow_auto_que = true
	
	var stat_data = _def["Stats"]
	
	sprite = ActorSprite.new(self)
	stats = StatHolder.new(self, stat_data)
	effects = EffectHolder.new(self)
	details = ObjectDetailsData.new(_def_load_path, _def.get("Details", {}))
	equipment = EquipmentHolder.new(self)
	equipment.items_changed.connect(_on_equipment_holder_items_change)
	items = BagItemHolder.new(self, equipment.get_bag_equipment())
	pages = PageHolder.new(self, equipment.get_que_equipment())
	pages.class_page_changed.connect(_on_class_page_change)
	
	equipment.validate_items()
	items.validate_items()
	pages.validate_items()
	# Que requires info from Pages and Equipment so must be inited after item validation
	Que = ActionQue.new(self)
	if get_load_val("IsPlayer", false):
		is_player = true

func post_creation():
	pages.load_effects()

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
	
	self.equipment_changed.emit()

func _on_class_page_change():
	stats.dirty_stats()
	stats.recache_stats()

func save_me()->bool:
	return self.is_player

func save_data()->Dictionary:
	var data = super()
	data['Pages'] = pages.list_item_ids(true)
	data['BagItems'] = items.list_item_ids(true)
	data['Equipment'] = equipment.list_item_ids(true)
	return data

func on_combat_start():
	effects.on_combat_start()

func die():
	if is_dead:
		return
	is_dead = true
	var map_pos = CombatRootControl.Instance.GameState.MapState.get_actor_pos(self)
	if map_pos:
		var drop_items = get_load_val("DropItems", [])
		for item_key in drop_items:
			ItemHelper.spawn_item(item_key, {}, map_pos)
		
	on_death.emit()
	#node.set_corpse_sprite()
	#node.queue_death()
	
func auto_build_que(current_turn:int):
	if !_allow_auto_que:
		return
	var actions = AiHandler.build_action_que(self, CombatRootControl.Instance.GameState)
	for action_name in actions:
		var action = ActionLibrary.get_action(action_name)
		if action:
			#print("Queing Page: " + action_name)
			Que.que_action(action)
		else:
			printerr("Quied Page %s not found" % [action_name])
			
func get_action_list()->Array:
	return pages.list_action_keys()

func get_default_attack_target_params()->TargetParameters:
	var weapon = equipment.get_primary_weapon()
	if weapon:
		return TargetParameters.new("Default", weapon.get_load_val("TargetParams"))
	var default_attack_data = get_load_val("DefaultAttackData", {})
	var default = TargetParameters.new("Default", default_attack_data.get("TargetParams", {}))
	return default

func get_default_attack_damage_datas()->Dictionary:
	var out_dict = {}
	var weapon = equipment.get_primary_weapon()
	if weapon:
		out_dict['WeaponDamage'] = weapon.get_damage_data()
	else:
		var default_attack_data = get_load_val("DefaultAttackData", {})
		var default_damage_datas = default_attack_data.get("DamageDatas", {})
		for d_data_key in default_damage_datas.keys():
			var d_data = default_damage_datas[d_data_key]
			if not d_data.keys().has("DamageDataKey"):
				d_data["DamageDataKey"] = d_data_key
			out_dict[d_data_key] = d_data.duplicate()
	return out_dict

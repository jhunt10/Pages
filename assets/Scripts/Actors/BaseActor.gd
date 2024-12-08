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
	Que = ActionQue.new(self)
	pages = PageHolder.new(self, equipment.get_que_equipment())
	pages.class_page_changed.connect(_on_class_page_change)
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
	return data

func on_combat_start():
	effects.on_combat_start()

#func set_pos(old_pos:MapPos, new_pos:MapPos, move_type:String, moved_by:BaseActor):
	#on_move.emit(old_pos, new_pos, move_type, moved_by)
	#if node:
		#node.set_display_pos(new_pos)

#func on_turn_failed():
	#node.cancel_current_animation()

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
	#var auto_que_list = get_load_val("AutoQue", null)
	#if Que:
		#for action_key in auto_que_list:
			#var action = ActionLibrary.get_action(action_key)
			#print("AutoQue: " + action.ActionKey)
			#if action:
				#Que.que_action(action)
				
				
				
	#var player = CombatRootControl.Instance.get_player_actor()
	#var player_pos = CombatRootControl.Instance.GameState.MapState.get_actor_pos(player)
	#
	#var self_pos = CombatRootControl.Instance.GameState.MapState.get_actor_pos(self)
	#var path_res = AiHandler.path_to_target(self, self_pos, player_pos, CombatRootControl.Instance.GameState)
	#print("Actor: %s built path:\n\tFrom: %s to %s\n\t%s" % [self.Id, self_pos, player_pos, path_res])
	#for move_name in path_res['Moves']:
		#if pages.has_page(move_name):
			#var action = ActionLibrary.get_action(move_name)
			#if action:
				#print("Queing Page: " + move_name)
				#Que.que_action(action)
			#else:
				#printerr("Move Page %s not found" % [move_name])
		#else:
			#printerr("Move Page %s not equipt" % [move_name])
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
